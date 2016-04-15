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
    
    // MARK: - Sequence
    
    var streamItem: VStreamItem? {
        didSet {
            updatePreviewView()
        }
    }
    
    // MARK: - Dependency manager
    
    var dependencyManager: VDependencyManager?
    
    // MARK: - Views
    
    private var previewView: VStreamItemPreviewView?
    
    private func updatePreviewView() {
        guard let streamItem = streamItem else {
            previewView?.removeFromSuperview()
            return
        }
        
        if previewView?.canHandleStreamItem(streamItem) == true {
            previewView?.streamItem = streamItem
        }
        else {
            previewView?.removeFromSuperview()
            
            let newPreviewView = VStreamItemPreviewView(streamItem: streamItem)
            newPreviewView.onlyShowPreview = true
            newPreviewView.dependencyManager = dependencyManager
            newPreviewView.streamItem = streamItem
            contentView.addSubview(newPreviewView)
            
            previewView = newPreviewView
            
            setNeedsLayout()
        }
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
        previewView?.frame = contentView.bounds
    }
}
