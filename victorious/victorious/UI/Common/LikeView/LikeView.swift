//
//  LikeView.swift
//  victorious
//
//  Created by Mariana Lenetis on 9/16/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

enum LikeViewAlignment {
    case left
    case center

    var imageLeadingPadding: CGFloat {
        switch self {
            case .left: return 0.0
            case .center: return 0.0
        }
    }

    var countLeadingPadding: CGFloat {
        switch self {
            case .left: return 4.0
            case .center: return 4.0
        }
    }
}

/// A class to display content like count and like image

final class LikeView: UIView {

    // MARK: - AnimationFrames

    static let animationFrames: [UIImage]? = {
        guard let
            f00 = UIImage(named: "flutter_hearts_00"),
            f01 = UIImage(named: "flutter_hearts_01"),
            f02 = UIImage(named: "flutter_hearts_02"),
            f03 = UIImage(named: "flutter_hearts_03"),
            f04 = UIImage(named: "flutter_hearts_04"),
            f05 = UIImage(named: "flutter_hearts_05"),
            f06 = UIImage(named: "flutter_hearts_06"),
            f07 = UIImage(named: "flutter_hearts_07"),
            f08 = UIImage(named: "flutter_hearts_08"),
            f09 = UIImage(named: "flutter_hearts_09"),
            f10 = UIImage(named: "flutter_hearts_10"),
            f11 = UIImage(named: "flutter_hearts_11"),
            f12 = UIImage(named: "flutter_hearts_12"),
            f13 = UIImage(named: "flutter_hearts_13"),
            f14 = UIImage(named: "flutter_hearts_14")
        else {
            return nil
        }
        return [f00, f01, f02, f03, f04, f05, f06, f07, f08, f09, f10, f11, f12, f13, f14]
    }()

    // MARK: - Constants

    private struct Constants {
        static let font: UIFont = UIFont(name: ".SFUIText-Regular", size: 12.0)
            ?? UIFont.systemFontOfSize(12.0, weight: UIFontWeightRegular)
    }

    // MARK: - Views

    private let imageView = UIImageView()
    private let countLabel = UILabel()

    private lazy var animationImageView: UIImageView = {
        return UIImageView()
    }()

    // MARK: - Properties

    private var selectedIcon: UIImage?
    private var unselectedIcon: UIImage?
    private var alignment = LikeViewAlignment.center

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

    init(frame: CGRect, textColor: UIColor, alignment: LikeViewAlignment, selectedIcon: UIImage? = nil, unselectedIcon: UIImage? = nil) {
        super.init(frame: frame)

        addSubview(imageView)
        addSubview(countLabel)

        countLabel.font = Constants.font
        countLabel.textAlignment = .Left
        self.textColor = textColor
        self.selectedIcon = selectedIcon
        self.unselectedIcon = unselectedIcon
        self.alignment = alignment
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        assertionFailure("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        let originX = alignment == .center
            ? bounds.center.x - (imageView.intrinsicContentSize().width / 2)
            : alignment.imageLeadingPadding

        imageView.frame = CGRect(
            x: originX,
            y: bounds.center.y - (imageView.intrinsicContentSize().height / 2),
            width: imageView.intrinsicContentSize().width,
            height: imageView.intrinsicContentSize().height
        )

        countLabel.frame = CGRect(
            x: imageView.frame.maxX + alignment.countLeadingPadding,
            y: bounds.center.y - (countLabel.intrinsicContentSize().height / 2),
            width: bounds.maxX - imageView.frame.maxX + alignment.countLeadingPadding,
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

    func updateAlignment(newAlignment: LikeViewAlignment) {
        alignment = newAlignment
    }

    // MARK: - Animation

    func animateLike() {
        animate()
    }

    // MARK: - Private helpers

    private func updateLikeCount(content: Content) {
        let likeCount = content.likeCount ?? 0
        let totalLikes = likeCount > 0 ? likeCount + content.currentUserLikeCount : content.currentUserLikeCount
        countLabel.text = totalLikes > 0 ? largeNumberFormatter.stringForInteger(totalLikes) : ""
        setNeedsLayout()
    }

    private func updateLikeImage(content: Content) {
        imageView.image = content.isLikedByCurrentUser ? selectedIcon : unselectedIcon
    }

    // MARK: - Private Animation

    private func animate() {
        guard let frames = LikeView.animationFrames, imageSize = frames.first?.size else {
            return
        }

        addAnimationView(of: imageSize)
        animationImageView.animationImages = LikeView.animationFrames
        animationImageView.animationDuration = 0.5
        animationImageView.animationRepeatCount = 1
        animationImageView.startAnimating()
    }

    private func addAnimationView(of size: CGSize) {
        if subviews.contains(animationImageView) {
            return
        }

        addSubview(animationImageView)
        animationImageView.frame = CGRect(
            center: imageView.center,
            size: size
        )
    }
}
