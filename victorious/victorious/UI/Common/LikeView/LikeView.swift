//
//  LikeView.swift
//  victorious
//
//  Created by Mariana Lenetis on 9/16/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

/// A class to display content like count and like image

enum LikeViewAlignment {
    case left
    case center
}

final class LikeView: UIView {
    // MARK: - Constants

    private struct Constants {
        static let font: UIFont = UIFont(name: ".SFUIText-Regular", size: 12.0)
            ?? UIFont.systemFontOfSize(12.0, weight: UIFontWeightRegular)
        static let flutterFrameNames = [
            "flutter_hearts_00", "flutter_hearts_01", "flutter_hearts_02",
            "flutter_hearts_03", "flutter_hearts_04", "flutter_hearts_05",
            "flutter_hearts_06", "flutter_hearts_07", "flutter_hearts_08",
            "flutter_hearts_09", "flutter_hearts_10", "flutter_hearts_11",
            "flutter_hearts_12", "flutter_hearts_13", "flutter_hearts_14"
        ]
    }

    // MARK: - Views

    private let imageView = UIImageView()
    private let flutterImageView = UIImageView()
    private let countLabel = UILabel()
    private var flutterFrames = [UIImage]()

    // MARK: - Properties

    private var selectedIcon: UIImage?
    private var unselectedIcon: UIImage?
    private var alignment: LikeViewAlignment?

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

    init(frame: CGRect, textColor: UIColor, selectedIcon: UIImage? = nil, unselectedIcon: UIImage? = nil, alignment: LikeViewAlignment? = .center) {
        super.init(frame: frame)

        addSubview(imageView)
        addSubview(flutterImageView)
        addSubview(countLabel)

        countLabel.font = Constants.font
        self.textColor = textColor
        self.selectedIcon = selectedIcon
        self.unselectedIcon = unselectedIcon
        self.alignment = alignment
        self.flutterFrames = self.createFlutterFrames()
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

        let horizontalPadding: CGFloat
        if alignment == LikeViewAlignment.left {
            imageView.frame = CGRect(
                x: 3.0,
                y: bounds.center.y - (imageView.intrinsicContentSize().height / 2),
                width: imageView.intrinsicContentSize().width,
                height: imageView.intrinsicContentSize().height
            )

            horizontalPadding = CGFloat(0.0)
        } else {
            imageView.frame = CGRect(
                center: bounds.center,
                size: imageView.intrinsicContentSize()
            )

            horizontalPadding = CGFloat(4.0)
        }

        flutterImageView.image = flutterFrames.first
        flutterImageView.frame = CGRect(
            center: imageView.center,
            size: CGSize(
                width: flutterImageView.intrinsicContentSize().width,
                height: flutterImageView.intrinsicContentSize().height
            )
        )

        countLabel.frame = CGRect(
            x: imageView.frame.maxY + horizontalPadding,
            y: bounds.center.y - (countLabel.intrinsicContentSize().height / 2),
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

    // MARK - Animation

    func animateLike() {
        animateFlutterHearts()
    }

    private func animateFlutterHearts() {
        guard let imageSize = flutterFrames.first?.size else {
            return
        }

        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        UIGraphicsEndImageContext()

        flutterImageView.animationImages = flutterFrames
        flutterImageView.animationDuration = 0.5
        flutterImageView.animationRepeatCount = 1
        flutterImageView.startAnimating()
    }

    private func createFlutterFrames() -> [UIImage]{
        var images = [UIImage]()
        Constants.flutterFrameNames.forEach { (name) in
            if let image = UIImage(named: name) {
                images.append(image)
            }
        }
        
        return images
    }
}
