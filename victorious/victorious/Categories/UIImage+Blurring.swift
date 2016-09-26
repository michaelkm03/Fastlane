//
//  UIImage+Blurring.swift
//  victorious
//
//  Created by Tian Lan on 6/10/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

let sharedCIContext = CIContext(options: nil)

extension UIImage {
    func applyBlur(withRadius radius: CGFloat) -> UIImage? {
        guard
            let blurFilter = CIFilter(name: "CIGaussianBlur"),
            let inputImage = CoreImage.CIImage(image: self)
        else {
            return nil
        }
        
        blurFilter.setValue(inputImage, forKey: kCIInputImageKey)
        blurFilter.setValue(radius, forKey: kCIInputRadiusKey)
        
        guard let result = blurFilter.outputImage, let cgImage = sharedCIContext.createCGImage(result, fromRect: inputImage.extent) else {
            return nil
        }

        return UIImage(CGImage: cgImage)
    }
}
