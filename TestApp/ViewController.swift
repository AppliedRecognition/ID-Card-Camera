//
//  ViewController.swift
//  TestApp
//
//  Created by Jakub Dolejs on 12/12/2019.
//  Copyright © 2019 Applied Recognition Inc. All rights reserved.
//

import UIKit
import IDCardCamera

class ViewController: UIViewController, CardDetectionViewControllerDelegate {
    
    @IBOutlet var scanButton: UIButton!
    @IBOutlet var cardImageView: UIImageView!
    
    @IBAction func startIDCardScan() {
        let controller = CardDetectionViewController()
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
    }
    
    func cardDetectionViewController(_ viewController: CardDetectionViewController, didDetectCard image: CGImage, withSettings settings: CardDetectionSettings) {
        self.scanButton.isHidden = true
        self.cardImageView.isHidden = false
        if let aspectRatioConstraint = self.cardImageView.constraints.first(where: { $0.identifier == "aspectRatio" }) {
            self.cardImageView.removeConstraint(aspectRatioConstraint)
        }
        let aspectRatioConstraint = NSLayoutConstraint(item: self.cardImageView, attribute: .width, relatedBy: .equal, toItem: self.cardImageView, attribute: .height, multiplier: settings.size.width/settings.size.height, constant: 0)
        aspectRatioConstraint.identifier = "aspectRatio"
        self.cardImageView.addConstraint(aspectRatioConstraint)
        let uiImage = UIImage(cgImage: image)
        self.cardImageView.image = uiImage
    }
    
//    // Uncomment to implement your own image quality detection
//    func qualityOfImage(_ image: CGImage) -> NSNumber? {
//        if #available(iOS 13, *) {
//            // Return `nil` to use image sharpness as quality score
//            return nil
//        }
//        return NSNumber(value: 1) // Implement your own quality scoring
//    }
}

