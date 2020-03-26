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
    
    @available(iOS 13.0, *)
    public func sharpness() -> Float? {
        CVPixelBufferLockBaseAddress(self, [])
        guard let srcBuff = CVPixelBufferGetBaseAddress(self) else {
            return nil
        }
        let bytesPerRow: Int = CVPixelBufferGetBytesPerRow(self)
        let width: UInt = UInt(CVPixelBufferGetWidth(self))
        let height: UInt = UInt(CVPixelBufferGetHeight(self))
        let outBytesPerRow: Int = bytesPerRow / 4
        // Calculate the size of the rotated image buffer
        let destSize = outBytesPerRow * Int(height) * MemoryLayout<UInt8>.size
        let ptr = UnsafeMutablePointer<UInt8>.allocate(capacity: destSize)
        defer {
            ptr.deallocate()
        }
        var planar8Buffer = vImage_Buffer(data: ptr, height: height, width: width, rowBytes: outBytesPerRow)
        var argbBuffer = vImage_Buffer(data: srcBuff, height: height, width: width, rowBytes: bytesPerRow)
        let divisor: Float = 256
        let a: Int16 = 0
        let r = Int16(0.299*divisor)
        let g = Int16(0.587*divisor)
        let b = Int16(0.114*divisor)
        let format = CVPixelBufferGetPixelFormatType(self)
        var matrix: [Int16]
        switch format {
        case kCVPixelFormatType_32ARGB:
            matrix = [a,r,g,b]
        case kCVPixelFormatType_32ABGR:
            matrix = [a,b,g,r]
        case kCVPixelFormatType_32BGRA, kCVPixelFormatType_24BGR:
            matrix = [b,g,r,a]
        case kCVPixelFormatType_32RGBA, kCVPixelFormatType_24RGB:
            matrix = [r,g,b,a]
        default:
            return nil
        }
        guard vImageMatrixMultiply_ARGB8888ToPlanar8(&argbBuffer, &planar8Buffer, &matrix, Int32(divisor), nil, 0, numericCast(kvImageNoFlags)) == kvImageNoError else {
            return nil
        }
        var floatPixels: [Float] = [Float](unsafeUninitializedCapacity: destSize) { buffer, initializedCount in
            var floatBuffer = vImage_Buffer(data: buffer.baseAddress, height: planar8Buffer.height, width: planar8Buffer.width, rowBytes: outBytesPerRow * MemoryLayout<Float>.size)
            vImageConvert_Planar8toPlanarF(&planar8Buffer, &floatBuffer, 0, 255, vImage_Flags(kvImageNoFlags))
            initializedCount = destSize
        }
        let laplacian: [Float] = [-1, -1, -1,
                                  -1,  8, -1,
                                  -1, -1, -1]
        vDSP.convolve(floatPixels, rowCount: Int(height), columnCount: outBytesPerRow, with3x3Kernel: laplacian, result: &floatPixels)
        var mean = Float.nan
        var stdDev = Float.nan

        vDSP_normalize(floatPixels, 1, nil, 1, &mean, &stdDev, vDSP_Length(floatPixels.count))
        CVPixelBufferUnlockBaseAddress(self, [])
        return stdDev
    }
    
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
        let dstBuff = UnsafeMutablePointer<UInt8>.allocate(capacity: destSize)
        defer {
            dstBuff.deallocate()
        }
        // Create the input vImage buffer
        var inBuff = vImage_Buffer(data: srcBuff, height: height, width: width, rowBytes: bytesPerRow)
        // Create the output vImage buffer
        var outBuff = vImage_Buffer(data: dstBuff, height: outHeight, width: outWidth, rowBytes: outBytesPerRow)
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
