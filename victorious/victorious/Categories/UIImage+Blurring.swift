//
//  UIImage+Blurring.swift
//  victorious
//
//  Created by Tian Lan on 6/10/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

extension UIImage {
    func applyBlur(withRadius radius: CGFloat, in bounds: CGRect) -> UIImage? {
        guard let blurFilter = CIFilter(name: "CIGaussianBlur") else {
            return nil
        }
        
        blurFilter.setValue(CoreImage.CIImage(image: self), forKey: kCIInputImageKey)
        blurFilter.setValue(radius, forKey: kCIInputRadiusKey)
        
        let ciContext  = CIContext(options: nil)
        
        guard let result = blurFilter.valueForKey(kCIOutputImageKey) as? CoreImage.CIImage else {
            return nil
        }
        
        let cgImage = ciContext.createCGImage(result, fromRect: bounds)
        
        return UIImage(CGImage: cgImage)
    }
}
