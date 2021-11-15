//
//  CardAndBarcodeDetectionViewController.swift
//  IDCardCamera
//
//  Created by Jakub Dolejs on 19/12/2019.
//  Copyright © 2019 Applied Recognition Inc. All rights reserved.
//

import UIKit
import Vision

/// View controller that scans both front and back of the card
/// - Since: 1.4.0
@objc public class CardAndBarcodeDetectionViewController: BaseCardDetectionViewController {
    
    private var cardImage: CGImage?
    private var barcodes: [VNBarcodeObservation]?
    
    /// Detection delegate
    /// - Since: 1.4.0
    @objc public weak var delegate: CardAndBarcodeDetectionViewControllerDelegate?
    /// Detection settings
    /// - Since: 1.4.0
    @objc public let settings: CardAndBarcodeDetectionSettings
    
    /// Initializer
    /// - Parameter settings: Detection settings
    /// - Since: 1.4.0
    @objc public init(settings: CardAndBarcodeDetectionSettings) {
        self.settings = settings
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didCropImageToImage(_ image: CGImage) {
        self.cardImage = image
        DispatchQueue.main.async {
            self.navigationBar.topItem?.prompt = "Scan the barcode on the back of your ID card"
            self.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(title: "Skip", style: .plain, target: self, action: #selector(self.finish))
            let imageView = UIImageView(frame: self.cardOverlayView.frame)
            imageView.contentMode = .scaleAspectFill
            imageView.image = UIImage(cgImage: image)
            imageView.layer.masksToBounds = true
            imageView.layer.cornerRadius = 20
            let cardLayer = CATransformLayer()
            cardLayer.frame = self.view.bounds
            var perspective = CATransform3DIdentity
            perspective.m34 = -1 / 500
            cardLayer.transform = perspective
            cardLayer.addSublayer(imageView.layer)
            let cardView = UIView(frame: self.view.bounds)
            cardView.layer.addSublayer(cardLayer)
            self.flipCardView.isHidden = false
            self.view.insertSubview(cardView, belowSubview: self.flipCardView)
            self.cardOverlayView.isHidden = true
            
            UIView.animate(withDuration: 1.0, animations: { [weak imageView] in
                imageView?.layer.transform = CATransform3DMakeRotation(CGFloat.pi, 0, 1, 0)
            }, completion: { [weak cardView] completed in
                cardView?.removeFromSuperview()
            })
            UIView.animate(withDuration: 0.5, delay: 1.0, options: .curveEaseOut, animations: { [weak self] in
                self?.flipCardView.alpha = 0.0
            }, completion: { [weak self] completed in
                self?.flipCardView.isHidden = true
                self?.flipCardView.alpha = 1.0
            })
        }
    }
    
    override var cardAspectRatio: CGFloat {
        return self.settings.cardDetectionSettings.size.width / self.settings.cardDetectionSettings.size.height
    }
    
    override func flipCardOrientation() {
        if self.settings.cardDetectionSettings.orientation == .landscape {
            self.settings.cardDetectionSettings.orientation = .portrait
        } else {
            self.settings.cardDetectionSettings.orientation = .landscape
        }
    }
    
    override var imagePoolSize: Int {
        return self.settings.cardDetectionSettings.imagePoolSize
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.sessionHandler.torchSettings = self.settings
        self.sessionHandler.cardDetectionSettings = self.settings.cardDetectionSettings
        self.sessionHandler.barcodeDetectionSettings = self.settings.barcodeDetectionSettings
    }
    
    override func sessionHandler(_ handler: ObjectDetectionSessionHandler, didDetectBarcodes barcodes: [VNBarcodeObservation]) {
        self.barcodes = barcodes
        DispatchQueue.main.async {
            self.finish()
        }
    }
    
    override func shouldDetectCardImageWithSessionHandler(_ handler: ObjectDetectionSessionHandler) -> Bool {
        return super.shouldDetectCardImageWithSessionHandler(handler) && self.cardImage == nil
    }
    
    override func shouldDetectBarcodeWithSessionHandler(_ handler: ObjectDetectionSessionHandler) -> Bool {
        return self.cardImage != nil && self.barcodes == nil
    }
    
    @objc func finish() {
        if let image = self.cardImage {
            let barcodes = self.barcodes ?? []
            self.delegate?.cardAndBarcodeDetectionViewController(self, didDetectCard: image, andBarcodes: barcodes, withSettings: self.settings)
            self.delegate = nil
        }
        self.dismiss()
    }
}
