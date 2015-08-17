//
//  VListShelfContentCoverCell.swift
//  victorious
//
//  Created by Sharif Ahmed on 8/15/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

class VListShelfContentCoverCell : VShelfContentCollectionViewCell {
    
    private struct Constants {
        static let kSpaceBetweenElements: CGFloat = 5
        static let kDividerLineMinimumWidth: CGFloat = 12
        static let kDividerLineHeight: CGFloat = 1
    }
    
    private let overlayView: UIView = UIView()
    private let overlayLabel: UILabel = UILabel()
    private let dividerLineLeft: UIView = UIView()
    private let dividerLineRight: UIView = UIView()
    
    var overlayText: String? {
        didSet {
            updateVisibility()
            overlayLabel.text = overlayText
        }
    }
    
    required init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        contentView.insertSubview(overlayView, aboveSubview: previewViewContainer)
        contentView.v_addFitToParentConstraintsToSubview(overlayView)
        overlayView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        
        dividerLineLeft.setTranslatesAutoresizingMaskIntoConstraints(false)
        dividerLineRight.setTranslatesAutoresizingMaskIntoConstraints(false)
        overlayLabel.setTranslatesAutoresizingMaskIntoConstraints(false)

        overlayView.addSubview(dividerLineLeft)
        overlayView.addSubview(dividerLineRight)
        overlayView.addSubview(overlayLabel)
        overlayView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-space-[left(>=minWidth)]-space-[label]-space-[right(>=minWidth)]-space-|", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: ["space" : Constants.kSpaceBetweenElements, "minWidth" : Constants.kDividerLineMinimumWidth], views: ["left" : dividerLineLeft, "label" : overlayLabel, "right" : dividerLineRight]))
        
        overlayLabel.numberOfLines = 2
        overlayView.v_addCenterToParentContraintsToSubview(overlayLabel)
        overlayView.v_addPinToTopBottomToSubview(overlayLabel)

        dividerLineLeft.v_addHeightConstraint(Constants.kDividerLineHeight)
        dividerLineRight.v_addHeightConstraint(Constants.kDividerLineHeight)
        
        overlayLabel.textAlignment = NSTextAlignment.Center
        updateOverlayLabel()
    }
    
    private func updateVisibility() {
        var hidden = true
        if let text = overlayText {
            hidden = streamItem?.previewImagesObject == nil || count(text) == 0
        }
        overlayView.hidden = hidden
    }
    
    override func onStreamItemSet() {
        super.onStreamItemSet()
        updateVisibility()
    }
    
    override func onDependencyManagerSet() {
        super.onDependencyManagerSet()
        updateOverlayLabel()
    }
    
    private func updateOverlayLabel() {
        if let dependencyManager = dependencyManager {
            let color = dependencyManager.seeAllTextColor()
            overlayLabel.textColor = color
            dividerLineLeft.backgroundColor = color
            dividerLineRight.backgroundColor = color
            overlayLabel.font = dependencyManager.seeAllFont()
        }
    }
    
}

extension VListShelfContentCoverCell: VStreamCellComponentSpecialization {
    
    override class func reuseIdentifierForStreamItem(streamItem: VStreamItem, baseIdentifier: String?, dependencyManager: VDependencyManager?) -> String {
        let base = identifier(baseIdentifier, className: NSStringFromClass(self))
        return super.reuseIdentifierForStreamItem(streamItem, baseIdentifier: base, dependencyManager: dependencyManager)
    }
    
}

private extension VDependencyManager {
    
    func seeAllFont() -> UIFont {
        return self.fontForKey(VDependencyManagerParagraphFontKey)
    }
    
    func seeAllTextColor() -> UIColor {
        return UIColor.whiteColor()
    }
    
}
