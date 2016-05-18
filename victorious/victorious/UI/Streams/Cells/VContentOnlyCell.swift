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
            self.viewedContent = nil
        }
        updatePreviewView()
    }
    
    func setViewedContent(viewedContent: VViewedContent?) {
        if let viewedContent = viewedContent {
            self.viewedContent = viewedContent
            self.streamItem = nil
        }
        updatePreviewView()
    }
    
    private var streamItem: VStreamItem?
    private var viewedContent: VViewedContent?
    
    // MARK: - Dependency manager
    
    var dependencyManager: VDependencyManager?
    
    // MARK: - Views
    
    private var streamItemPreviewView: VStreamItemPreviewView?
    private var viewedContentPreviewView: UIView?
    
    private func updatePreviewView() {
        if streamItem == nil && viewedContent == nil {
            streamItemPreviewView?.removeFromSuperview()
            viewedContentPreviewView?.removeFromSuperview()
            return
        }
        
        if let streamItem = streamItem {
            viewedContentPreviewView?.removeFromSuperview()
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
        else if viewedContent != nil {
            streamItemPreviewView?.removeFromSuperview()
            viewedContentPreviewView?.removeFromSuperview()
            viewedContentPreviewView = UIImageView()
            addSubview(viewedContentPreviewView!)
            v_addFitToParentConstraintsToSubview(viewedContentPreviewView!)
            
            let minWidth = UIScreen.mainScreen().bounds.size.width
            
            if let preview = viewedContent?.content?.previewImageWithMinimumWidth(minWidth),
                let previewRemoteURL = preview.imageURL,
                let previewImageURL = NSURL(string: previewRemoteURL) {
                (viewedContentPreviewView as! UIImageView).sd_setImageWithURL(previewImageURL)
            }
        }
        
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
        streamItemPreviewView?.frame = contentView.bounds
    }
}
