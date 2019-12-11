//
//  IDCardCameraDelegate.swift
//  IDCardCamera
//
//  Created by Jakub Dolejs on 11/12/2019.
//  Copyright © 2019 Applied Recognition Inc. All rights reserved.
//

import UIKit

@objc public protocol CardDetectionViewControllerDelegate: class {
    
    @objc func cardDetectionViewController(_ viewController: CardDetectionViewController, didDetectCard image: CGImage, withSettings settings: CardDetectionSettings)
    
    @objc optional func cardDetectionViewControllerDidCancel(_ viewController: CardDetectionViewController)
}
