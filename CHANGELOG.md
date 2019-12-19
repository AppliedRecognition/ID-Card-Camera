# Change log

## 1.4.0
 - Added scanning of barcodes on the back of the ID card

## 1.3.1
 - Fixed a bug where the whole unstraightened image was being passed to the delegate for quality detection

## 1.3.0
 - Added optional delegate method to allow the delegate to determine the quality of the detected images

## 1.2.1
 - Make the size of the corners of the card template consistent in landscape and portrait orientations
 - Ensure card template isn't cut off when the device is in landscape orientation

## 1.2.0
 - Added torch level setting (default is too strong for scanning cards at close range)

## 1.1.0
 - Collect a pool of images instead of just one and return the best (sharpest) image

## 1.0.1
 - Added sample app target in the Xcode project