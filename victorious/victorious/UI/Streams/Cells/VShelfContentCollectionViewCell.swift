//
//  VShelfContentCollectionViewCell.swift
//  victorious
//
//  Created by Sharif Ahmed on 7/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

class VShelfContentCollectionViewCell: VBaseCollectionViewCell {

    let previewViewContainer: UIView = UIView()
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
                previewViewContainer.addSubview(newPreviewView)
                v_addFitToParentConstraintsToSubview(newPreviewView)
                previewView = newPreviewView
            }
        }
    }
    
    var dependencyManager: VDependencyManager? {
        didSet {
            onDependencyManagerSet()
        }
    }
    
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
        contentView.addSubview(previewViewContainer)
        contentView.v_addFitToParentConstraintsToSubview(previewViewContainer)
    }
    
    static func reuseIdentifierForStreamItem(streamItem: VStreamItem, baseIdentifier: String?, dependencyManager: VDependencyManager?, className: String) -> String {
        var identifier = ""
        if let base = baseIdentifier {
            identifier = base
        }
        
        identifier += className
        
        if let itemType = streamItem.itemType {
            identifier += "." + itemType
        }
        
        if let itemSubType = streamItem.itemSubType {
            identifier += "." + itemSubType
        }
        
        return identifier
    }
}

extension VShelfContentCollectionViewCell: VStreamCellComponentSpecialization {
    
    class func reuseIdentifierForStreamItem(streamItem: VStreamItem, baseIdentifier: String?, dependencyManager: VDependencyManager?) -> String {
        return reuseIdentifierForStreamItem(streamItem, baseIdentifier: baseIdentifier, dependencyManager: dependencyManager, className: NSStringFromClass(self))
    }
    
}

extension VShelfContentCollectionViewCell: VBackgroundContainer {
    
    func backgroundContainerView() -> UIView! {
        return previewViewContainer
    }
    
}
