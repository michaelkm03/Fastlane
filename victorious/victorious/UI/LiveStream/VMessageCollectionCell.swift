//
//  VMessageCollectionCell.swift
//  victorious
//
//  Created by Patrick Lynch on 2/19/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

@objc protocol SelfSizingCell: NSObjectProtocol {
    func cellSizeWithinBounds(bounds: CGRect) -> CGSize
}

enum ChatAlignment {
    case Left, Right
    
    var textAlignment: NSTextAlignment {
        switch self {
        case .Left:
            return .Left
        case .Right:
            return .Right
        }
    }
}

struct StreamCellAligner {
    
    let cell: VMessageCollectionCell
    
    init(cell: VMessageCollectionCell) {
        self.cell = cell
    }
    
    func align(alignment: ChatAlignment) {
        cell.textView.textAlignment = alignment.textAlignment
        
        switch alignment {
        case .Left:
            // Activate constraints for left alignment
            cell.constraintAvatarLeading?.active = true
            cell.constraintHorizontalSpacingLeft?.active = true
            cell.constraintBubbleTrailing?.active = true
            
            // Deactivate constraints for right alignment
            cell.constraintAvatarTrailing?.active = false
            cell.constraintBubbleLeading?.active = false
            cell.constraintHorizontalSpacingRight?.active = false
            
        case .Right:
            // Aactivate constraints for right alignment
            cell.constraintAvatarTrailing?.active = true
            cell.constraintBubbleLeading?.active = true
            cell.constraintHorizontalSpacingRight?.active = true
            
            // Deactivate constraints for left alignment
            cell.constraintAvatarLeading?.active = false
            cell.constraintHorizontalSpacingLeft?.active = false
            cell.constraintBubbleTrailing?.active = false
        }
    }
}

class VMessageCollectionCell: UICollectionViewCell {
    
    static var suggestedReuseIdentifier = "VMessageCollectionCell"
    
    struct Style {
        let textColor: UIColor
        let backgroundColor: UIColor
        let font: UIFont
    }
    
    var style: Style! {
        didSet {
            textView.font = style.font
            textView.textColor = style.textColor
            
            bubbleView.backgroundColor = style.backgroundColor
            bubbleView.layer.cornerRadius = 5.0
            bubbleView.layer.borderColor = style.textColor.CGColor
            bubbleView.layer.borderWidth = 1.0
            
            avatarView.layer.cornerRadius = avatarView.bounds.width * 0.5
        }
    }
    
    struct ViewData {
        let text: String
        let createdAt: NSDate
        let username: String
    }
    
    var viewData: ViewData! {
        didSet {
            textView.text = viewData.text
        }
    }
    
    // Constraints for left alignment
    @IBOutlet private(set) weak var constraintAvatarLeading: NSLayoutConstraint!
    @IBOutlet private(set) weak var constraintHorizontalSpacingLeft: NSLayoutConstraint!
    @IBOutlet private(set) weak var constraintBubbleTrailing: NSLayoutConstraint!
    
    // Constraints for right alignment
    @IBOutlet private(set) weak var constraintAvatarTrailing: NSLayoutConstraint!
    @IBOutlet private(set) weak var constraintBubbleLeading: NSLayoutConstraint!
    @IBOutlet private(set) weak var constraintHorizontalSpacingRight: NSLayoutConstraint!
    
    @IBOutlet private(set) weak var textView: UITextView!
    @IBOutlet private weak var bubbleView: UIView!
    @IBOutlet private weak var avatarView: UIView!
    
    // MARK: - SelfSizingCell
    
    func cellSizeWithinBounds(bounds: CGRect) -> CGSize {
        var sizeNeeded = textView.sizeThatFits(CGSize(width: bounds.width, height: CGFloat.max))
        sizeNeeded.width = bounds.width
        sizeNeeded.height += textView.frame.minY + self.bounds.maxY - textView.frame.maxY
        return sizeNeeded
    }
}
