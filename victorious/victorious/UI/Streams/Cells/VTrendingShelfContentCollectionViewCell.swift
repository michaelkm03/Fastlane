//
//  VTrendingShelfContentCollectionViewCell.swift
//  victorious
//
//  Created by Sharif Ahmed on 7/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

class VTrendingShelfContentCollectionViewCell: VBaseCollectionViewCell {

    private let previewViewContainer: UIView
    private var overlayView: UIView?
    private var overlayLabel: UILabel?
    private var previewView: VStreamItemPreviewView?
    
    var streamItem: VStreamItem? {
        didSet {
            if let previewView = previewView {
                if previewView.canHandleStreamItem(streamItem) {
                    previewView.streamItem = streamItem
                    return
                }
                previewView.removeFromSuperview()
            }

            if let newPreviewView = VStreamItemPreviewView(streamItem: streamItem) {
                newPreviewView.streamItem = streamItem
                contentView.addSubview(newPreviewView)
                v_addFitToParentConstraintsToSubview(newPreviewView)
                previewView = newPreviewView
            }
        }
    }
    
    var showOverlay = false {
        didSet {
            if showOverlay {
                if overlayView == nil && overlayLabel == nil {
                    overlayView = UIView()
                    if let overlayView = overlayView {
                        contentView.addSubview(overlayView)
                        contentView.v_addFitToParentConstraintsToSubview(overlayView)
                        overlayView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
                        
                        overlayLabel = UILabel()
                        if let overlayLabel = overlayLabel {
                            overlayView.addSubview(overlayLabel)
                            overlayView.v_addFitToParentConstraintsToSubview(overlayLabel)
                            overlayLabel.text = NSLocalizedString("See all", comment: "")
                            overlayLabel.textAlignment = NSTextAlignment.Center
                        }
                    }
                }
            }
            overlayView?.hidden = !showOverlay
        }
    }
    
    var dependencyManager: VDependencyManager? {
        didSet {
            if let dependencyManager = dependencyManager {
                overlayLabel?.textColor = dependencyManager.seeAllTextColor()
                overlayLabel?.font = dependencyManager.seeAllFont()
                dependencyManager.addLoadingBackgroundToBackgroundHost(self)
            }
        }
    }
    
    required override init(frame: CGRect) {
        previewViewContainer = UIView()
        super.init(frame: frame)
        setup()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        contentView.addSubview(previewViewContainer)
        contentView.v_addFitToParentConstraintsToSubview(previewViewContainer)
    }
    
    static func reuseIdentifierForStreamItem(streamItem: VStreamItem, asShowMore: Bool, baseIdentifier: String?, dependencyManager: VDependencyManager?) -> String {
        var identifier = self .reuseIdentifierForStreamItem(streamItem, baseIdentifier: baseIdentifier, dependencyManager: dependencyManager)
        if ( asShowMore ) {
            identifier += ".showMore"
        }
        return identifier
    }
}

extension VTrendingShelfContentCollectionViewCell: VStreamCellComponentSpecialization {
    
    static func reuseIdentifierForStreamItem(streamItem: VStreamItem, baseIdentifier: String?, dependencyManager: VDependencyManager?) -> String {
        var identifier = ""
        if let base = baseIdentifier {
            identifier = base
        }
        
        if let itemType = streamItem.itemType {
            identifier += "." + itemType
        }
        
        if let itemSubType = streamItem.itemSubType {
            identifier += "." + itemSubType
        }
        
        return identifier
    }
    
}

extension VTrendingShelfContentCollectionViewCell: VBackgroundContainer {
    
    func backgroundContainerView() -> UIView! {
        return previewViewContainer
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
