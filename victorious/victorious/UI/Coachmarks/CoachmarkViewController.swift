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
    static let textContainerTextWidth: CGFloat = 320
    static let closeButtonWidth: CGFloat = 90
    static let closeButtonHeight: CGFloat = 40
    static let closeButtonCornerRadius: CGFloat = 6
    static let textContainerPadding: CGFloat = -20
    static let highlightBoundaryStrokeThickness: CGFloat = 2.0
    static let highlightCircleRadius: CGFloat = 50
    static let highlightStrokeColor = UIColor.blackColor().CGColor
    static let userMacro = "%%USER%%"
    static let animationDuration: NSTimeInterval = 1
    static let closeButtonStrokeWidth: CGFloat = 2
    static let closeButtonStrokeColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).CGColor
}

class CoachmarkViewController: UIViewController, VBackgroundContainer {
    let backgroundView = UIView()
    var displayer: CoachmarkDisplayer?
    
    init(coachmark: Coachmark, containerFrame: CGRect, highlightFrame: CGRect? = nil, displayer: CoachmarkDisplayer? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.view = UIView(frame: containerFrame)
        self.displayer = displayer
        self.modalPresentationStyle = .OverFullScreen
        let dependencyManager = coachmark.dependencyManager
        
        dependencyManager.addBackgroundToBackgroundHost(self)
        view.addSubview(backgroundView)
        view.v_addFitToParentConstraintsToSubview(backgroundView)
        
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
        closeButton.addTarget(self, action: #selector(CoachmarkViewController.closeButtonAction), forControlEvents: .TouchUpInside)
        closeButton.layer.borderColor = Constants.closeButtonStrokeColor
        closeButton.layer.borderWidth = Constants.closeButtonStrokeWidth
        closeButton.applyCornerRadius(Constants.closeButtonCornerRadius)
        detailsView.addSubview(closeButton)
        
        detailsView.translatesAutoresizingMaskIntoConstraints = false
        dependencyManager.addBackgroundToBackgroundHost(detailsView, forKey: Constants.textBackgroundKey)
        self.view.addSubview(detailsView)
        
        //Setup constraints
        detailsView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
        detailsView.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        detailsView.topAnchor.constraintEqualToAnchor(titleLabel.topAnchor, constant: Constants.textContainerPadding).active = true
        detailsView.widthAnchor.constraintEqualToAnchor(view.widthAnchor).active = true
        
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.bottomAnchor.constraintEqualToAnchor(detailsView.bottomAnchor, constant: Constants.textContainerPadding).active = true
        closeButton.centerXAnchor.constraintEqualToAnchor(detailsView.centerXAnchor).active = true
        closeButton.widthAnchor.constraintEqualToConstant(Constants.closeButtonWidth).active = true
        closeButton.heightAnchor.constraintEqualToConstant(Constants.closeButtonHeight).active = true
        
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.bottomAnchor.constraintEqualToAnchor(closeButton.topAnchor, constant: -18).active = true
        textLabel.centerXAnchor.constraintEqualToAnchor(detailsView.centerXAnchor).active = true
        textLabel.widthAnchor.constraintEqualToConstant(Constants.textContainerTextWidth).active = true
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.bottomAnchor.constraintEqualToAnchor(textLabel.topAnchor, constant: -12).active = true
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
            let foregroundSize = CGSize(width: Constants.highlightCircleRadius * CGFloat(2), height: Constants.highlightCircleRadius * CGFloat(2))
            let foregroundView = HighlightForegroundView(frame: CGRect(center: highlightFrame.center, size: foregroundSize))
            foregroundView.layer.cornerRadius = foregroundSize.v_roundCornerRadius
            foregroundView.layer.masksToBounds = true
            foregroundView.layer.borderColor = Constants.highlightStrokeColor
            foregroundView.layer.borderWidth = Constants.highlightBoundaryStrokeThickness
            view.addSubview(foregroundView)
        }
        
        backgroundMaskLayer.path = maskPath.CGPath
        backgroundView.layer.mask = backgroundMaskLayer
        view.bringSubviewToFront(detailsView)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK : - Button Actions 
    
    func closeButtonAction() {
       UIView.animateWithDuration(
            Constants.animationDuration,
            animations: {
                self.view.alpha = 0
            })
            { _ in
                self.dismissViewControllerAnimated(false, completion: nil)
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
