![Cocoapods](https://img.shields.io/cocoapods/v/ID-Card-Camera.svg)

# ID Card Camera

Detects an ID card in a camera view and returns the de-warped image of the ID card.

## Installation using [CocoaPods](https://cocoapods.org/)

Add the following pod in your **Podfile** and run `pod install`.

~~~ruby
pod 'ID-Card-Camera', '~> 1.0'
~~~

## Usage

~~~swift
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
~~~

## [API documentation](https://appliedrecognition.github.io/ID-Card-Camera/)

## [Change log](./CHANGELOG.md)
