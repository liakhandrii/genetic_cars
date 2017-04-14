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
        let t: CGAffineTransform = CGAffineTransform(rotationAngle: degrees * CGFloat(M_PI / 180))
        rotatedViewBox.transform = t
        let rotatedSize: CGSize = rotatedViewBox.frame.size
        //Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap: CGContext = UIGraphicsGetCurrentContext()!
        //Move the origin to the middle of the image so we will rotate and scale around the center.
        bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        //Rotate the image context
        bitmap.rotate(by: (degrees * CGFloat(M_PI / 180)))
        //Now, draw the rotated/scaled image into the context
        bitmap.scaleBy(x: 1.0, y: -1.0)
        bitmap.draw(self.cgImage!, in: CGRect(x: -self.size.width / 2, y: -self.size.height / 2, width: self.size.width, height: self.size.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func firstWhitePixel() -> CGPoint? {
        let width = Int(self.size.width)
        let height = Int(self.size.height)
        if let cfData = self.cgImage?.dataProvider?.data, let pointer = CFDataGetBytePtr(cfData) {
            for y in 0..<height {
                for x in 0..<width {
                    let pixelAddress = x * 4 + y * width * 4
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
                    let reverseY = height - y - 1
                    let pixelAddress = x * 4 + reverseY * width * 4
                    if pointer.advanced(by: pixelAddress).pointee == UInt8.max &&     //Red
                        pointer.advanced(by: pixelAddress + 1).pointee == UInt8.max && //Green
                        pointer.advanced(by: pixelAddress + 2).pointee == UInt8.max && //Blue
                        pointer.advanced(by: pixelAddress + 3).pointee == UInt8.max  {  //Alpha
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
