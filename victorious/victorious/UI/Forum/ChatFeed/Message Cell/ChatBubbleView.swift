//
//  ChatBubbleView.swift
//  victorious
//
//  Created by Jarod Long on 7/5/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

/// A view that renders as an empty chat bubble.
///
/// Subviews can be added to `contentView` to display content in the bubble.
///
class ChatBubbleView: UIView {
    private struct Constants {
        static let borderInsets = UIEdgeInsets(top: -1.0, left: -2.0, bottom: -3.0, right: -2.0)
        static let bubbleCornerRadius = CGFloat(6.0)
    }
    
    // MARK: - Initializing
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = Constants.bubbleCornerRadius
        contentView.layer.cornerRadius = Constants.bubbleCornerRadius
        contentView.clipsToBounds = true
        borderView.image = UIImage(named: "chat-cell-border")
        addSubview(contentView)
        addSubview(borderView)
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported.")
    }
    
    // MARK: - Subviews
    
    private let borderView = UIImageView()
    
    let contentView = UIView()
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
        borderView.frame = bounds.insetBy(Constants.borderInsets)
    }
}
