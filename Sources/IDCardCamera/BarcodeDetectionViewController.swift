//
//  BarcodeDetectionViewController.swift
//  VerIDIDCapture
//
//  Created by Jakub Dolejs on 02/01/2018.
//  Copyright © 2018 Applied Recognition, Inc. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

/// Barcode detection view controller
/// - Since: 1.4.0
public class BarcodeDetectionViewController: ObjectDetectionViewController {
    
    /// Barcode detection view controller delegate
    /// - Since: 1.4.0
    @objc public weak var delegate: BarcodeDetectionViewControllerDelegate?
    
    /// Barcode detection settings
    /// - Since: 1.4.0
    @objc public let settings: BarcodeDetectionSettings
    
    /// Initializer
    /// - Parameter settings: Barcode detection settings
    /// - Since: 1.4.0
    @objc public init(settings: BarcodeDetectionSettings) {
        self.settings = settings
        super.init(nibName: "BarcodeDetectionViewController", bundle: Bundle.module)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.sessionHandler.torchSettings = self.settings
        self.sessionHandler.barcodeDetectionSettings = self.settings
    }
    
    override func sessionHandler(_ handler: ObjectDetectionSessionHandler, didDetectBarcodes barcodes: [VNBarcodeObservation]) {
        self.sessionHandler.delegate = nil
        DispatchQueue.main.async {
            guard self.isViewLoaded else {
                return
            }
            self.dismiss()
            self.delegate?.barcodeDetectionViewController(self, didDetectBarcodes: barcodes)
            self.delegate = nil
        }
    }
    
    override func shouldDetectBarcodeWithSessionHandler(_ handler: ObjectDetectionSessionHandler) -> Bool {
        return true
    }
    
    @IBAction override func cancel() {
        super.cancel()
        self.delegateCancel()
    }
    
    public override func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        self.delegateCancel()
    }
    
    private func delegateCancel() {
        self.delegate?.barcodeDetectionViewControllerDidCancel?(self)
        self.delegate = nil
    }
}
