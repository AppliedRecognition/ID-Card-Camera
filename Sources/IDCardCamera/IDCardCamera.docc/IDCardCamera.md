# ``IDCardCamera``

Capture photo page and barcode of ID cards on iOS

## Overview

- Detects an ID card in a camera view and returns the de-warped image of the ID card.
- Scans PDF417 barcode on the back side of an ID card.

### Example Usage

```swift
import UIKit
import IDCardCamera

class ViewController: UIViewController, CardDetectionViewControllerDelegate {

    @IBOutlet var imageView: UIImageView!

    func scanIDCard() {
        // Set the scan settings
        // In this example the aspect ratio is that of a typical credit card
        // The width and height units are not important
        let settings = CardDetectionSettings(width: 85.6, height: 53.98)

        // Create the view controller
        let controller = CardDetectionViewController()

        // Set the delegate that will receive the result
        controller.delegate = self

        // Present the card detection view controller
        self.present(controller, animated: true, completion: nil)
    }

    func cardDetectionViewController(_ viewController: CardDetectionViewController, didDetectCard image: CGImage, withSettings settings: CardDetectionSettings) {
        // The card has been scanned
        // Display the image in the image view
        self.imageView.image = UIImage(cgImage: image)
    }
}
```

## Topics

### Capturing ID Card Photo Page

- ``CardDetectionViewController``
- ``CardDetectionSettings``
- ``CardDetectionViewControllerDelegate``

### Capturing ID Card Barcode

- ``BarcodeDetectionViewController``
- ``BarcodeDetectionSettings``
- ``BarcodeDetectionViewControllerDelegate``
- ``BarcodeDetectionSettingsError``

### Capturing Both Sides of ID Card

- ``CardAndBarcodeDetectionViewController``
- ``CardAndBarcodeDetectionSettings``
- ``CardAndBarcodeDetectionViewControllerDelegate``
