//
//  CoachmarkViewController.swift
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
    static let textContainerStrokeColorKey = "color.stroke"
    static let textContainerTextWidth: CGFloat = 320
    static let closeButtonWidth: CGFloat = 90
    static let closeButtonHeight: CGFloat = 40
    static let closeButtonCornerRadius: CGFloat = 6
    static let textContainerPadding: CGFloat = -20
    static let highlightBoundaryStrokeThickness: CGFloat = 1.0
    static let highlightCircleRadius: CGFloat = 50
    static let highlightStrokeColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8).CGColor
    static let userMacro = "%%USER%%"
    static let creatorMacro = "%%CREATOR%%"
    static let animationDuration: NSTimeInterval = 0.3
    static let closeButtonStrokeWidth: CGFloat = 1
    static let closeButtonStrokeColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).CGColor
    static let textContainerBackgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.5)
    static let textContainerStrokeHeight: CGFloat = 2
    static let textLabelBottomPadding: CGFloat = -18
    static let titleLabelBottomPadding: CGFloat = -12
}

class CoachmarkViewController: UIViewController, VBackgroundContainer {
    private let backgroundView = UIView()
    
    init(coachmark: Coachmark, containerFrame: CGRect, highlightFrame: CGRect? = nil) {
        super.init(nibName: nil, bundle: nil)
        view = UIView(frame: containerFrame)
        modalPresentationStyle = .OverFullScreen
        modalTransitionStyle = .CrossDissolve
        let dependencyManager = coachmark.dependencyManager
        
        dependencyManager.addBackgroundToBackgroundHost(self)
        view.addSubview(backgroundView)
        view.v_addFitToParentConstraintsToSubview(backgroundView)
        
        let detailsView = CoachmarkTextContainerView()
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
        (closeButton as? TextOnColorButton)?.roundingType = .roundedRect(radius: Constants.closeButtonCornerRadius)
        detailsView.addSubview(closeButton)
        
        let strokeView = UIView(frame: CGRectZero)
        strokeView.backgroundColor = dependencyManager.containerStrokeColor
        detailsView.addSubview(strokeView)
        
        detailsView.translatesAutoresizingMaskIntoConstraints = false
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        detailsView.addSubview(blurView)
        detailsView.sendSubviewToBack(blurView)
        detailsView.v_addFitToParentConstraintsToSubview(blurView)
        dependencyManager.addBackgroundToBackgroundHost(detailsView, forKey: Constants.textBackgroundKey)
        view.addSubview(detailsView)
        
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
        textLabel.bottomAnchor.constraintEqualToAnchor(closeButton.topAnchor, constant: Constants.textLabelBottomPadding).active = true
        textLabel.centerXAnchor.constraintEqualToAnchor(detailsView.centerXAnchor).active = true
        textLabel.widthAnchor.constraintEqualToConstant(Constants.textContainerTextWidth).active = true
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.bottomAnchor.constraintEqualToAnchor(textLabel.topAnchor, constant: Constants.titleLabelBottomPadding).active = true
        titleLabel.widthAnchor.constraintEqualToConstant(Constants.textContainerTextWidth).active = true
        titleLabel.centerXAnchor.constraintEqualToAnchor(detailsView.centerXAnchor).active = true
        
        strokeView.translatesAutoresizingMaskIntoConstraints = false
        strokeView.topAnchor.constraintEqualToAnchor(detailsView.topAnchor).active = true
        strokeView.widthAnchor.constraintEqualToAnchor(detailsView.widthAnchor).active = true
        strokeView.heightAnchor.constraintEqualToConstant(Constants.textContainerStrokeHeight).active = true
        strokeView.centerXAnchor.constraintEqualToAnchor(detailsView.centerXAnchor).active = true
        
        // Must force layout here so that we can use the height
        // of the view when calculating the region to mask
        detailsView.layoutIfNeeded()
        
        //This path ensures that the background doesn't display behind the details text view
        let maskPath = UIBezierPath(rect: CGRect(
            origin: containerFrame.origin,
            size: CGSize(width: containerFrame.width, height: containerFrame.height - detailsView.frame.height)
        ))
        
        let backgroundMaskLayer = CAShapeLayer()
        
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
    
    // MARK: - Button Actions
    
    func closeButtonAction() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - VBackgroundContainer Methods
    
    func backgroundContainerView() -> UIView {
        return backgroundView
    }
    
    // MARK: - Configuration
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [.Portrait]
    }
}

private class HighlightForegroundView : UIView, VBackgroundContainer {
    @objc func backgroundContainerView() -> UIView {
        return self
    }
}

private class CoachmarkTextContainerView: UIView, VBackgroundContainer {
    @objc func backgroundContainerView() -> UIView {
        return self
    }
}

private extension VDependencyManager {
    var title: String {
        guard let titleString = stringForKey(Constants.titleKey) else {
            return ""
        }
        
        let name = VCurrentUser.user()?.displayName ?? ""
        return titleString.stringByReplacingOccurrencesOfString(Constants.userMacro, withString: name)
    }
    
    var titleFont: UIFont {
        return fontForKey(Constants.titleFontKey) ?? UIFont.systemFontOfSize(12.0)
    }
    
    var titleColor: UIColor {
        return colorForKey(Constants.titleColorKey) ?? UIColor.blackColor()
    }
    
    var text: String {
        guard let coachmarkText = stringForKey(Constants.textKey) else {
            return ""
        }
        
        let appInfo = VAppInfo(dependencyManager: self)
        let ownerName = appInfo.ownerName ?? ""
        
        return coachmarkText.stringByReplacingOccurrencesOfString(Constants.creatorMacro, withString: ownerName)
    }
    
    var textColor: UIColor {
        return colorForKey(Constants.textColorKey) ?? UIColor.blackColor()
    }
    
    var textFont: UIFont {
        return fontForKey(Constants.textFontKey) ?? UIFont.systemFontOfSize(10.0)
    }
    
    var closeButton: UIButton {
        return buttonForKey(Constants.closeButtonKey) ?? UIButton()
    }
    
    var containerStrokeColor: UIColor {
        return colorForKey(Constants.textContainerStrokeColorKey) ?? UIColor.clearColor()
    }
}
