//
//  BarcodeDetectionSettings.swift
//  IDCardCamera
//
//  Created by Jakub Dolejs on 19/12/2019.
//  Copyright © 2019 Applied Recognition Inc. All rights reserved.
//

import Foundation
import Vision

/// Barcode detection settings
/// - Since: 1.4.0
@objc public class BarcodeDetectionSettings: BaseBarcodeDetectionSettings, TorchSettings {
    
    /// Set the torch level when the user turns the torch on
    ///
    /// Range `0.0` (darkest) – `1` (brightest). Default value is `0.1`.
    /// - Since: 1.4.0
    @objc public var torchLevel: Float = 0.1
}

/// Base class for barcode detection settings
/// - Since: 1.4.0
@objc public class BaseBarcodeDetectionSettings: NSObject {
    
    /// Symbologies of barcodes to detect
    /// - Since: 1.4.0
    @objc public let barcodeSymbologies: [VNBarcodeSymbology]
    
    /// Initializer
    /// - Parameter barcodeSymbologies: Symbologies of barcodes to detect
    /// - Throws: Barcode detection settings error when attempting to initialize the settings with an unsupported barcode symbology
    /// - Since: 1.4.0
    @objc public init(barcodeSymbologies: [VNBarcodeSymbology]) throws {
        self.barcodeSymbologies = try barcodeSymbologies.filter({
            if !VNDetectBarcodesRequest.supportedSymbologies.contains($0) {
                throw BarcodeDetectionSettingsError.unsupportedBarcodeSymbology
            }
            return true
        })
    }
}

/// Barcode detection settings error
/// - Since: 1.4.0
@objc public enum BarcodeDetectionSettingsError: Int, Error {
    /// Unsupported barcode symbology error
    /// - Since: 1.4.0
    case unsupportedBarcodeSymbology
}
