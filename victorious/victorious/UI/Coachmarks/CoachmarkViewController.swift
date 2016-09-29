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
    static let highlightStrokeColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8).cgColor
    static let userMacro = "%%USER%%"
    static let creatorMacro = "%%CREATOR%%"
    static let animationDuration: TimeInterval = 0.3
    static let closeButtonStrokeWidth: CGFloat = 1
    static let closeButtonStrokeColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
    static let textContainerBackgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.5)
    static let textContainerStrokeHeight: CGFloat = 2
    static let textLabelBottomPadding: CGFloat = -18
    static let titleLabelBottomPadding: CGFloat = -12
}

class CoachmarkViewController: UIViewController, VBackgroundContainer {
    fileprivate let backgroundView = UIView()
    fileprivate let detailsView = CoachmarkTextContainerView()
    
    init(coachmark: Coachmark, containerFrame: CGRect, highlightFrame: CGRect? = nil) {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        let dependencyManager = coachmark.dependencyManager
        
        dependencyManager.addBackground(toBackgroundHost: self)
        view.addSubview(backgroundView)
        view.v_addFitToParentConstraints(toSubview: backgroundView)
        
        let titleLabel = UILabel()
        titleLabel.text = dependencyManager.title
        titleLabel.font = dependencyManager.titleFont
        titleLabel.textColor = dependencyManager.titleColor
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        detailsView.addSubview(titleLabel)
        
        let textLabel = UILabel()
        textLabel.text = dependencyManager.text
        textLabel.font = dependencyManager.textFont
        textLabel.textColor = dependencyManager.textColor
        textLabel.numberOfLines = 0
        textLabel.textAlignment = .center
        detailsView.addSubview(textLabel)
        
        let closeButton = dependencyManager.closeButton
        closeButton.addTarget(self, action: #selector(CoachmarkViewController.closeButtonAction), for: .touchUpInside)
        closeButton.layer.borderColor = Constants.closeButtonStrokeColor
        closeButton.layer.borderWidth = Constants.closeButtonStrokeWidth
        (closeButton as? TextOnColorButton)?.roundingType = .roundedRect(radius: Constants.closeButtonCornerRadius)
        detailsView.addSubview(closeButton)
        
        let strokeView = UIView(frame: CGRect.zero)
        strokeView.backgroundColor = dependencyManager.containerStrokeColor
        detailsView.addSubview(strokeView)
        
        detailsView.translatesAutoresizingMaskIntoConstraints = false
        dependencyManager.addBackground(toBackgroundHost: detailsView, forKey: Constants.textBackgroundKey)
        view.addSubview(detailsView)
        
        //Setup constraints
        detailsView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        detailsView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        detailsView.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: Constants.textContainerPadding).isActive = true
        detailsView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.bottomAnchor.constraint(equalTo: detailsView.bottomAnchor, constant: Constants.textContainerPadding).isActive = true
        closeButton.centerXAnchor.constraint(equalTo: detailsView.centerXAnchor).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: Constants.closeButtonWidth).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: Constants.closeButtonHeight).isActive = true
        
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.bottomAnchor.constraint(equalTo: closeButton.topAnchor, constant: Constants.textLabelBottomPadding).isActive = true
        textLabel.centerXAnchor.constraint(equalTo: detailsView.centerXAnchor).isActive = true
        textLabel.widthAnchor.constraint(equalToConstant: Constants.textContainerTextWidth).isActive = true
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.bottomAnchor.constraint(equalTo: textLabel.topAnchor, constant: Constants.titleLabelBottomPadding).isActive = true
        titleLabel.widthAnchor.constraint(equalToConstant: Constants.textContainerTextWidth).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: detailsView.centerXAnchor).isActive = true
        
        strokeView.translatesAutoresizingMaskIntoConstraints = false
        strokeView.topAnchor.constraint(equalTo: detailsView.topAnchor).isActive = true
        strokeView.widthAnchor.constraint(equalTo: detailsView.widthAnchor).isActive = true
        strokeView.heightAnchor.constraint(equalToConstant: Constants.textContainerStrokeHeight).isActive = true
        strokeView.centerXAnchor.constraint(equalTo: detailsView.centerXAnchor).isActive = true
        
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
            
            maskPath.append(circularPath)
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
        
        backgroundMaskLayer.path = maskPath.cgPath
        backgroundView.layer.mask = backgroundMaskLayer
        view.bringSubview(toFront: detailsView)
    }
    
    func setupBlurView() -> UIVisualEffectView {
        let blurView = UIVisualEffectView()
        detailsView.addSubview(blurView)
        detailsView.sendSubview(toBack: blurView)
        detailsView.v_addFitToParentConstraints(toSubview: blurView)
        return blurView
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Button Actions
    
    func closeButtonAction() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - VBackgroundContainer Methods
    
    func backgroundContainerView() -> UIView {
        return backgroundView
    }
    
    // MARK: - Configuration
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [.portrait]
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
        guard let titleString = string(forKey: Constants.titleKey) else {
            return ""
        }
        
        let name = VCurrentUser.user?.displayName ?? ""
        return titleString.stringByReplacingOccurrencesOfString(Constants.userMacro, withString: name)
    }
    
    var titleFont: UIFont {
        return font(forKey: Constants.titleFontKey) ?? UIFont.systemFont(ofSize: 12.0)
    }
    
    var titleColor: UIColor {
        return color(forKey: Constants.titleColorKey) ?? UIColor.black
    }
    
    var text: String {
        guard let coachmarkText = string(forKey: Constants.textKey) else {
            return ""
        }
        
        let appInfo = VAppInfo(dependencyManager: self)
        let ownerName = appInfo.ownerName ?? ""
        
        return coachmarkText.stringByReplacingOccurrencesOfString(Constants.creatorMacro, withString: ownerName)
    }
    
    var textColor: UIColor {
        return color(forKey: Constants.textColorKey) ?? UIColor.black
    }
    
    var textFont: UIFont {
        return font(forKey: Constants.textFontKey) ?? UIFont.systemFont(ofSize: 10.0)
    }
    
    var closeButton: UIButton {
        return button(forKey: Constants.closeButtonKey) ?? UIButton()
    }
    
    var containerStrokeColor: UIColor {
        return color(forKey: Constants.textContainerStrokeColorKey) ?? UIColor.clear
    }
}
