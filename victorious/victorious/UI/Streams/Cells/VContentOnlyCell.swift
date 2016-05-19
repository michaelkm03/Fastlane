//
//  VContentOnlyCell.swift
//  victorious
//
//  Created by Jarod Long on 4/5/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

/// A collection view cell that only shows a stream item's content.
class VContentOnlyCell: UICollectionViewCell {
    // MARK: - Constants
    
    private static let cornerRadius: CGFloat = 6.0
    
    // MARK: - Initializing
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        // Prevents UICollectionView from complaining about constraints "ambiguously suggesting a size of zero".
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraint(NSLayoutConstraint(item: contentView, attribute: .Width,  relatedBy: .GreaterThanOrEqual, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 1.0))
        contentView.addConstraint(NSLayoutConstraint(item: contentView, attribute: .Height, relatedBy: .GreaterThanOrEqual, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 1.0))
        
        clipsToBounds = true
        layer.cornerRadius = VContentOnlyCell.cornerRadius
    }
    
    // MARK: - Sequence/ViewedContent
    
    func setStreamItem(streamItem: VStreamItem?) {
        if let streamItem = streamItem {
            self.streamItem = streamItem
            self.content = nil
        }
        updatePreviewView()
    }
    
    func setContent(content: VContent?) {
        if let content = content {
            self.content = content
            self.streamItem = nil
        }
        updatePreviewView()
    }
    
    private var streamItem: VStreamItem?
    private var content: VContent?
    
    // MARK: - Dependency manager
    
    var dependencyManager: VDependencyManager?
    
    // MARK: - Views
    
    private var streamItemPreviewView: VStreamItemPreviewView?
    private var contentPreviewView = ContentPreviewView()
    
    private func updatePreviewView() {
        if streamItem == nil && content == nil {
            streamItemPreviewView?.removeFromSuperview()
            contentPreviewView.removeFromSuperview()
            return
        }
        
        if let streamItem = streamItem {
            contentPreviewView.removeFromSuperview()
            if streamItemPreviewView?.canHandleStreamItem(streamItem) == true {
                streamItemPreviewView?.streamItem = streamItem
            }
            else {
                streamItemPreviewView?.removeFromSuperview()
                
                let newPreviewView = VStreamItemPreviewView(streamItem: streamItem)
                newPreviewView.onlyShowPreview = true
                newPreviewView.dependencyManager = dependencyManager
                newPreviewView.streamItem = streamItem
                contentView.addSubview(newPreviewView)
                
                streamItemPreviewView = newPreviewView
                
                setNeedsLayout()
            }
        }
        else if let content = content {
            streamItemPreviewView?.removeFromSuperview()
            addSubview(contentPreviewView)
            v_addFitToParentConstraintsToSubview(contentPreviewView)
            contentPreviewView.backgroundColor = .blackColor()
            contentPreviewView.content = content
        }
        
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
        streamItemPreviewView?.frame = contentView.bounds
    }
}
