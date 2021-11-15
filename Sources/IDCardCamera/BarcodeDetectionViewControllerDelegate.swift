//
//  BarcodeDetectionViewControllerDelegate.swift
//  IDCardCamera
//
//  Created by Jakub Dolejs on 19/12/2019.
//  Copyright © 2019 Applied Recognition Inc. All rights reserved.
//

import Foundation
import Vision

/// Barcode detection view controller delegate
/// - Since: 1.4.0
@objc public protocol BarcodeDetectionViewControllerDelegate: AnyObject {
    
    /// Called when barcode detection succeeds
    /// - Parameters:
    ///   - viewController: View controller that detected the barcode
    ///   - data: Raw barcode data
    /// - Since: 1.4.0
    @objc func barcodeDetectionViewController(_ viewController: BarcodeDetectionViewController, didDetectBarcodes barcodes: [VNBarcodeObservation])
    
    /// Called when barcode detection is cancelled
    /// - Parameter viewController: View controller that was used for barcode detection
    /// - Since: 1.4.0
    @objc optional func barcodeDetectionViewControllerDidCancel(_ viewController: BarcodeDetectionViewController)
}
