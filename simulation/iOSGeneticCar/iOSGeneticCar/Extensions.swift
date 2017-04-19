//
//  Extensions.swift
//  iOSGeneticCar
//
//  Created by Andrew Liakh on 4/11/17.
//  Copyright © 2017 Andrew Liakh. All rights reserved.
//

import UIKit

extension UIImage {
    func crop(rect: CGRect) -> UIImage {
        var rect = rect
        rect.origin.x*=self.scale
        rect.origin.y*=self.scale
        rect.size.width*=self.scale
        rect.size.height*=self.scale
        
        let imageRef = self.cgImage!.cropping(to: rect)
        let image = UIImage(cgImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
        return image
    }
    
    func rotatedByDegrees(deg degrees: CGFloat) -> UIImage {
        //Calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let t: CGAffineTransform = CGAffineTransform(rotationAngle: degrees * CGFloat(Double.pi / 180))
        rotatedViewBox.transform = t
        let rotatedSize: CGSize = rotatedViewBox.frame.size
        //Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap: CGContext = UIGraphicsGetCurrentContext()!
        //Move the origin to the middle of the image so we will rotate and scale around the center.
        bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        //Rotate the image context
        bitmap.rotate(by: (degrees * CGFloat(Double.pi / 180)))
        //Now, draw the rotated/scaled image into the context
        bitmap.scaleBy(x: 1.0, y: -1.0)
//        bitmap.setFillColor(UIColor.green.cgColor)
//        bitmap.fill(CGRect(x: 0, y: 0, width: self.size.width * 2, height: self.size.height * 2))
        bitmap.draw(self.cgImage!, in: CGRect(x: -self.size.width / 2, y: -self.size.height / 2, width: self.size.width, height: self.size.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func pixelData() -> [UInt8]? {
        let size = self.size
        let dataSize = size.width * size.height * 4
        var pixelData = [UInt8](repeating: 0, count: Int(dataSize))
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: &pixelData,
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: 8,
                                bytesPerRow: 4 * Int(size.width),
                                space: colorSpace,
                                bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
        guard let cgImage = self.cgImage else { return nil }
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        return pixelData
    }
    
    func firstWhitePixel() -> CGPoint? {
        let width = Int(self.size.width)
        let height = Int(self.size.height)
        if let cfData = self.cgImage?.dataProvider?.data, let pointer = CFDataGetBytePtr(cfData) {
            for y in 0..<height {
                for x in 0..<width {
                    let pixelAddress = x * 4 + y * (width - 1) * 4
                    if pointer.advanced(by: pixelAddress).pointee == UInt8.max &&     //Red
                        pointer.advanced(by: pixelAddress + 1).pointee == UInt8.max && //Green
                        pointer.advanced(by: pixelAddress + 2).pointee == UInt8.max && //Blue
                        pointer.advanced(by: pixelAddress + 3).pointee == UInt8.max  {  //Alpha
                        return CGPoint(x: x, y: y)
                    }
                }
            }
        }
        return nil
    }
    
    func whitePixelAtTheBottom() -> CGPoint? {
        let width = Int(self.size.width)
        let height = Int(self.size.height)
        if let cfData = self.cgImage?.dataProvider?.data, let pointer = CFDataGetBytePtr(cfData) {
            for y in 0..<height {
                for x in 0..<width {
                    let reverseY = height - y - 2
                    let pixelAddress = x * 4 + reverseY * width * 4
                    if pointer.advanced(by: pixelAddress).pointee == UInt8.max &&     //Red
                        pointer.advanced(by: pixelAddress + 1).pointee == UInt8.max && //Green
                        pointer.advanced(by: pixelAddress + 2).pointee == UInt8.max && //Blue
                        pointer.advanced(by: pixelAddress + 3).pointee == UInt8.max  {  //Alpha
                        print("width: \(width) y: \(reverseY)")
                        return CGPoint(x: x, y: reverseY)
                    }
                }
            }
        }
        return nil
    }
}

extension UIView {
    func takeSnapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
