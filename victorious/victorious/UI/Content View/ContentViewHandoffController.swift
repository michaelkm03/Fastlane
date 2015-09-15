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
    
    struct MementoConstraint {
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
        let height: MementoConstraint
        let width: MementoConstraint
        let top: MementoConstraint
        let center: MementoConstraint
        let view: UIView
        let parent: UIView
    }
    
    struct BottomSliceLayout {
        let bottom: MementoConstraint
        let parent: UIView
    }
    
    private(set) var previewLayout: PreviewLayout?
    private(set) var bottomSliceLayout: BottomSliceLayout?
    private(set) var transitionSliceViews = [UIView]()
    
    func addPreviewView( previewView: UIView, toContentViewController contentViewController: VNewContentViewController, originSnapshotImage snapshotImage: UIImage) {
        
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
        
        let parentView = contentViewController.contentCell.contentView
        let originFrame = parentView.convertRect( previewView.frame, fromView: previewView )
        
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
            constant: originFrame.width - parentView.frame.width )
        parentView.addConstraint( widthConstraint )
        
        let heightConstraint = NSLayoutConstraint(item: previewView,
            attribute: .Height,
            relatedBy: .Equal,
            toItem: parentView,
            attribute: .Height,
            multiplier: 1.0,
            constant: originFrame.height - parentView.frame.height )
        parentView.addConstraint( heightConstraint )
        
        let topConstraint = NSLayoutConstraint(item: previewView,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: parentView,
            attribute: .Top,
            multiplier: 1.0,
            constant: originFrame.origin.y )
        parentView.addConstraint( topConstraint )
        
        let centerConstraint = NSLayoutConstraint(item: previewView,
            attribute: .CenterX,
            relatedBy: .Equal,
            toItem: parentView,
            attribute: .CenterX,
            multiplier: 1.0,
            constant: originFrame.midX - parentView.frame.midX )
        parentView.addConstraint( centerConstraint )
        
        self.previewLayout = PreviewLayout(
            height: MementoConstraint(constraint: heightConstraint, originValue: heightConstraint.constant, destinationValue:0.0),
            width: MementoConstraint(constraint: widthConstraint, originValue: widthConstraint.constant, destinationValue:0.0 ),
            top: MementoConstraint(constraint: topConstraint, originValue: topConstraint.constant, destinationValue:0.0),
            center: MementoConstraint(constraint: centerConstraint, originValue: centerConstraint.constant, destinationValue:0.0),
            view: previewView,
            parent: parentView )
        
        let topFrame = CGRect(
            x: 0,
            y: 0,
            width: snapshotImage.size.width,
            height: originFrame.minY
        )
        if let topImage = self.imageFromImage( snapshotImage, rect: topFrame) {
            let topImageView = UIImageView(image: topImage)
            parentView.addSubview( topImageView )
            topImageView.frame = topFrame
            topImageView.setTranslatesAutoresizingMaskIntoConstraints(false)
            
            let views = [
                "topImageView" : topImageView,
                "previewView" : previewView
            ]
            let constraintsV = NSLayoutConstraint.constraintsWithVisualFormat(
                "V:[topImageView(height)][previewView]",
                options: nil,
                metrics: [ "height" : topImageView.frame.height ],
                views: views
            )
            let constraintsH = NSLayoutConstraint.constraintsWithVisualFormat("H:|[topImageView]|",
                options: nil,
                metrics: nil,
                views: views
            )
            parentView.addConstraints( constraintsH )
            parentView.addConstraints( constraintsV )
            
            transitionSliceViews.append( topImageView )
        }
        
        let midFrame = CGRect(
            x: 0,
            y: originFrame.minY,
            width: snapshotImage.size.width,
            height: originFrame.height
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
            parentView.addConstraint( NSLayoutConstraint(item: midImageView,
                attribute: .Top,
                relatedBy: .Equal,
                toItem: previewView,
                attribute: .Top,
                multiplier: 1.0, constant: 0.0)
            )
            parentView.addConstraint( NSLayoutConstraint(item: midImageView,
                attribute: .Bottom,
                relatedBy: .Equal,
                toItem: previewView,
                attribute: .Bottom,
                multiplier: 1.0, constant: 0.0)
            )
            transitionSliceViews.append( midImageView )
        }
        
        // WARNING: Get real tabbar height
        let tabbarHeight: CGFloat = 60.0
        let botFrame = CGRect(
            x: 0,
            y: min( originFrame.maxY, snapshotImage.size.height - tabbarHeight ),
            width: snapshotImage.size.width,
            height: max( snapshotImage.size.height - originFrame.maxY, tabbarHeight )
        )
        if let botImage = self.imageFromImage( snapshotImage, rect: botFrame) {
            let botImageView = UIImageView(image: botImage)
            parentView.addSubview( botImageView )
            botImageView.frame = botFrame
            botImageView.setTranslatesAutoresizingMaskIntoConstraints(false)
            
            let bottomConstraint = NSLayoutConstraint(item: botImageView,
                attribute: .Top,
                relatedBy: .Equal,
                toItem: previewView,
                attribute: .Bottom,
                multiplier: 1.0,
                constant: 0.0)
            parentView.addConstraint( bottomConstraint )
            
            let views = [ "botImageView" : botImageView ]
            let constraintsV = NSLayoutConstraint.constraintsWithVisualFormat(
                "V:[botImageView(height)]",
                options: nil,
                metrics: [
                    "height" : botImageView.frame.height,
                    "botSpace" : 0 ],
                views: views
            )
            let constraintsH = NSLayoutConstraint.constraintsWithVisualFormat("H:|[botImageView]|",
                options: nil,
                metrics: nil,
                views: views
            )
            parentView.addConstraints( constraintsH )
            
            transitionSliceViews.append( botImageView )
            
            self.bottomSliceLayout = BottomSliceLayout(
                bottom: MementoConstraint(
                    constraint: bottomConstraint,
                    originValue: 0.0,
                    destinationValue: topConstraint.constant + snapshotImage.size.height - originFrame.maxY
                ),
                parent: parentView )
        }
    }
    
    func imageFromImage( sourceImage: UIImage, rect: CGRect ) -> UIImage? {
        let sourceImageRef = sourceImage.CGImage
        let imageRef = CGImageCreateWithImageInRect( sourceImageRef, rect )
        return UIImage(CGImage: imageRef)
    }
}