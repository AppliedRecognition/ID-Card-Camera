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
@objc public protocol CardDetectionViewControllerDelegate: AnyObject {
    
    /// Called when card detection succeeds
    /// - Parameters:
    ///   - viewController: View controller that detected the card
    ///   - image: Image of the detected card straightened to fit the rectangle specified in settings
    ///   - settings: Card detection settings
    /// - Since: 1.0.0
    @objc func cardDetectionViewController(_ viewController: CardDetectionViewController, didDetectCard image: CGImage, withSettings settings: CardDetectionSettings)
    
    /// Called when card detection is cancelled
    /// - Parameter viewController: View controller that was used for card detection
    /// - Since: 1.0.0
    @objc optional func cardDetectionViewControllerDidCancel(_ viewController: CardDetectionViewController)
    
    /// Called when an image is straightened
    ///
    /// Implement in your delegate to determine the image quality. By default the quality is determined by
    /// the sharpness of the image. However, sharpness detection is only available on iOS 13 and newer.
    /// If you wish to keep the sharpness detection and implement your own image quality scoring for iOS 12
    /// and older return `nil` on iOS 13 and your score on iOS 12 and older.
    /// - Parameter image: Image
    /// - Returns: Score representing the quality of the image (higher score is better than lower)
    /// - Since: 1.3.0
    @objc optional func qualityOfImage(_ image: CGImage) -> NSNumber?
}
