//
//  VTrendingShelfContentCollectionViewCell.swift
//  victorious
//
//  Created by Sharif Ahmed on 7/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

class VTrendingShelfContentCollectionViewCell: VBaseCollectionViewCell {

    var previewView : VStreamItemPreviewView? = nil
    var streamItem : VStreamItem? {
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
                addSubview(newPreviewView)
                v_addFitToParentConstraintsToSubview(newPreviewView)
                previewView = newPreviewView
            }
        }
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
