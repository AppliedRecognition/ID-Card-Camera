//
//  VerID+CMSampleBuffer.swift
//  VerIDIDCapture
//
//  Created by Jakub Dolejs on 03/01/2018.
//  Copyright © 2018 Applied Recognition, Inc. All rights reserved.
//

import UIKit
import Accelerate
import CoreMedia

extension CVImageBuffer {
    
    public func cgImage(withOrientation orientation: CGImagePropertyOrientation) -> CGImage? {
        // Lock the pixels before adjusting rotation
        CVPixelBufferLockBaseAddress(self, [])
        // Get the vImage rotation constant based on the UI orientation
        let rotation: UInt8
        switch orientation {
        case .right, .rightMirrored:
            rotation = 3
        case .up, .upMirrored:
            rotation = 0
        case .left, .leftMirrored:
            rotation = 1
        case .down, .downMirrored:
            rotation = 2
        }
        // Get the image width, height and bytes per row
        let bytesPerRow: Int = CVPixelBufferGetBytesPerRow(self)
        let width: UInt = UInt(CVPixelBufferGetWidth(self))
        let height: UInt = UInt(CVPixelBufferGetHeight(self))
        
        let outWidth: UInt
        let outHeight: UInt
        // Flip width and height if the image is rotated 90 or 270 degrees
        if rotation == 1 || rotation == 3 {
            outWidth = height
            outHeight = width
        } else {
            outWidth = width
            outHeight = height
        }
        // Set the bytes per row for the rotated image
        let outBytesPerRow: Int = 4 * Int(outWidth)
        // Calculate the size of the rotated image buffer
        let destSize = outBytesPerRow * Int(outHeight) * MemoryLayout<UInt8>.size
        // Get the pixel bytes
        guard let srcBuff = CVPixelBufferGetBaseAddress(self) else {
            return nil
        }
        // Allocate the rotated image buffer
        var dstBuff: [UInt8] = [UInt8](repeating: 0, count: destSize)
        // Create the input vImage buffer
        var inBuff = vImage_Buffer(data: srcBuff, height: height, width: width, rowBytes: bytesPerRow)
        // Create the output vImage buffer
        var outBuff = vImage_Buffer(data: &dstBuff, height: outHeight, width: outWidth, rowBytes: outBytesPerRow)
        // Set the background colour to black
        var bg: UInt8 = 0
        // Rotate the image using the Accelerate framework (very fast)
        var err = vImageRotate90_ARGB8888(&inBuff, &outBuff, rotation, &bg, UInt32(0))
        if err != kvImageNoError {
            return nil
        }
        // Unlock the pixels
        CVPixelBufferUnlockBaseAddress(self, [])
        
        // Set the CGImage format
        // This format mirrors the image format descriptors used by CoreGraphics to create things like CGImageRef and CGBitmapContextRef.
        let colorSpace = Unmanaged.passRetained(CGColorSpaceCreateDeviceRGB())
        var format = vImage_CGImageFormat(bitsPerComponent: 8, bitsPerPixel: 32, colorSpace: colorSpace, bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue).union(.byteOrder32Little), version: 0, decode: nil, renderingIntent: CGColorRenderingIntent.defaultIntent)
        // Create a CGImage from the rotated pixel buffer
        return vImageCreateCGImageFromBuffer(&outBuff, &format, nil, nil, numericCast(kvImageNoFlags), &err)?.takeRetainedValue()
    }
}

extension CMSampleBuffer {
    
    public func cgImage(withOrientation orientation: CGImagePropertyOrientation) -> CGImage? {
        // Get the pixels from the sample buffer
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(self) else {
            return nil
        }
        return pixelBuffer.cgImage(withOrientation: orientation)
    }
}
