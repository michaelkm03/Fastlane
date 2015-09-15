//
//  ContentViewHandoffController.swift
//  victorious
//
//  Created by Patrick Lynch on 9/2/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

/// An object sets up the view hiearachy and sets up relationships between objects
/// to facilitate the "split-to-reveal" style animated transition used when showing
/// `VNewContentViewController`
class ContentViewHandoffController {
    
    struct AnimatedConstraint {
        let constraint: NSLayoutConstraint
        let originValue: CGFloat
        let destinationValue: CGFloat
        
        func restore() {
            self.constraint.constant = originValue
        }
        func apply() {
            self.constraint.constant = destinationValue
        }
    }
    
    struct PreviewLayout {
        let height: AnimatedConstraint
        let width: AnimatedConstraint
        let top: AnimatedConstraint
        let center: AnimatedConstraint
        let view: UIView
        let parent: UIView
    }
    
    struct SliceLayout {
        let constraint: AnimatedConstraint
        let parent: UIView
    }
    
    private(set) var previewLayout: PreviewLayout?
    private(set) var sliceLayouts = [SliceLayout]()
    private(set) var transitionSliceViews = [UIView]()
    
    func addPreviewView( contentPreviewProvider: VContentPreviewViewProvider, toContentViewController contentViewController: VNewContentViewController, originSnapshotImage snapshotImage: UIImage) {
        
        let previewView = contentPreviewProvider.getPreviewView()
        let containerView = contentPreviewProvider.getContainerView()
        
        // Set up some of the important relationships between these objects
        if let videoPreviewView = previewView as? VVideoPreviewView {
            contentViewController.videoPlayer = videoPreviewView.videoPlayer
        }
        if let pollAnswerReceiver = previewView as? VPollResultReceiver {
            contentViewController.pollAnswerReceiver = pollAnswerReceiver
        }
        if let previewView = previewView as? VSequencePreviewView,
            let detailDelegate = contentViewController as? VSequencePreviewViewDetailDelegate {
                previewView.detailDelegate = detailDelegate
        }
        if let focusableView = previewView as? VFocusable {
            focusableView.focusType = VFocusType.Detail
        }
        if let videoSequenceDelegate = contentViewController as? VVideoSequenceDelegate,
            let videoSequence = previewView as? VVideoSequencePreviewView {
            videoSequence.delegate = videoSequenceDelegate
        }
        
        let parentView = contentViewController.contentCell.contentView
        let previewFrame = parentView.convertRect( previewView.frame, fromView: previewView )
        let containerFrame = parentView.convertRect( containerView.frame, fromView: containerView )
        
        parentView.addSubview(previewView)
        
        if let focusableView = previewView as? VFocusable {
            focusableView.focusType = .Detail
        }
        
        let widthConstraint = NSLayoutConstraint(item: previewView,
            attribute: .Width,
            relatedBy: .Equal,
            toItem: parentView,
            attribute: .Width,
            multiplier: 1.0,
            constant: previewFrame.width - parentView.frame.width )
        parentView.addConstraint( widthConstraint )
        
        let heightConstraint = NSLayoutConstraint(item: previewView,
            attribute: .Height,
            relatedBy: .Equal,
            toItem: parentView,
            attribute: .Height,
            multiplier: 1.0,
            constant: previewFrame.height - parentView.frame.height )
        parentView.addConstraint( heightConstraint )
        
        let topConstraint = NSLayoutConstraint(item: previewView,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: parentView,
            attribute: .Top,
            multiplier: 1.0,
            constant: previewFrame.origin.y )
        parentView.addConstraint( topConstraint )
        
        let centerConstraint = NSLayoutConstraint(item: previewView,
            attribute: .CenterX,
            relatedBy: .Equal,
            toItem: parentView,
            attribute: .CenterX,
            multiplier: 1.0,
            constant: previewFrame.midX - parentView.frame.midX )
        parentView.addConstraint( centerConstraint )
        
        self.previewLayout = PreviewLayout(
            height: AnimatedConstraint(constraint: heightConstraint, originValue: heightConstraint.constant, destinationValue:0.0),
            width: AnimatedConstraint(constraint: widthConstraint, originValue: widthConstraint.constant, destinationValue:0.0 ),
            top: AnimatedConstraint(constraint: topConstraint, originValue: topConstraint.constant, destinationValue:0.0),
            center: AnimatedConstraint(constraint: centerConstraint, originValue: centerConstraint.constant, destinationValue:0.0),
            view: previewView,
            parent: parentView )
        
        
        // WARNING: Get real values
        let tabbarHeight: CGFloat = 49.0
        let statusBarHeight: CGFloat = 20.0
        
        let topFrame = CGRect(
            x: 0,
            y: 0,
            width: snapshotImage.size.width,
            height: max(containerFrame.minY, statusBarHeight)
        )
        if let topImage = self.imageFromImage( snapshotImage, rect: topFrame) {
            let topImageView = UIImageView(image: topImage)
            parentView.addSubview( topImageView )
            topImageView.frame = topFrame
            topImageView.setTranslatesAutoresizingMaskIntoConstraints(false)
            
            let views = [ "topImageView" : topImageView ]
            
            let constraintsV = NSLayoutConstraint.constraintsWithVisualFormat(
                "V:[topImageView(height)]",
                options: nil,
                metrics: [ "height" : topImageView.frame.height, ],
                views: views
            )
            parentView.addConstraints( constraintsV )
            
            let topConstraint = NSLayoutConstraint(item: topImageView,
                attribute: .Bottom,
                relatedBy: .Equal,
                toItem: previewView,
                attribute: .Top,
                multiplier: 1.0,
                constant: containerFrame.minY - previewFrame.minY )
            parentView.addConstraint( topConstraint )
            
            
            let constraintsH = NSLayoutConstraint.constraintsWithVisualFormat("H:|[topImageView]|",
                options: nil,
                metrics: nil,
                views: views
            )
            parentView.addConstraints( constraintsH )
            
            sliceLayouts.append( SliceLayout(
                constraint: AnimatedConstraint(
                    constraint: topConstraint,
                    originValue: topConstraint.constant,
                    destinationValue: 0.0
                ),
                parent: parentView
            ) )
            
            transitionSliceViews.append( topImageView )
        }
        
        let midFrame = CGRect(
            x: 0,
            y: containerFrame.minY,
            width: snapshotImage.size.width,
            height: containerFrame.height
        )
        if let midImage = self.imageFromImage( snapshotImage, rect: midFrame) {
            let midImageView = UIImageView(image: midImage)
            parentView.insertSubview( midImageView, belowSubview: previewView )
            midImageView.frame = midFrame
            midImageView.setTranslatesAutoresizingMaskIntoConstraints(false)
            
            parentView.addConstraints( NSLayoutConstraint.constraintsWithVisualFormat("H:|[midImageView]|",
                options: nil,
                metrics: nil,
                views: [ "midImageView" : midImageView ])
            )
            let topConstraint = NSLayoutConstraint(item: midImageView,
                attribute: .Top,
                relatedBy: .Equal,
                toItem: previewView,
                attribute: .Top,
                multiplier: 1.0, constant: containerFrame.minY - previewFrame.minY)
            parentView.addConstraint( topConstraint )

            let bottomConstraint = NSLayoutConstraint(item: midImageView,
                attribute: .Bottom,
                relatedBy: .Equal,
                toItem: previewView,
                attribute: .Bottom,
                multiplier: 1.0, constant: containerFrame.maxY - previewFrame.maxY)
            parentView.addConstraint( bottomConstraint )
            
            transitionSliceViews.append( midImageView )
            
            sliceLayouts.append( SliceLayout(
                constraint: AnimatedConstraint(
                    constraint: topConstraint,
                    originValue: topConstraint.constant,
                    destinationValue: 0.0
                ),
                parent: parentView
            ) )
            
            sliceLayouts.append( SliceLayout(
                constraint: AnimatedConstraint(
                    constraint: bottomConstraint,
                    originValue: bottomConstraint.constant,
                    destinationValue: 0.0
                ),
                parent: parentView
            ) )
        }
        
        let botFrame = CGRect(
            x: 0,
            y: min( containerFrame.maxY, snapshotImage.size.height - tabbarHeight ),
            width: snapshotImage.size.width,
            height: max( snapshotImage.size.height - containerFrame.maxY, tabbarHeight )
        )
        if let botImage = self.imageFromImage( snapshotImage, rect: botFrame) {
            let botImageView = UIImageView(image: botImage)
            parentView.addSubview( botImageView )
            botImageView.frame = botFrame
            botImageView.setTranslatesAutoresizingMaskIntoConstraints(false)
            
            let bottomConstraint = NSLayoutConstraint(item: botImageView,
                attribute: .Top,
                relatedBy: .Equal,
                toItem: parentView,
                attribute: .Top,
                multiplier: 1.0,
                constant: snapshotImage.size.height - botFrame.height)
            parentView.addConstraint( bottomConstraint )
            
            let views = [ "botImageView" : botImageView ]
            let constraintsV = NSLayoutConstraint.constraintsWithVisualFormat( "V:[botImageView(height)]",
                options: nil,
                metrics: [ "height" : botImageView.frame.height, ],
                views: views
            )
            let constraintsH = NSLayoutConstraint.constraintsWithVisualFormat("H:|[botImageView]|",
                options: nil,
                metrics: nil,
                views: views
            )
            parentView.addConstraints( constraintsH )
            
            transitionSliceViews.append( botImageView )
            
            sliceLayouts.append( SliceLayout(
                constraint: AnimatedConstraint(
                    constraint: bottomConstraint,
                    originValue: bottomConstraint.constant,
                    destinationValue: snapshotImage.size.height
                ),
                parent: parentView
            ) )
        }
    }
    
    func imageFromImage( sourceImage: UIImage, rect: CGRect ) -> UIImage? {
        let sourceImageRef = sourceImage.CGImage
        let imageRef = CGImageCreateWithImageInRect( sourceImageRef, rect )
        return UIImage(CGImage: imageRef)
    }
}