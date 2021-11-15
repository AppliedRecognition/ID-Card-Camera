//
//  CardDetectionSessionHandler.swift
//  VerIDIDCapture
//
//  Created by Jakub Dolejs on 03/01/2018.
//  Copyright © 2018 Applied Recognition, Inc. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class ObjectDetectionSessionHandler: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var session = AVCaptureSession()
    lazy var captureLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer(session: self.session)
        layer.videoGravity = .resizeAspectFill
        return layer
    }()
    
    lazy var rectangleDetectionQueue: DispatchQueue = {
        return DispatchQueue(label: "com.appliedrec.Ver-ID.RectangleDetection", attributes: [])
    }()
    
    lazy var imageConversionOperationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    lazy var device: AVCaptureDevice? = {
        return AVCaptureDevice.default(.builtInWideAngleCamera , for: .video, position: .back)
    }()
    
    var imageOrientation: CGImagePropertyOrientation = .right
    
    weak var delegate: CardDetectionSessionHandlerDelegate?
    
    var isTorchAvailable: Bool {
        guard let device = self.device else {
            return false
        }
        return device.hasTorch && device.isTorchAvailable
    }
    
    var cardDetectionSettings: BaseCardDetectionSettings?
    var barcodeDetectionSettings: BaseBarcodeDetectionSettings?
    var torchSettings: TorchSettings?
    
    var imageTransform: CGAffineTransform {
        switch self.imageOrientation {
        case .right, .left:
            return CGAffineTransform(scaleX: self.captureLayer.bounds.width, y: 0-self.captureLayer.bounds.height).concatenating(CGAffineTransform(translationX: 0, y: self.captureLayer.bounds.height))
        default:
            return CGAffineTransform(scaleX: 0-self.captureLayer.bounds.width, y: self.captureLayer.bounds.height).concatenating(CGAffineTransform(translationX: self.captureLayer.bounds.width, y: 0))
        }
    }
    
    func startCamera() {
        guard let device = self.device else {
            return
        }
        
        do {
            try device.lockForConfiguration()
            if device.isExposureModeSupported(.continuousAutoExposure) {
                device.exposureMode = .continuousAutoExposure
            }
            if device.isFocusModeSupported(.continuousAutoFocus) {
                device.focusMode = .continuousAutoFocus
            } else if device.isFocusModeSupported(.autoFocus) {
                device.focusMode = .autoFocus
            }
            if device.isFocusPointOfInterestSupported {
                device.focusPointOfInterest = CGPoint(x: 0.5, y: 0.5)
            }
            device.unlockForConfiguration()
        } catch {
            
        }
        
        self.imageConversionOperationQueue.isSuspended = false
        
        let input = try! AVCaptureDeviceInput(device: device)
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: self.rectangleDetectionQueue)
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        
        session.beginConfiguration()
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }
        
        session.commitConfiguration()
        
        session.startRunning()
    }
    
    func stopCamera() {
        self.toggleTorch(on: false)
        self.imageConversionOperationQueue.cancelAllOperations()
        self.imageConversionOperationQueue.isSuspended = true
        session.stopRunning()
    }
    
    func toggleTorch(on: Bool) {
        guard let device = self.device else {
            return
        }
        if device.hasTorch && device.isTorchAvailable {
            do {
                try device.lockForConfiguration()
                if on {
                    if let torchLevel = self.torchSettings?.torchLevel {
                        try device.setTorchModeOn(level: torchLevel)
                    } else {
                        device.torchMode = .on
                    }
                } else {
                    device.torchMode = .off
                }
                device.unlockForConfiguration()
            } catch {
                NSLog("Unable to lock device for configuation: %@", error.localizedDescription)
            }
        }
    }
    
    func featureTransform(fromSize size: CGSize, atOrientation orientation: CGImagePropertyOrientation) -> CGAffineTransform {
        switch orientation {
        case .right, .left:
            return CGAffineTransform(scaleX: size.width, y: 0-size.height).concatenating(CGAffineTransform(translationX: 0, y: size.height))
        default:
            return CGAffineTransform(scaleX: 0-size.width, y: size.height).concatenating(CGAffineTransform(translationX: size.width, y: 0))
        }
    }
    
    func rectangleDetectionRequest(withPixelBuffer pixelBuffer: CVImageBuffer) -> VNDetectRectanglesRequest? {
        guard let delegate = self.delegate, delegate.shouldDetectCardImageWithSessionHandler(self) && !self.imageConversionOperationQueue.isSuspended && self.imageConversionOperationQueue.operationCount == 0 else {
            return nil
        }
        let orientation = self.imageOrientation
        let rectangleDetectionRequest = VNDetectRectanglesRequest() { (request, error) in
            if let rect = request.results?.first as? VNRectangleObservation, !self.imageConversionOperationQueue.isSuspended && self.imageConversionOperationQueue.operationCount == 0 {
                let op = PerspectiveCorrectionParamsOperation(pixelBuffer: pixelBuffer, orientation: orientation, rect: rect)
                op.completionBlock = { [weak self, weak op] in
                    let sharpness = op?.sharpness
                    if let cgImage = op?.cgImage, let corners = op?.corners, let params = op?.perspectiveCorrectionParams {
                        DispatchQueue.main.async {
                            guard let `self` = self else {
                                return
                            }
                            delegate.sessionHandler(self, didDetectCardInImage: cgImage, withTopLeftCorner: corners.topLeft, topRightCorner: corners.topRight, bottomRightCorner: corners.bottomRight, bottomLeftCorner: corners.bottomLeft, perspectiveCorrectionParams: params, sharpness: sharpness)
                        }
                    }
                }
                self.imageConversionOperationQueue.addOperation(op)
            }
        }
        rectangleDetectionRequest.maximumObservations = 1
        return rectangleDetectionRequest
    }
    
    func barcodeDetectionRequest(settings: BaseBarcodeDetectionSettings) -> VNDetectBarcodesRequest? {
        guard let delegate = self.delegate, delegate.shouldDetectBarcodeWithSessionHandler(self) else {
            return nil
        }
        let request = VNDetectBarcodesRequest { request, error in
            guard let barcodes = request.results?.compactMap({ $0 as? VNBarcodeObservation }), !barcodes.isEmpty else {
                return
            }
            DispatchQueue.main.async {
                self.delegate?.sessionHandler(self, didDetectBarcodes: barcodes)
            }
        }
        request.symbologies = settings.barcodeSymbologies
        return request
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if let adjustingFocus = self.device?.isAdjustingFocus, adjustingFocus {
            return
        }
        guard let delegate = self.delegate else {
            return
        }
        if !delegate.shouldDetectBarcodeWithSessionHandler(self) && !delegate.shouldDetectCardImageWithSessionHandler(self) {
            return
        }
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        let requestOptions: [VNImageOption:Any] = [:]
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: self.imageOrientation, options: requestOptions)
        
        var requests: [VNRequest] = []
        if let rectangleDetectionRequest = self.rectangleDetectionRequest(withPixelBuffer: pixelBuffer) {
            requests.append(rectangleDetectionRequest)
        }
        if delegate.shouldDetectBarcodeWithSessionHandler(self), let settings = self.barcodeDetectionSettings, let request = self.barcodeDetectionRequest(settings: settings) {
            requests.append(request)
        }
        if !requests.isEmpty {
            do {
                try handler.perform(requests)
            } catch {
                
            }
        }
    }
}

protocol CardDetectionSessionHandlerDelegate: AnyObject {
    func sessionHandler(_ handler: ObjectDetectionSessionHandler, didDetectCardInImage image: CGImage, withTopLeftCorner topLeftCorner: CGPoint, topRightCorner: CGPoint, bottomRightCorner: CGPoint, bottomLeftCorner: CGPoint, perspectiveCorrectionParams: [String:CIVector], sharpness: Float?)
    func sessionHandler(_ handler: ObjectDetectionSessionHandler, didDetectBarcodes barcodes: [VNBarcodeObservation])
    func shouldDetectCardImageWithSessionHandler(_ handler: ObjectDetectionSessionHandler) -> Bool
    func shouldDetectBarcodeWithSessionHandler(_ handler: ObjectDetectionSessionHandler) -> Bool
}
