//
//  BundleHelper.swift
//  IDCardCamera
//
//  Created by Jakub Dolejs on 15/11/2021.
//  Copyright © 2021 Applied Recognition Inc. All rights reserved.
//

import Foundation

class BundleHelper {
    
    static var moduleBundle: Bundle? {
        guard let url = Bundle(for: BundleHelper.self).url(forResource: "IDCardCameraResources", withExtension: "bundle"), let idCamBundle = Bundle(url: url) else {
            return nil
        }
        return idCamBundle
    }
}
