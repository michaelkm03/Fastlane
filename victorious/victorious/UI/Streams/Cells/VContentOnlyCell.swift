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
    
    // MARK: - Content
    
    func setContent(content: ContentModel?) {
        if let content = content {
            self.content = content
        }
        updatePreviewView()
    }
    
    private var content: ContentModel?
    
    // MARK: - Dependency manager
    
    var dependencyManager: VDependencyManager? {
        didSet {
            if oldValue != dependencyManager {
                contentPreviewView.dependencyManager = dependencyManager
            }
        }
    }
    
    // MARK: - Views
    
    private var contentPreviewView = ContentPreviewView()
    
    private func updatePreviewView() {
        guard let content = content else {
            return
        }
        addSubview(contentPreviewView)
        v_addFitToParentConstraintsToSubview(contentPreviewView)
        contentPreviewView.content = content
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
    }
}
