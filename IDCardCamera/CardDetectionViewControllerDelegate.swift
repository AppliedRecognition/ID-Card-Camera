//
//  IDCardCameraDelegate.swift
//  IDCardCamera
//
//  Created by Jakub Dolejs on 11/12/2019.
//  Copyright © 2019 Applied Recognition Inc. All rights reserved.
//

import UIKit

/// Card detection view controller delegate
/// - Since: 1.0.0
@objc public protocol CardDetectionViewControllerDelegate: class {
    
    /// Called when card detection succeeds
    /// - Parameters:
    ///   - viewController: View controller that detected the card
    ///   - image: Image of the detected card straightened to fit the rectangle specified in settings
    ///   - settings: Card detection settings
    @objc func cardDetectionViewController(_ viewController: CardDetectionViewController, didDetectCard image: CGImage, withSettings settings: CardDetectionSettings)
    
    /// Called when card detection fails
    /// - Parameter viewController: View controller that was used for card detection
    @objc optional func cardDetectionViewControllerDidCancel(_ viewController: CardDetectionViewController)
}
