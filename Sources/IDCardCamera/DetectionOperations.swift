//
//  DetectionOperations.swift
//  VerIDCredentials
//
//  Created by Jakub Dolejs on 12/01/2018.
//  Copyright © 2018 Applied Recognition, Inc. All rights reserved.
//

import UIKit
import Vision

@available(iOS 11.0, *)
public class PerspectiveCorrectionParamsOperation: Operation {
    
    let orientation: CGImagePropertyOrientation
    let pixelBuffer: CVImageBuffer
    let rect: VNRectangleObservation
    
    var perspectiveCorrectionParams: [String:CIVector]?
    var corners: (topLeft: CGPoint, topRight: CGPoint, bottomRight: CGPoint, bottomLeft: CGPoint)?
    var cgImage: CGImage?
    var sharpness: Float?
    
    public init(pixelBuffer: CVImageBuffer, orientation: CGImagePropertyOrientation, rect: VNRectangleObservation) {
        self.pixelBuffer = pixelBuffer
        self.orientation = orientation
        self.rect = rect
    }
    
    public override func main() {
        if #available(iOS 13.0, *) {
            self.sharpness = pixelBuffer.sharpness()
        }
        guard let cgImage = pixelBuffer.cgImage(withOrientation: orientation) else {
            return
        }
        let imageSize = CGSize(width: cgImage.width, height: cgImage.height)
        let transform = CGAffineTransform(scaleX: imageSize.width, y: imageSize.height)
        
        let corners: (topLeft: CGPoint, topRight: CGPoint, bottomRight: CGPoint, bottomLeft: CGPoint)
        let flipTransform: CGAffineTransform
        switch orientation {
        case .left, .right:
            corners = (topLeft: rect.topLeft.applying(transform), topRight: rect.topRight.applying(transform), bottomRight: rect.bottomRight.applying(transform), bottomLeft: rect.bottomLeft.applying(transform))
            flipTransform = CGAffineTransform(scaleX: 1, y: -1).concatenating(CGAffineTransform(translationX: 0, y: imageSize.height))
        default:
            corners = (topLeft: rect.bottomRight.applying(transform), topRight: rect.bottomLeft.applying(transform), bottomRight: rect.topLeft.applying(transform), bottomLeft: rect.topRight.applying(transform))
            flipTransform = CGAffineTransform(scaleX: -1, y: 1).concatenating(CGAffineTransform(translationX: imageSize.width, y: 0))
        }
        let params = [
            "inputTopLeft": CIVector(cgPoint: corners.topLeft),
            "inputTopRight": CIVector(cgPoint: corners.topRight),
            "inputBottomRight": CIVector(cgPoint: corners.bottomRight),
            "inputBottomLeft": CIVector(cgPoint: corners.bottomLeft)
        ]
        
        self.cgImage = cgImage
        self.corners = (topLeft: corners.topLeft.applying(flipTransform), topRight: corners.topRight.applying(flipTransform), bottomRight: corners.bottomRight.applying(flipTransform), bottomLeft: corners.bottomLeft.applying(flipTransform))
        self.perspectiveCorrectionParams = params
    }
}
