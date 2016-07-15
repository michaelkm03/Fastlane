//
//  Coachmark.swift
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
    static let titleColorKey = "title.color"
    static let titleFontKey = "title.font"
    static let textKey = "text"
    static let textColorKey = "color.text"
    static let textFontKey = "font.text"
    static let closeButtonKey = "close.button"
    static let textBackgroundKey = "text.background"
    static let highlightTargetKey = "highlight.target"
    static let highlightForegrounKey = "highlight.foreground"
    static let textContainerStrokeColorKey = "stroke.color"
    static let highlightCircleRadius: CGFloat = 10.0
}

class Coachmark: UIView {
    
    init(dependencyManager: VDependencyManager, frame: CGRect, highlightFrame: CGRect? = nil) {
        super.init(frame: frame)
        
        let detailsView = UIStackView()
        detailsView.axis = .Vertical
        
        let titleLabel = UILabel()
        titleLabel.text = dependencyManager.title
        titleLabel.font = dependencyManager.titleFont
        titleLabel.textColor = dependencyManager.titleColor
        detailsView.addArrangedSubview(titleLabel)
        
        let textLabel = UILabel()
        textLabel.text = dependencyManager.text
        textLabel.font = dependencyManager.textFont
        textLabel.textColor = dependencyManager.textColor
        detailsView.addArrangedSubview(textLabel)
        
        let closeButton = dependencyManager.closeButton
        closeButton.addTarget(self, action: #selector(Coachmark.closeButtonAction), forControlEvents: .TouchUpInside)
        detailsView.addArrangedSubview(closeButton)
        
        detailsView.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor).active = true
        detailsView.widthAnchor.constraintEqualToAnchor(self.widthAnchor).active = true
        detailsView.centerXAnchor.constraintEqualToAnchor(self.centerXAnchor).active = true
        detailsView.heightAnchor.constraintEqualToConstant(200)
        
        //dependencyManager.addBackgroundToBackgroundHost(detailsView, forKey: Constants.textBackgroundKey)
        if let highlightFrame = highlightFrame {
            let circleLayer = CAShapeLayer()
            circleLayer.path = UIBezierPath(
                arcCenter: highlightFrame.center,
                radius: Constants.highlightCircleRadius,
                startAngle: 0,
                endAngle: CGFloat(2 * M_PI),
                clockwise: true
            ).CGPath
            circleLayer.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).CGColor
            layer.addSublayer(circleLayer)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK : - Button Actions 
    
    func closeButtonAction() {
        
    }
    
}

private extension VDependencyManager {
    var title: String {
        return stringForKey(Constants.titleKey) ?? "Test title"
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