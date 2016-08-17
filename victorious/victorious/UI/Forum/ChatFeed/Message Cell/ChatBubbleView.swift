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
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    // MARK: - Subviews
    
    private let borderView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clearColor()
        return imageView
    }()
    
    let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clearColor()
        return view
    }()
    
    private func setupSubviews() {
        backgroundColor = .clearColor()
        layer.cornerRadius = Constants.bubbleCornerRadius
        contentView.layer.cornerRadius = Constants.bubbleCornerRadius
        contentView.clipsToBounds = true
        borderView.image = UIImage(named: "chat-cell-border")
        addSubview(contentView)
        addSubview(borderView)
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
        borderView.frame = bounds.insetBy(Constants.borderInsets)
    }
    
    // MARK: - Subviews
    
    override func addSubview(view: UIView) {
        if view == contentView || view == borderView {
            super.addSubview(view)
        } else {
            contentView.addSubview(view)
        }
    }
}
