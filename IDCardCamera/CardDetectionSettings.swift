//
//  CardDetectionSettings.swift
//  IDCardCamera
//
//  Created by Jakub Dolejs on 11/12/2019.
//  Copyright © 2019 Applied Recognition Inc. All rights reserved.
//

import UIKit

/// Card detection session settings
/// - Since: 1.0.0
@objc public class CardDetectionSettings: BaseCardDetectionSettings, TorchSettings {
    
    /// Set the torch level when the user turns the torch on
    ///
    /// Range `0.0` (darkest) – `1` (brightest). Default value is `0.1`.
    /// - Since: 1.2.0
    @objc public var torchLevel: Float = 0.1
}

/// Base card detection settings
/// - Since: 1.4.0
@objc public class BaseCardDetectionSettings: NSObject {
    
    /// Card orientation
    /// - Since: 1.0.0
    @objc public enum Orientation: Int {
        /// Landscape (height &lt; width)
        case landscape
        /// Portrait (width &lt; height)
        case portrait
    }
    
    /// Size of the card to detect
    ///
    /// Only the aspect ratio is considered by the app. The units are inconsequential.
    /// - Since: 1.0.0
    @objc public var size: CGSize
    
    /// Orientation of the card to be detected
    ///
    /// The orientation is determined by the size. Setting the orientation to the other available value will flip the width and height of the size.
    /// - Since: 1.0.0
    @objc public var orientation: Orientation {
        get {
            return size.width > size.height ? .landscape : .portrait
        }
        set {
            if newValue == .landscape && size.width < size.height {
                let w = size.width
                size.width = size.height
                size.height = w
            } else if newValue == .portrait && size.height < size.width {
                let h = size.height
                size.height = size.width
                size.width = h
            }
        }
    }
    /// Number of image samples the camera should collect
    ///
    /// The samples in the pool are compared for sharpness and the sharpest one is de-warped and returned.
    /// - Since: 1.1.0
    @objc public var imagePoolSize: Int = 5
    
    /// Initializer
    /// - Parameters:
    ///   - width: Width of the card (units don't matter)
    ///   - height: Height of the card (units don't matter)
    /// - Since: 1.0.0
    @objc public init(width: CGFloat, height: CGFloat) {
        self.size = CGSize(width: width, height: height)
    }
    
    /// Convenience initializer
    ///
    /// Initializes settings with ISO ID-1 dimensions
    /// - Since: 1.4.0
    @objc public convenience override init() {
        self.init(width: 85.6, height: 53.98)
    }
}
