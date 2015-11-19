//
//  FilteredImageView.swift
//  victorious
//
//  Created by Michael Sena on 11/17/15.
//  Copyright © 2015 Victorious. All rights reserved.
//


import UIKit
import CoreImage
import GLKit
import OpenGLES

@objc(VFilteredImageView)
class FilteredImageView: GLKView {
    
    var filter: VPhotoFilter? {
        didSet {
            setNeedsDisplay()
        }
    }
    var inputImage: UIImage? {
        didSet {
            if let inputImage = inputImage {
                self.scaledImage = inputImage.fixOrientation().scaledImageWithMaxDimension(300.0)
            }
        }
    }
    private var scaledImage: UIImage? {
        didSet {
            // Get rid of the original image we no longer need it
            inputImage = nil
            setNeedsDisplay()
        }
    }
    private var ciContext: CIContext!
    
    //MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame, context: EAGLContext(API: .OpenGLES2))
        clipsToBounds = true
        self.ciContext = CIContext(EAGLContext: context, options: [kCIContextWorkingColorSpace: NSNull()])
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        clipsToBounds = true
        context = EAGLContext(API: .OpenGLES2)
        ciContext = CIContext(EAGLContext: context)
    }
    
    //MARK: - UIView
    
    override func drawRect(rect: CGRect) {
        if let scaledImage = scaledImage {
            if let filter = filter {
                let inputCIImage = CIImage(image: scaledImage)?.imageByApplyingOrientation(scaledImage.imageOrientation.tiffOrientation())
                if let outputImage = filter.filteredImageWithInputImage(inputCIImage) {
                    drawCIImage(outputImage)
                }
            } else {
                drawCIImage(CIImage(image: scaledImage)!.imageByApplyingOrientation(scaledImage.imageOrientation.tiffOrientation()))
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setNeedsDisplay()
    }
    
    // MARK: - Private
    
    private func clearBackground() {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        backgroundColor?.getRed(&r, green: &g, blue: &b, alpha: &a)
        glClearColor(GLfloat(r), GLfloat(g), GLfloat(b), GLfloat(a))
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
    }
    
    private func drawCIImage(image: CIImage) {
        EAGLContext.setCurrentContext(self.context)
        
        clearBackground()

        // Draw visible rect
        let inputBounds = image.extent
        let drawableBounds = CGRect(x: 0, y: 0, width: drawableWidth, height: drawableHeight)
        let targetBounds = imageBoundsForContentMode(inputBounds, toRect: drawableBounds)
        ciContext.drawImage(image, inRect: targetBounds, fromRect: inputBounds)
        
        print("drawable bounds: \(drawableBounds), targetBounds: \(targetBounds)")
    }
    
    private func imageBoundsForContentMode(fromRect: CGRect, toRect: CGRect) -> CGRect {
        switch contentMode {
        case .ScaleAspectFill:
            return aspectFill(fromRect, toRect: toRect)
        case .ScaleAspectFit:
            return aspectFit(fromRect, toRect: toRect)
        default:
            return fromRect
        }
    }
    
    private func aspectFit(fromRect: CGRect, toRect: CGRect) -> CGRect {
        let fromAspectRatio = fromRect.size.width / fromRect.size.height;
        let toAspectRatio = toRect.size.width / toRect.size.height;
        
        var fitRect = toRect
        
        if (fromAspectRatio > toAspectRatio) {
            fitRect.size.height = toRect.size.width / fromAspectRatio;
            fitRect.origin.y += (toRect.size.height - fitRect.size.height) * 0.5;
        } else {
            fitRect.size.width = toRect.size.height  * fromAspectRatio;
            fitRect.origin.x += (toRect.size.width - fitRect.size.width) * 0.5;
        }
        
        return CGRectIntegral(fitRect)
    }
    
    private func aspectFill(fromRect: CGRect, toRect: CGRect) -> CGRect {
        let fromAspectRatio = fromRect.size.width / fromRect.size.height;
        let toAspectRatio = toRect.size.width / toRect.size.height;
        
        var fitRect = toRect
        
        if (fromAspectRatio > toAspectRatio) {
            fitRect.size.width = toRect.size.height  * fromAspectRatio;
            fitRect.origin.x += (toRect.size.width - fitRect.size.width) * 0.5;
        } else {
            fitRect.size.height = toRect.size.width / fromAspectRatio;
            fitRect.origin.y += (toRect.size.height - fitRect.size.height) * 0.5;
        }
        
        return CGRectIntegral(fitRect)
    }
    
}
