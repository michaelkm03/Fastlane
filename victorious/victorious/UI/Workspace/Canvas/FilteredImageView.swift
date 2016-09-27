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
    
    let glContext = EAGLContext(api: .openGLES2)
    
    var filter: VPhotoFilter? {
        didSet {
            setNeedsDisplay()
        }
    }
    var inputImage: UIImage? {
        didSet {
            if let inputImage = inputImage {
                self.scaledImage = inputImage.fixOrientation().scaledImage(withMaxDimension: 300.0, upScaling: false)
            }
        }
    }
    fileprivate var scaledImage: UIImage? {
        didSet {
            // Get rid of the original image we no longer need it
            inputImage = nil
            setNeedsDisplay()
        }
    }
    fileprivate var ciContext: CIContext!
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame, context: glContext!)
        sharedSetup(context)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        context = glContext!
        sharedSetup(context)
    }
            
    fileprivate func sharedSetup(_ context: EAGLContext) {
        clipsToBounds = true
        ciContext = CIContext(eaglContext: context, options: [kCIContextWorkingColorSpace: NSNull()])
    }
    
    // MARK: - UIView
    
    override func draw(_ rect: CGRect) {
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
    
    // MARK: - Private
    
    fileprivate func clearBackground() {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        backgroundColor?.getRed(&r, green: &g, blue: &b, alpha: &a)
        glClearColor(GLfloat(r), GLfloat(g), GLfloat(b), GLfloat(a))
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
    }
    
    fileprivate func drawCIImage(_ image: CIImage) {
        clearBackground()

        // Draw visible rect
        let inputBounds = image.extent
        let drawableBounds = CGRect(x: 0, y: 0, width: drawableWidth, height: drawableHeight)
        let targetBounds = imageBoundsForContentMode(inputBounds, toRect: drawableBounds)
        ciContext.draw(image, in: targetBounds, from: inputBounds)
    }
    
    fileprivate func imageBoundsForContentMode(_ fromRect: CGRect, toRect: CGRect) -> CGRect {
        switch contentMode {
        case .scaleAspectFill:
            return fromRect.v_aspectFill(toRect)
        case .scaleAspectFit:
            return fromRect.v_aspectFit(toRect)
        default:
            return fromRect
        }
    }

}
