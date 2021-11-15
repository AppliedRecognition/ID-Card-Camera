//
//  CardAndBarcodeDetectionSettings.swift
//  IDCardCamera
//
//  Created by Jakub Dolejs on 19/12/2019.
//  Copyright © 2019 Applied Recognition Inc. All rights reserved.
//

import UIKit
import Vision

/// Combined card and barcode detection settings
/// - Since: 1.4.0
@objc public class CardAndBarcodeDetectionSettings: NSObject, TorchSettings {
    
    /// Set the torch level when the user turns the torch on
    ///
    /// Range `0.0` (darkest) – `1` (brightest). Default value is `0.1`.
    /// - Since: 1.4.0
    @objc public var torchLevel: Float = 0.1
    
    /// Card detection settings (for the front side of the card)
    /// - Since: 1.4.0
    @objc public let cardDetectionSettings: BaseCardDetectionSettings
    
    /// Barcode detection settings (for the back of the card)
    /// - Since: 1.4.0
    @objc public let barcodeDetectionSettings: BaseBarcodeDetectionSettings
    
    /// Initializer
    /// - Parameters:
    ///   - width: Width of the card (units don't matter)
    ///   - height: Height of the card (units don't matter)
    ///   - barcodeSymbologies: Barcode symbologies to look for
    /// - Since: 1.4.0
    @objc public init(width: CGFloat, height: CGFloat, barcodeSymbologies: [VNBarcodeSymbology]) throws {
        self.cardDetectionSettings = BaseCardDetectionSettings(width: width, height: height)
        self.barcodeDetectionSettings = try BaseBarcodeDetectionSettings(barcodeSymbologies: barcodeSymbologies)
    }
    
    /// Convenience initializer
    ///
    /// Initializes settings with ISO ID-1 dimensions and PDF417 barcode
    /// - Since: 1.4.0
    @objc public override init() {
        self.cardDetectionSettings = BaseCardDetectionSettings()
        self.barcodeDetectionSettings = try! BaseBarcodeDetectionSettings(barcodeSymbologies: VNDetectBarcodesRequest.supportedSymbologies.contains(.pdf417) ? [.pdf417] : [])
    }
}
