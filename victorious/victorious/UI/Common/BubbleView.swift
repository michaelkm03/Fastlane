//
//  BubbleView.swift
//  victorious
//
//  Created by Jarod Long on 7/5/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

/// A view that renders as an empty chat bubble.
///
/// Subviews can be added to `contentView` to display content in the bubble.
///
class BubbleView: UIView {
    fileprivate struct Constants {
        static let borderInsets = UIEdgeInsets(top: -1.0, left: -2.0, bottom: -3.0, right: -2.0)
        static let bubbleCornerRadius = CGFloat(6.0)
    }
    
    // MARK: - Initializing
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView = UIView()
        borderView = UIImageView()
        backgroundColor = .clearColor()
        setupSubviews()
        contentView.backgroundColor = .clearColor()
        borderView.backgroundColor = .clearColor()
        addSubview(contentView)
        addSubview(borderView)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupSubviews()
    }
    
    // MARK: - Subviews
    
    @IBOutlet fileprivate var borderView: UIImageView!
    
    @IBOutlet var contentView: UIView!
    
    fileprivate func setupSubviews() {
        layer.cornerRadius = Constants.bubbleCornerRadius
        contentView.layer.cornerRadius = Constants.bubbleCornerRadius
        contentView.clipsToBounds = true
        borderView.image = UIImage(named: "chat-cell-border")
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView?.frame = bounds
        borderView?.frame = bounds.insetBy(Constants.borderInsets)
    }
}
