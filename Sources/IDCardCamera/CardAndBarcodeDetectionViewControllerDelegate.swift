//
//  CardAndBarcodeDetectionViewControllerDelegate.swift
//  IDCardCamera
//
//  Created by Jakub Dolejs on 19/12/2019.
//  Copyright © 2019 Applied Recognition Inc. All rights reserved.
//

import UIKit
import Vision

/// Delegate for combined detection of front and back of the card
/// - Since: 1.4.0
@objc public protocol CardAndBarcodeDetectionViewControllerDelegate: AnyObject {
    
    /// Called when the detection finishes
    /// - Parameters:
    ///   - viewController: View controller that detected the card and barcodes
    ///   - image: Image of the front of the detected card straightened to fit the rectangle specified in settings
    ///   - barcodes: Barcodes detected in the session (empty array if user skips the barcode detection)
    ///   - settings: Settings used for the card and barcode detection
    /// - Since: 1.4.0
    @objc func cardAndBarcodeDetectionViewController(_ viewController: CardAndBarcodeDetectionViewController, didDetectCard image: CGImage, andBarcodes barcodes: [VNBarcodeObservation], withSettings settings: CardAndBarcodeDetectionSettings)
    
    /// Called when the detection is cancelled
    /// - Parameter viewController: View controller that was used for detection
    /// - Since: 1.4.0
    @objc optional func cardAndBarcodeDetectionViewControllerDidCancel(_ viewController: CardAndBarcodeDetectionViewController)
    
    /// Called when an image is straightened
    ///
    /// Implement in your delegate to determine the image quality. By default the quality is determined by
    /// the sharpness of the image. However, sharpness detection is only available on iOS 13 and newer.
    /// If you wish to keep the sharpness detection and implement your own image quality scoring for iOS 12
    /// and older return `nil` on iOS 13 and your score on iOS 12 and older.
    /// - Parameter image: Image
    /// - Returns: Score representing the quality of the image (higher score is better than lower)
    /// - Since: 1.4.0
    @objc optional func qualityOfImage(_ image: CGImage) -> NSNumber?
}
