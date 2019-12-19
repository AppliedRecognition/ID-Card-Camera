//
//  TorchSettings.swift
//  IDCardCamera
//
//  Created by Jakub Dolejs on 19/12/2019.
//  Copyright © 2019 Applied Recognition Inc. All rights reserved.
//

import Foundation

/// Protocol describing torch settings
/// - Since: 1.4.0
@objc public protocol TorchSettings {
    
    /// Set the torch level when the user turns the torch on
    ///
    /// Range `0.0` (darkest) – `1` (brightest). Default value is `0.1`.
    /// - Since: 1.4.0
    @objc var torchLevel: Float { get }
}
