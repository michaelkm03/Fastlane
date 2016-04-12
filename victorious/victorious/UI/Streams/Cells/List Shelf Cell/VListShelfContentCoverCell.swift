//
//  VListShelfContentCoverCell.swift
//  victorious
//
//  Created by Sharif Ahmed on 8/15/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

/// A shelf content collection view cell with a stylized, centered label on top.
class VListShelfContentCoverCell: VShelfContentCollectionViewCell {
    
    private struct Constants {
        static let kSpaceBetweenElements: CGFloat = 5
        static let kDividerLineMinimumWidth: CGFloat = 12
        static let kDividerLineHeight: CGFloat = 1
    }
    
    private let overlayView = UIView()
    private let overlayLabel = UILabel()
    private let dividerLineLeft = UIView()
    private let dividerLineRight = UIView()
    
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
        
        dividerLineLeft.translatesAutoresizingMaskIntoConstraints = false
        dividerLineRight.translatesAutoresizingMaskIntoConstraints = false
        overlayLabel.translatesAutoresizingMaskIntoConstraints = false

        overlayView.addSubview(dividerLineLeft)
        overlayView.addSubview(dividerLineRight)
        overlayView.addSubview(overlayLabel)
        let constraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-space-[left(>=minWidth)]-space-[label]-space-[right(>=minWidth)]-space-|",
            options: NSLayoutFormatOptions.AlignAllCenterY,
            metrics: [
                "space": Constants.kSpaceBetweenElements,
                "minWidth": Constants.kDividerLineMinimumWidth
            ],
            views: [
                "left": dividerLineLeft,
                "label": overlayLabel,
                "right": dividerLineRight
            ]
        )
        overlayView.addConstraints(constraints)
        
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
        if let text = overlayText,
            let previewImageAssets = streamItem?.previewImageAssets {
            hidden = previewImageAssets.count == 0 || text.characters.count == 0
        }
        overlayView.hidden = hidden
    }
    
    override var streamItem: VStreamItem? {
        didSet {
            updateVisibility()
        }
    }
    
    override var dependencyManager: VDependencyManager? {
        didSet {
            updateOverlayLabel()
        }
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

extension VListShelfContentCoverCell { // VStreamCellComponentSpecialization methods
    
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
