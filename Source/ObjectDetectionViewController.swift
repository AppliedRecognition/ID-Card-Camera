//
//  CardDetectionViewController.swift
//  VerIDIDCapture
//
//  Created by Jakub Dolejs on 03/01/2018.
//  Copyright © 2018 Applied Recognition, Inc. All rights reserved.
//

import UIKit
import AVFoundation

public class ObjectDetectionViewController: UIViewController, CardDetectionSessionHandlerDelegate {
    
    let sessionHandler = ObjectDetectionSessionHandler()
    
    lazy var backgroundOperationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    @IBOutlet var cameraPreview: UIView!
    @IBOutlet var torchImageView: UIImageView!
    
    @IBAction func toggleTorch(_ sender: UIGestureRecognizer) {
        if !self.sessionHandler.isTorchAvailable {
            return
        }
        let torchOn: Bool
        let imageName: String
        if let torchActive = self.sessionHandler.device?.isTorchActive, torchActive {
            torchOn = false
            imageName = "torch_on"
        } else {
            torchOn = true
            imageName = "torch_off"
        }
        self.sessionHandler.toggleTorch(on: torchOn)
        self.torchImageView.image = UIImage(named: imageName, in: Bundle(for: type(of: self)), compatibleWith: nil)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.cameraPreview.layer.addSublayer(self.sessionHandler.captureLayer)
        self.torchImageView.isHidden = !self.sessionHandler.isTorchAvailable
    }
    
    override public var prefersStatusBarHidden: Bool {
        return true
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.sessionHandler.delegate = self
        self.navigationController?.navigationBar.barStyle = .blackTranslucent
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
        case .authorized:
            self.sessionHandler.startCamera()
        case .notDetermined:
            self.sessionHandler.imageConversionOperationQueue.isSuspended = true
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { [weak self] granted in
                guard let `self` = self else {
                    return
                }
                if granted {
                    self.sessionHandler.startCamera()
                } else {
                    self.cancel()
                }
            })
        default:
            self.sessionHandler.imageConversionOperationQueue.isSuspended = true
            guard let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String else {
                return
            }
            let alert = UIAlertController(title: "Camera permission required", message: "ID capture requires camera permission. Please enable camera for \(appName) in settings", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                if let settingsURL = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(settingsURL) {
                    UIApplication.shared.open(settingsURL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: { _ in
                        self.cancel()
                    })
                } else {
                    self.cancel()
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                self.cancel()
            }))
            self.present(alert, animated: true, completion: nil)
        }
        self.sessionHandler.captureLayer.frame = self.cameraPreview.bounds
        self.backgroundOperationQueue.isSuspended = false
        self.backgroundOperationQueue.cancelAllOperations()
        self.updateCameraOrientation()
        self.view.layoutIfNeeded()
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.barStyle = .default
        super.viewWillDisappear(animated)
        self.sessionHandler.stopCamera()
        self.sessionHandler.delegate = nil
    }
    
    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animateAlongsideTransition(in: self.view, animation: nil, completion: { context in
            if !context.isCancelled {
                self.sessionHandler.captureLayer.frame.size = size
                self.updateCameraOrientation()
                self.sessionHandler.captureLayer.videoGravity = .resizeAspectFill
            }
        })
    }

    func updateCameraOrientation() {
        if let videoPreviewLayerConnection = self.sessionHandler.captureLayer.connection {
            let avCaptureVideoOrientation: AVCaptureVideoOrientation
            switch UIApplication.shared.statusBarOrientation {
            case .portraitUpsideDown:
                avCaptureVideoOrientation = .portraitUpsideDown
                self.sessionHandler.imageOrientation = .left
            case .landscapeLeft:
                avCaptureVideoOrientation = .landscapeLeft
                self.sessionHandler.imageOrientation = .up
            case .landscapeRight:
                avCaptureVideoOrientation = .landscapeRight
                self.sessionHandler.imageOrientation = .down
            default:
                avCaptureVideoOrientation = .portrait
                self.sessionHandler.imageOrientation = .right
            }
            videoPreviewLayerConnection.videoOrientation = avCaptureVideoOrientation
        }
    }
    
    func sessionHandler(_ handler: ObjectDetectionSessionHandler, didDetectCardInImage image: CGImage, withTopLeftCorner topLeftCorner: CGPoint, topRightCorner: CGPoint, bottomRightCorner: CGPoint, bottomLeftCorner: CGPoint, perspectiveCorrectionParams: [String:CIVector]) {
        
    }
    
    func sessionHandler(_ handler: ObjectDetectionSessionHandler, didDetectBarcodeData data: Data) {
        
    }
    
    func shouldDetectBarcodeWithSessionHandler(_ handler: ObjectDetectionSessionHandler) -> Bool {
        return false
    }
    
    func shouldDetectCardImageWithSessionHandler(_ handler: ObjectDetectionSessionHandler) -> Bool {
        return false
    }
    
    func cancel() {
        
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
