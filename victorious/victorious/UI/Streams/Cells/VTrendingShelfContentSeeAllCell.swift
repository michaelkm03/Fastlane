//
//  VTrendingShelfContentSeeAllCell.swift
//  victorious
//
//  Created by Sharif Ahmed on 8/15/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

/// Displays a simple overlay and "see all" label on top of a shelf content collection view cell.
class VTrendingShelfContentSeeAllCell: VShelfContentCollectionViewCell {

    private let overlayView: UIView = UIView()
    private let overlayLabel: UILabel = UILabel()
    
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
        
        overlayView.addSubview(overlayLabel)
        overlayView.v_addFitToParentConstraintsToSubview(overlayLabel)
        overlayLabel.text = NSLocalizedString("See all", comment: "")
        overlayLabel.textAlignment = NSTextAlignment.Center
        updateOverlayLabel()
    }
    
    override func onDependencyManagerSet() {
        super.onDependencyManagerSet()
        updateOverlayLabel()
    }
    
    private func updateOverlayLabel() {
        if let dependencyManager = dependencyManager {
            overlayLabel.textColor = dependencyManager.seeAllTextColor()
            overlayLabel.font = dependencyManager.seeAllFont()
        }
    }

}

extension VTrendingShelfContentSeeAllCell: VStreamCellComponentSpecialization {
    
    override class func reuseIdentifierForStreamItem(streamItem: VStreamItem, baseIdentifier: String?, dependencyManager: VDependencyManager?) -> String {
        let updatedIdentifier = self.identifier(baseIdentifier, className: NSStringFromClass(self))
        return super.reuseIdentifierForStreamItem(streamItem, baseIdentifier: updatedIdentifier, dependencyManager: dependencyManager)
    }
    
}

private extension VDependencyManager {
    
    func seeAllFont() -> UIFont {
        return self.fontForKey(VDependencyManagerParagraphFontKey)
    }
    
    func seeAllTextColor() -> UIColor {
        return self.colorForKey(VDependencyManagerSecondaryTextColorKey)
    }
    
}
