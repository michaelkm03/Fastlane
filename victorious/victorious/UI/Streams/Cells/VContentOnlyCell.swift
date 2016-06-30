//
//  VContentOnlyCell.swift
//  victorious
//
//  Created by Jarod Long on 4/5/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

/// A collection view cell that only shows a stream item's content.
class VContentOnlyCell: UICollectionViewCell, ContentCell {
    // MARK: - Constants
    
    private static let cornerRadius: CGFloat = 6.0
    private static let highlightAlpha: CGFloat = 0.2
    
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
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = VContentOnlyCell.cornerRadius
    }
    
    // MARK: - Content
    
    var content: ContentModel? {
        didSet {
            updatePreviewView()
        }
    }
    
    // MARK: - Dependency manager
    
    var dependencyManager: VDependencyManager? {
        didSet {
            if dependencyManager != nil && dependencyManager != oldValue {
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
        contentPreviewView.frame = self.bounds
        contentView.addSubview(contentPreviewView)
        contentPreviewView.content = content
    }
    
    // MARK: Highlighting
    
    override var highlighted: Bool {
        didSet {
            contentView.alpha = highlighted ? VContentOnlyCell.highlightAlpha : 1.0
        }
    }
}
