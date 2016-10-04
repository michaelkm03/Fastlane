//
//  VContentOnlyCell.swift
//  victorious
//
//  Created by Jarod Long on 4/5/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
import VictoriousIOSSDK

/// A collection view cell that only shows a stream item's content.
class VContentOnlyCell: UICollectionViewCell, ContentCell {
    // MARK: - Constants
    
    fileprivate static let cornerRadius: CGFloat = 6.0
    fileprivate static let highlightAlpha: CGFloat = 0.2
    
    // MARK: - Initializing
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    fileprivate func setup() {
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = VContentOnlyCell.cornerRadius
    }
    
    // MARK: - Content
    
    var content: Content? {
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
    
    fileprivate var contentPreviewView = ContentPreviewView()
    
    fileprivate func updatePreviewView() {
        guard let content = content else {
            return
        }
        
        setNeedsLayout()
        layoutIfNeeded()
        
        contentView.addSubview(contentPreviewView)
        contentPreviewView.content = content
    }
    
    // MARK: - View Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentPreviewView.frame = contentView.bounds
    }
    
    // MARK: Highlighting
    
    override var isHighlighted: Bool {
        didSet {
            contentView.alpha = isHighlighted ? VContentOnlyCell.highlightAlpha : 1.0
        }
    }
}
