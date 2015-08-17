//
//  VShelfContentCollectionViewCell.swift
//  victorious
//
//  Created by Sharif Ahmed on 7/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

/// A simple UICollectionViewCell with a loading background and a preview view
/// for displaying the content of any provided stream item.
class VShelfContentCollectionViewCell: VBaseCollectionViewCell {

    /// The view that will house the preview view.
    let previewViewContainer: UIView = UIView()
    private var previewView: VStreamItemPreviewView?
    
    /// The stream item whose content will populate this cell.
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
                previewViewContainer.addSubview(newPreviewView)
                v_addFitToParentConstraintsToSubview(newPreviewView)
                previewView = newPreviewView
            }
        }
    }
    
    /// The dependency manager whose colors and fonts will be used to style this cell.
    var dependencyManager: VDependencyManager? {
        didSet {
            onDependencyManagerSet()
        }
    }
    
    /// Called when a new dependency manager is set.
    func onDependencyManagerSet() {
        if let dependencyManager = dependencyManager {
            dependencyManager.addLoadingBackgroundToBackgroundHost(self)
        }
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        previewViewContainer.backgroundColor = UIColor.clearColor()
        contentView.addSubview(previewViewContainer)
        contentView.v_addFitToParentConstraintsToSubview(previewViewContainer)
    }
    
}

extension VShelfContentCollectionViewCell: VStreamCellComponentSpecialization {
    
    class func reuseIdentifierForStreamItem(streamItem: VStreamItem, baseIdentifier: String?, dependencyManager: VDependencyManager?) -> String {
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

extension VShelfContentCollectionViewCell: VBackgroundContainer {
    
    func loadingBackgroundContainerView() -> UIView! {
        return previewViewContainer
    }
    
}
