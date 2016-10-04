//
//  LikeView.swift
//  victorious
//
//  Created by Mariana Lenetis on 9/16/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
import VictoriousIOSSDK

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
            let f01 = UIImage(named: "flutter_hearts_01"),
            let f02 = UIImage(named: "flutter_hearts_02"),
            let f03 = UIImage(named: "flutter_hearts_03"),
            let f04 = UIImage(named: "flutter_hearts_04"),
            let f05 = UIImage(named: "flutter_hearts_05"),
            let f06 = UIImage(named: "flutter_hearts_06"),
            let f07 = UIImage(named: "flutter_hearts_07"),
            let f08 = UIImage(named: "flutter_hearts_08"),
            let f09 = UIImage(named: "flutter_hearts_09"),
            let f10 = UIImage(named: "flutter_hearts_10"),
            let f11 = UIImage(named: "flutter_hearts_11"),
            let f12 = UIImage(named: "flutter_hearts_12"),
            let f13 = UIImage(named: "flutter_hearts_13"),
            let f14 = UIImage(named: "flutter_hearts_14")
        else {
            return nil
        }
        return [f00, f01, f02, f03, f04, f05, f06, f07, f08, f09, f10, f11, f12, f13, f14]
    }()

    // MARK: - Constants

    fileprivate struct Constants {
        static let font: UIFont = UIFont(name: ".SFUIText-Regular", size: 12.0)
            ?? UIFont.systemFont(ofSize: 12.0, weight: UIFontWeightRegular)
    }

    // MARK: - Views

    fileprivate let imageView = UIImageView()
    fileprivate let countLabel = UILabel()

    fileprivate lazy var animationImageView: UIImageView = {
        return UIImageView()
    }()

    // MARK: - Properties
    
    private var selectedIcon: UIImage?
    private var unselectedIcon: UIImage?
    private var alignment = LikeViewAlignment.center {
        didSet {
            setNeedsLayout()
        }
    }

    fileprivate var textColor: UIColor {
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
        countLabel.textAlignment = .left
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
            ? bounds.center.x - (imageView.intrinsicContentSize.width / 2)
            : alignment.imageLeadingPadding

        imageView.frame = CGRect(
            x: originX,
            y: bounds.center.y - (imageView.intrinsicContentSize.height / 2),
            width: imageView.intrinsicContentSize.width,
            height: imageView.intrinsicContentSize.height
        )

        countLabel.frame = CGRect(
            x: imageView.frame.maxX + alignment.countLeadingPadding,
            y: bounds.center.y - (countLabel.intrinsicContentSize.height / 2),
            width: bounds.maxX - imageView.frame.maxX + alignment.countLeadingPadding,
            height: countLabel.intrinsicContentSize.height
        )
    }

    // MARK: - UI Updates

    func updateLikeStatus(_ content: Content?) {
        guard let content = content else {
            return
        }

        updateLikeImage(content)
        updateLikeCount(content)
    }

    func updateAlignment(_ newAlignment: LikeViewAlignment) {
        alignment = newAlignment
    }

    // MARK: - Animation

    func animateLike() {
        animate()
    }

    // MARK: - Private helpers

    fileprivate func updateLikeCount(_ content: Content) {
        let likeCount = content.likeCount ?? 0
        let totalLikes = likeCount > 0 ? likeCount + content.currentUserLikeCount : content.currentUserLikeCount
        countLabel.text = totalLikes > 0 ? largeNumberFormatter.string(for: totalLikes) : ""
        setNeedsLayout()
    }

    fileprivate func updateLikeImage(_ content: Content) {
        imageView.image = content.isLikedByCurrentUser ? selectedIcon : unselectedIcon
    }

    // MARK: - Private Animation

    fileprivate func animate() {
        guard let frames = LikeView.animationFrames, let imageSize = frames.first?.size else {
            return
        }

        addAnimationView(of: imageSize)
        animationImageView.animationImages = LikeView.animationFrames
        animationImageView.animationDuration = 0.5
        animationImageView.animationRepeatCount = 1
        animationImageView.startAnimating()
    }

    private func addAnimationView(of size: CGSize) {
        if !subviews.contains(animationImageView) {
            addSubview(animationImageView)
        }

        animationImageView.frame = CGRect(
            origin: imageView.center,
            size: size
        )

        setNeedsLayout()
    }
}
