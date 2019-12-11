//
//  CardDetectionSettings.swift
//  IDCardCamera
//
//  Created by Jakub Dolejs on 11/12/2019.
//  Copyright © 2019 Applied Recognition Inc. All rights reserved.
//

import UIKit

@objc public class CardDetectionSettings: NSObject {
    
    @objc public enum Orientation: Int {
        case landscape, portrait
    }
    
    @objc public var size: CGSize
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
    
    @objc public init(width: CGFloat, height: CGFloat) {
        self.size = CGSize(width: width, height: height)
    }
}
