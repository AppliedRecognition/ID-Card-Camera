# ``IDCardCamera``

Uses the camera to capture ID cards.

## Overview

### Installation 

#### Using [CocoaPods](https://cocoapods.org/)

Add the following pod in your **Podfile** and run `pod install`.

```ruby
pod 'ID-Card-Camera', '~> 1.0'
```

#### Using [Swift Package Manager](https://www.swift.org/package-manager/)

- In Xcode select **File -> Add Packages ...** from the top menu. 
- Enter `https://github.com/AppliedRecognition/ID-Card-Camera.git` in the search bar.
- Click the **Add Package** button.

### Usage

```swift
import UIKit
import IDCardCamera
s
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

### Capturing Both Sides of ID Card

- ``CardAndBarcodeDetectionViewController``
- ``CardAndBarcodeDetectionSettings``
- ``CardAndBarcodeDetectionViewControllerDelegate``
