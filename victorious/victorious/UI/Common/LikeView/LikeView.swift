//
//  LikeView.swift
//  victorious
//
//  Created by Mariana Lenetis on 9/16/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

/// A class to display content like count and like image
final class LikeView: UIView {
    // MARK: - Views

    private let imageView = UIImageView()
    private let countLabel = UILabel()

    // MARK: - Properties

    private var selectedIcon: UIImage?
    private var unselectedIcon: UIImage?

    private var font: UIFont? {
        get {
            return countLabel.font
        }

        set {
            countLabel.font = newValue
        }
    }

    private var textColor: UIColor {
        get {
            return countLabel.textColor
        }

        set {
            countLabel.textColor = newValue
        }
    }

    // MARK: - Formatters

    let largeNumberFormatter = VLargeNumberFormatter()

    // MARK: - Initialization

    init(frame: CGRect, textColor: UIColor, font: UIFont? = UIFont.preferredFontForTextStyle("UIFontTextStyleCaption1"), selectedIcon: UIImage? = nil, unselectedIcon: UIImage? = nil) {
        super.init(frame: frame)

        addSubview(imageView)
        addSubview(countLabel)

        self.textColor = textColor
        self.font = font
        self.selectedIcon = selectedIcon
        self.unselectedIcon = unselectedIcon
    }

    init() {
        super.init(frame: CGRect.zero)
        assertionFailure("init() has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        assertionFailure("init(frame:) has not been implemented")
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        assertionFailure("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        imageView.frame = CGRect(
            center: bounds.center,
            size: imageView.intrinsicContentSize()
        )

        let horizontalPadding = CGFloat(3.0)
        let verticalPadding = CGFloat(8.0)
        countLabel.frame = CGRect(
            x: CGRectGetMaxX(imageView.frame) - horizontalPadding,
            y: CGRectGetMaxY(imageView.frame) - verticalPadding,
            width: countLabel.intrinsicContentSize().width,
            height: countLabel.intrinsicContentSize().height
        )
    }

    // MARK: - UI Updates

    func updateLikeStatus(content: Content?) {
        guard let content = content else {
            return
        }

        updateLikeImage(content)
        updateLikeCount(content)
    }

    // MARK - Private helpers

    private func updateLikeCount(content: Content) {
        let likeCount = content.likeCount ?? 0
        let totalLikes = likeCount > 0 ? likeCount + content.currentUserLikeCount : content.currentUserLikeCount
        countLabel.text = totalLikes > 0 ? largeNumberFormatter.stringForInteger(totalLikes) : ""
        setNeedsLayout()
    }

    private func updateLikeImage(content: Content) {
        imageView.image = content.isLikedByCurrentUser ? selectedIcon : unselectedIcon
    }
}
