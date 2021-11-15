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
import AAMVABarcodeParser

class ViewController: UIViewController, CardDetectionViewControllerDelegate, BarcodeDetectionViewControllerDelegate, CardAndBarcodeDetectionViewControllerDelegate {
    
    // MARK: - UI outlets and actions
    
    @IBOutlet var photoPageSwitch: UISwitch!
    @IBOutlet var barcodeSwitch: UISwitch!
    @IBOutlet var captureButton: UIButton!
    
    @IBAction func didToggleSwitch(_ switch: UISwitch) {
        self.captureButton.isEnabled = self.photoPageSwitch.isOn || self.barcodeSwitch.isOn
    }
    
    @IBAction func captureIDCard() {
        if self.photoPageSwitch.isOn && self.barcodeSwitch.isOn {
            self.captureBothSides()
        } else if self.photoPageSwitch.isOn {
            self.capturePhotoPage()
        } else if self.barcodeSwitch.isOn {
            self.captureBarcode()
        }
    }
    
    // MARK: - Capture functions
    
    func capturePhotoPage() {
        let controller = CardDetectionViewController()
        controller.delegate = self
        self.present(controller, animated: true)
    }
    
    func captureBarcode() {
        let settings = try! BarcodeDetectionSettings(barcodeSymbologies: [.pdf417])
        let controller = BarcodeDetectionViewController(settings: settings)
        controller.delegate = self
        self.present(controller, animated: true)
    }
    
    func captureBothSides() {
        let settings = CardAndBarcodeDetectionSettings()
        let controller = CardAndBarcodeDetectionViewController(settings: settings)
        controller.delegate = self
        self.present(controller, animated: true)
    }
    
    // MARK: - CardDetectionViewControllerDelegate
    
    func cardDetectionViewController(_ viewController: CardDetectionViewController, didDetectCard image: CGImage, withSettings settings: CardDetectionSettings) {
        self.performSegue(withIdentifier: "result", sender: (UIImage(cgImage: image),settings.size.width/settings.size.height))
    }
    
//    // Uncomment to implement your own image quality detection
//    func qualityOfImage(_ image: CGImage) -> NSNumber? {
//        if #available(iOS 13, *) {
//            // Return `nil` to use image sharpness as quality score
//            return nil
//        }
//        return NSNumber(value: 1) // Implement your own quality scoring
//    }
    
    // MARK: - BarcodeDetectionViewControllerDelegate
    
    func barcodeDetectionViewController(_ viewController: BarcodeDetectionViewController, didDetectBarcodes barcodes: [VNBarcodeObservation]) {
        guard let docData = try? self.parseBarcode(from: barcodes) else {
            return
        }
        self.performSegue(withIdentifier: "result", sender: docData)
    }
    
    // MARK: - CardAndBarcodeDetectionViewControllerDelegate
    
    func cardAndBarcodeDetectionViewController(_ viewController: CardAndBarcodeDetectionViewController, didDetectCard image: CGImage, andBarcodes barcodes: [VNBarcodeObservation], withSettings settings: CardAndBarcodeDetectionSettings) {
        let collectedData: Any
        if let docData = try? self.parseBarcode(from: barcodes) {
            collectedData = (UIImage(cgImage: image),settings.cardDetectionSettings.size.width/settings.cardDetectionSettings.size.height,docData)
        } else {
            collectedData = (UIImage(cgImage: image),settings.cardDetectionSettings.size.width/settings.cardDetectionSettings.size.height)
        }
        self.performSegue(withIdentifier: "result", sender: collectedData)
    }
    
    // MARK: - Barcode parsing
    
    let barcodeParser = AAMVABarcodeParser()
    
    func parseBarcode(from barcodes: [VNBarcodeObservation]) throws -> DocumentData {
        guard let barcode = barcodes.first?.payloadStringValue?.data(using: .utf8) else {
            throw BarcodeParserError.parseError
        }
        return try self.barcodeParser.parseData(barcode)
    }
    
    // MARK: -
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let target = segue.destination as? ResultViewController {
            if let (image, aspectRatio, docData) = sender as? (UIImage,CGFloat,DocumentData) {
                target.documentProperties = docData.entries
                target.imageAspectRatio = aspectRatio
                target.documentImage = image
            } else if let docData = sender as? DocumentData {
                target.documentProperties = docData.entries
            } else if let (image, aspectRatio) = sender as? (UIImage,CGFloat) {
                target.documentImage = image
                target.imageAspectRatio = aspectRatio
            }
        }
    }
}

