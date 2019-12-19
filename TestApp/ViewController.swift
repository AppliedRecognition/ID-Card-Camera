//
//  ViewController.swift
//  TestApp
//
//  Created by Jakub Dolejs on 12/12/2019.
//  Copyright © 2019 Applied Recognition Inc. All rights reserved.
//

import UIKit
import IDCardCamera
import Vision

class ViewController: UIViewController, CardDetectionViewControllerDelegate, BarcodeDetectionViewControllerDelegate, CardAndBarcodeDetectionViewControllerDelegate {
    
    @IBOutlet var scanButton: UIButton!
    @IBOutlet var cardImageView: UIImageView!
    
    @IBAction func startIDCardScan() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Scan front", style: .default, handler: { _ in
            let controller = CardDetectionViewController()
            controller.delegate = self
            self.present(controller, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Scan barcode", style: .default, handler: { _ in
            do {
                let settings = try BarcodeDetectionSettings(barcodeSymbologies: [.PDF417])
                let controller = BarcodeDetectionViewController(settings: settings)
                controller.delegate = self
                self.present(controller, animated: true)
            } catch {
                let alert = UIAlertController(title: "Unsupported barcode format", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            }
        }))
        alert.addAction(UIAlertAction(title: "Scan both sides", style: .default, handler: { _ in
            let settings = CardAndBarcodeDetectionSettings()
            let controller = CardAndBarcodeDetectionViewController(settings: settings)
            controller.delegate = self
            self.present(controller, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func cardDetectionViewController(_ viewController: CardDetectionViewController, didDetectCard image: CGImage, withSettings settings: CardDetectionSettings) {
        self.displayDetectedImage(image, aspectRatio: settings.size.width/settings.size.height)
    }
    
//    // Uncomment to implement your own image quality detection
//    func qualityOfImage(_ image: CGImage) -> NSNumber? {
//        if #available(iOS 13, *) {
//            // Return `nil` to use image sharpness as quality score
//            return nil
//        }
//        return NSNumber(value: 1) // Implement your own quality scoring
//    }
    
    func barcodeDetectionViewController(_ viewController: BarcodeDetectionViewController, didDetectBarcodes barcodes: [VNBarcodeObservation]) {
        self.scanButton.isHidden = false
        self.cardImageView.isHidden = true
        self.displayBarcodes(barcodes)
    }
    
    func cardAndBarcodeDetectionViewController(_ viewController: CardAndBarcodeDetectionViewController, didDetectCard image: CGImage, andBarcodes barcodes: [VNBarcodeObservation], withSettings settings: CardAndBarcodeDetectionSettings) {
        self.displayDetectedImage(image, aspectRatio: settings.cardDetectionSettings.size.width/settings.cardDetectionSettings.size.height)
        self.displayBarcodes(barcodes)
    }
    
    func displayDetectedImage(_ image: CGImage, aspectRatio: CGFloat) {
        self.scanButton.isHidden = true
        self.cardImageView.isHidden = false
        if let aspectRatioConstraint = self.cardImageView.constraints.first(where: { $0.identifier == "aspectRatio" }) {
            self.cardImageView.removeConstraint(aspectRatioConstraint)
        }
        let aspectRatioConstraint = NSLayoutConstraint(item: self.cardImageView, attribute: .width, relatedBy: .equal, toItem: self.cardImageView, attribute: .height, multiplier: aspectRatio, constant: 0)
        aspectRatioConstraint.identifier = "aspectRatio"
        self.cardImageView.addConstraint(aspectRatioConstraint)
        let uiImage = UIImage(cgImage: image)
        self.cardImageView.image = uiImage
    }
    
    func displayBarcodes(_ barcodes: [VNBarcodeObservation]) {
        guard let barcode = barcodes.first?.payloadStringValue else {
            return
        }
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Barcode", message: barcode, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
    }
}

