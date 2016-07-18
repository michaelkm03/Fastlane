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
    static let titleColorKey = "title.color"
    static let titleFontKey = "title.font"
    static let textKey = "text"
    static let textColorKey = "color.text"
    static let textFontKey = "font.text"
    static let closeButtonKey = "close.button"
    static let textBackgroundKey = "text.background"
    static let highlightTargetKey = "highlight.target"
    static let highlightForegroundKey = "highlight.foreground"
    static let textContainerStrokeColorKey = "stroke.color"
    static let textContainerPadding: CGFloat = 10.0
    static let highlightBoundaryStrokeThickness: CGFloat = 4.0
    static let highlightCircleRadius: CGFloat = 50.0
    static let highlightStrokeColor = UIColor.blackColor().CGColor
}

class CoachmarkView: UIView, VBackgroundContainer {
    
    let backgroundView = UIView()
    
    init(coachmark: Coachmark, containerFrame: CGRect, highlightFrame: CGRect? = nil) {
        super.init(frame: containerFrame)
        
        let dependencyManager = coachmark.dependencyManager
//        
//        let detailsView = TextContainerView()
//        detailsView.axis = .Vertical
//        detailsView.distribution = .EqualCentering
//        detailsView.alignment = .Center
//        
//        let titleLabel = UILabel()
//        titleLabel.text = dependencyManager.title
//        titleLabel.font = dependencyManager.titleFont
//        titleLabel.textColor = dependencyManager.titleColor
//        detailsView.addArrangedSubview(titleLabel)
//        
//        let textLabel = UILabel()
//        textLabel.text = dependencyManager.text
//        textLabel.font = dependencyManager.textFont
//        textLabel.textColor = dependencyManager.textColor
//        detailsView.addArrangedSubview(textLabel)
//        
//        let closeButton = dependencyManager.closeButton
//        closeButton.addTarget(self, action: #selector(CoachmarkView.closeButtonAction), forControlEvents: .TouchUpInside)
//        detailsView.addArrangedSubview(closeButton)
//        self.addSubview(detailsView)
//        
//        detailsView.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor).active = true
//        detailsView.widthAnchor.constraintEqualToAnchor(self.widthAnchor).active = true
//        detailsView.centerXAnchor.constraintEqualToAnchor(self.centerXAnchor).active = true
//        
//        var height = titleLabel.intrinsicContentSize().height + textLabel.intrinsicContentSize().height + closeButton.intrinsicContentSize().height
//        height += Constants.textContainerPadding * 3
//        detailsView.heightAnchor.constraintEqualToConstant(height).active = true
//        self.translatesAutoresizingMaskIntoConstraints = false
//       
    
       dependencyManager.addBackgroundToBackgroundHost(self)
        self.addSubview(backgroundView)
        self.v_addFitToParentConstraintsToSubview(backgroundView)
       // dependencyManager.addBackgroundToBackgroundHost(detailsView, forKey: Constants.textBackgroundKey)
        
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
            
            let maskPath = UIBezierPath(rect: containerFrame)
            maskPath.appendPath(circularPath)

            let backgroundMaskLayer =  CAShapeLayer()
            backgroundMaskLayer.path = maskPath.CGPath
            backgroundMaskLayer.fillRule = kCAFillRuleEvenOdd
            backgroundView.layer.mask = backgroundMaskLayer
            
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
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK : - Button Actions 
    
    func closeButtonAction() {
        removeFromSuperview()
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

private class TextContainerView: UIStackView, VBackgroundContainer {
    @objc func backgroundContainerView() -> UIView {
        return self
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