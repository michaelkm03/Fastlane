//
//  CoachmarkView.swift
//  victorious
//
//  Created by Darvish Kamalia on 7/14/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

private struct Constants {
    static let backgroundKey = "background"
    static let screenIdentifierKey = "screen"
    static let titleKey = "title"
    static let titleColorKey = "color.title"
    static let titleFontKey = "font.title"
    static let textKey = "text"
    static let textColorKey = "color.text"
    static let textFontKey = "font.text"
    static let closeButtonKey = "close.button"
    static let textBackgroundKey = "text.background"
    static let highlightTargetKey = "highlight.target"
    static let highlightForegroundKey = "highlight.foreground"
    static let textContainerStrokeColorKey = "stroke.color"
    static let textContainerTextWidth: CGFloat = 279
    static let closeButtonWidth: CGFloat = 100
    static let closeButtonHeight: CGFloat = 40
    static let textContainerPadding: CGFloat = -20.0
    static let highlightBoundaryStrokeThickness: CGFloat = 4.0
    static let highlightCircleRadius: CGFloat = 50.0
    static let highlightStrokeColor = UIColor.blackColor().CGColor
    static let userMacro = "%%USER%%"
    static let animationDuration: NSTimeInterval = 1
}

class CoachmarkView: UIView, VBackgroundContainer {
    let backgroundView = UIView()
    var displayer: CoachmarkDisplayer?
    
    init(coachmark: Coachmark, containerFrame: CGRect, highlightFrame: CGRect? = nil, displayer: CoachmarkDisplayer? = nil) {
        super.init(frame: containerFrame)
        
        self.displayer = displayer
        
        let dependencyManager = coachmark.dependencyManager
        
        dependencyManager.addBackgroundToBackgroundHost(self)
        self.addSubview(backgroundView)
        self.v_addFitToParentConstraintsToSubview(backgroundView)
        
        let detailsView = TextContainerView()
        
        let titleLabel = UILabel()
        titleLabel.text = dependencyManager.title
        titleLabel.font = dependencyManager.titleFont
        titleLabel.textColor = dependencyManager.titleColor
        titleLabel.textAlignment = .Center
        titleLabel.numberOfLines = 0
        detailsView.addSubview(titleLabel)
        
        let textLabel = UILabel()
        textLabel.text = dependencyManager.text
        textLabel.font = dependencyManager.textFont
        textLabel.textColor = dependencyManager.textColor
        textLabel.numberOfLines = 0
        textLabel.textAlignment = .Center
        detailsView.addSubview(textLabel)
        
        let closeButton = dependencyManager.closeButton
        closeButton.addTarget(self, action: #selector(CoachmarkView.closeButtonAction), forControlEvents: .TouchUpInside)
        detailsView.addSubview(closeButton)
        
        detailsView.translatesAutoresizingMaskIntoConstraints = false
        dependencyManager.addBackgroundToBackgroundHost(detailsView, forKey: Constants.textBackgroundKey)
        self.addSubview(detailsView)
        
        //Setup constraints
        detailsView.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor).active = true
        detailsView.centerXAnchor.constraintEqualToAnchor(self.centerXAnchor).active = true
        detailsView.topAnchor.constraintEqualToAnchor(titleLabel.topAnchor, constant: Constants.textContainerPadding).active = true
        detailsView.widthAnchor.constraintEqualToAnchor(self.widthAnchor).active = true
        
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.bottomAnchor.constraintEqualToAnchor(detailsView.bottomAnchor, constant: Constants.textContainerPadding).active = true
        closeButton.centerXAnchor.constraintEqualToAnchor(detailsView.centerXAnchor).active = true
        closeButton.widthAnchor.constraintEqualToConstant(Constants.closeButtonWidth).active = true
        closeButton.heightAnchor.constraintEqualToConstant(Constants.closeButtonHeight).active = true
        
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.bottomAnchor.constraintEqualToAnchor(closeButton.topAnchor, constant: Constants.textContainerPadding).active = true
        textLabel.centerXAnchor.constraintEqualToAnchor(detailsView.centerXAnchor).active = true
        textLabel.widthAnchor.constraintEqualToConstant(Constants.textContainerTextWidth).active = true
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.bottomAnchor.constraintEqualToAnchor(textLabel.topAnchor, constant: Constants.textContainerPadding).active = true
        titleLabel.widthAnchor.constraintEqualToConstant(Constants.textContainerTextWidth).active = true
        titleLabel.centerXAnchor.constraintEqualToAnchor(detailsView.centerXAnchor).active = true
        
        // Must force layout here so that we can use the height
        // of the view when calculating the region to mask
        detailsView.layoutIfNeeded()
        
        //This path ensures that the background doesn't display behind the details text view
        let maskPath = UIBezierPath(rect: CGRect(
            origin: containerFrame.origin,
            size: CGSize(width: containerFrame.width, height: containerFrame.height - detailsView.frame.height)
            )
        )
        let backgroundMaskLayer =  CAShapeLayer()
        backgroundMaskLayer.path = maskPath.CGPath
        
        if let highlightFrame = highlightFrame {
            // The following code creates a "hole" in the view's layer
            // We start with a boundary path that encloses the whole view, then we add a path for the
            // circular highlight. Lastly, because we fill with the EvenOddRule, everything between the
            // circle and the boundary is filled, and this is used to mask the layer
            
            
            let circularPath = UIBezierPath(
                arcCenter: highlightFrame.center,
                radius: Constants.highlightCircleRadius,
                startAngle: 0,
                endAngle: CGFloat(2 * M_PI),
                clockwise: true
            )
            
            maskPath.appendPath(circularPath)
            backgroundMaskLayer.fillRule = kCAFillRuleEvenOdd
            
            //Fill in the "hole" using the specified foreground
            let foregroundMasklayer = CAShapeLayer()
            foregroundMasklayer.path = circularPath.CGPath  //Now we only want the inside of the circle
            
            let foregroundView = HighlightForegroundView(frame: containerFrame)
            foregroundView.layer.mask = foregroundMasklayer
            
            //Create the stroke around the highlight
            let strokeLayer = CAShapeLayer()
            strokeLayer.path = circularPath.CGPath
            strokeLayer.strokeColor = Constants.highlightStrokeColor
            strokeLayer.lineWidth = Constants.highlightBoundaryStrokeThickness
            strokeLayer.strokeStart = 0.0
            strokeLayer.strokeEnd = 1.0
            strokeLayer.fillColor = nil
            foregroundView.layer.addSublayer(strokeLayer)
            
            dependencyManager.addBackgroundToBackgroundHost(foregroundView, forKey: Constants.highlightForegroundKey)
            self.addSubview(foregroundView)
            v_addFitToParentConstraintsToSubview(foregroundView)
        }
        
        backgroundView.layer.mask = backgroundMaskLayer
        bringSubviewToFront(detailsView)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK : - Button Actions 
    
    func closeButtonAction() {
       UIView.animateWithDuration(
            Constants.animationDuration,
            animations: {
                self.alpha = 0
            })
            { _ in
                self.removeFromSuperview()
                self.displayer?.coachmarkDidDismiss()
            }
    }
    
    // MARK : - VBackgroundContainer Methods 
    
    func backgroundContainerView() -> UIView {
        return backgroundView
    }
    
}

private class HighlightForegroundView : UIView, VBackgroundContainer {
    @objc func backgroundContainerView() -> UIView {
        return self
    }
}

private class TextContainerView: UIView, VBackgroundContainer {
    @objc func backgroundContainerView() -> UIView {
        return self
    }
}

private extension VDependencyManager {
    var title: String {
        if let titleString = stringForKey(Constants.titleKey) {
            if let name = VCurrentUser.user()?.name {
                return titleString.stringByReplacingOccurrencesOfString(Constants.userMacro, withString: name)
            }
            return titleString.stringByReplacingOccurrencesOfString(Constants.userMacro, withString: "")
        }
        return ""
    }
    
    var titleFont: UIFont {
        return fontForKey(Constants.titleFontKey) ?? UIFont.systemFontOfSize(12.0)
    }
    
    var titleColor : UIColor {
        return colorForKey(Constants.titleColorKey) ?? UIColor.blackColor()
    }
    
    var text: String {
        return stringForKey(Constants.textKey) ?? "Test Coachmark text"
    }
    
    var textColor: UIColor {
        return colorForKey(Constants.textColorKey) ?? UIColor.blackColor()
    }
    
    var textFont: UIFont {
        return fontForKey(Constants.textFontKey) ?? UIFont.systemFontOfSize(10.0)
    }
    
    var closeButton : UIButton {
        return buttonForKey(Constants.closeButtonKey) ?? UIButton()
    }
}
