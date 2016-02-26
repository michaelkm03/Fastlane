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

extension CGRect {
    init(minX: CGFloat, minY: CGFloat, maxX: CGFloat, maxY: CGFloat ) {
        self.init(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
}

struct LeftAlignmentedLayout: AlignmentLayout {
    
    func layoutSubviews(cell: VMessageCollectionCell) {
        cell.textView.textAlignment = .Left
        
        cell.avatarView.frame = CGRect(
            x: cell.avatarEdges.left,
            y: cell.avatarEdges.top,
            width: cell.avatarView.bounds.width,
            height: cell.avatarView.bounds.height)
        
        cell.bubbleView.frame = CGRect(
            minX: cell.avatarView.frame.maxX + cell.bubbleEdges.left,
            minY: cell.avatarView.frame.minY,
            maxX: cell.bounds.width - cell.bubbleEdges.right,
            maxY: max(cell.bounds.height - cell.bubbleEdges.top, cell.avatarView.frame.maxY)
        )
        
        cell.textView.frame = cell.bubbleView.bounds
    }
}

struct RightAlignmentedLayout: AlignmentLayout {
    
    func layoutSubviews(cell: VMessageCollectionCell) {
        cell.textView.textAlignment = .Left
        
        cell.avatarView.frame = CGRect(
            x: cell.bounds.width - cell.avatarView.bounds.width - cell.avatarEdges.right,
            y: cell.bubbleEdges.top,
            width: cell.avatarView.bounds.width,
            height: cell.avatarView.bounds.height)
        
        cell.bubbleView.frame = CGRect(
            minX: cell.bubbleEdges.right,
            minY: cell.avatarView.frame.minY,
            maxX: cell.avatarView.frame.minX - cell.bubbleEdges.left,
            maxY: max(cell.bounds.height - cell.bubbleEdges.top, cell.avatarView.frame.maxY)
        )
        
        cell.textView.frame = cell.bubbleView.bounds
    }
}

class VMessageCollectionCell: UICollectionViewCell {
    
    static var suggestedReuseIdentifier = "VMessageCollectionCell"
    
    var alignmentLayout: AlignmentLayout! {
        didSet {
            alignmentLayout.layoutSubviews(self)
        }
    }
    
    let bubbleEdges = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 65)
    let avatarEdges = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    
    struct Style {
        let textColor: UIColor
        let backgroundColor: UIColor
        let font: UIFont
    }
    
    private var storyboardTextViewWidth: CGFloat!
    
    var style: Style! {
        didSet {
            textView.font = style.font
            textView.textColor = style.textColor
            
            bubbleView.backgroundColor = style.backgroundColor
            bubbleView.layer.cornerRadius = 5.0
            bubbleView.layer.borderColor = style.textColor.CGColor
            bubbleView.layer.borderWidth = 1.0
            
            avatarView.layer.cornerRadius = avatarView.bounds.width * 0.5
            avatarView.backgroundColor = UIColor.v_colorFromHexString("5e8d98")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        storyboardTextViewWidth = textView.bounds.width
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        alignmentLayout.layoutSubviews(self)
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
    
    @IBOutlet private(set) weak var textView: UITextView!
    @IBOutlet private weak var bubbleView: UIView!
    @IBOutlet private weak var avatarView: UIView!
    @IBOutlet private weak var nameLabel: UITextView!
    @IBOutlet private weak var timeLabel: UITextView!
    
    // MARK: - SelfSizingCell
    
    func cellSizeWithinBounds(bounds: CGRect) -> CGSize {
        var sizeNeeded = textViewSize
        sizeNeeded.width = bounds.width
        sizeNeeded.height += (bubbleEdges.top + bubbleEdges.bottom)
        return sizeNeeded
    }
    
    var textViewSize: CGSize {
        let maxTextWidth = bounds.width - bubbleEdges.left - bubbleEdges.right - 20
        let availableTextViewSize = CGSize(width: maxTextWidth, height: CGFloat.max)
        return textView.sizeThatFits( availableTextViewSize )
    }
}
