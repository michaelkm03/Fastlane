//
//  MarqueeView.swift
//  victorious
//
//  Created by Mariana Lenetis on 8/24/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

/// A view that contains a scrolling author and title label, each label scrolls only when the size of the labels is larger than the size of the view.
///
/// Usage:  updateLabels(author: author, title: title) - sets the label text and their frames, returns the width of the longest label
///         scroll() - determines if the labels should scroll and animates if needed, also applies gradient if label should scroll
///         maxAnimationDuration = 0.0 - set to the scroll duration

class MarqueeView: UIView {

    // MARK: - Constants

    fileprivate struct Constants {
        static let padding = CGFloat(10.0)
        static let gradientWidth = CGFloat(2.0)
        static let authorFont = UIFont.systemFont(ofSize: 14.0, weight: UIFontWeightSemibold)
        static let titleFont = UIFont.systemFont(ofSize: 12.0, weight: UIFontWeightRegular)
    }

    // MARK: - Views

    fileprivate var authorLabelA = UILabel()
    fileprivate var authorLabelB = UILabel()
    fileprivate var titleLabelA = UILabel()
    fileprivate var titleLabelB = UILabel()

    fileprivate lazy var gradientView: VLinearGradientView = {
        let gradientView = VLinearGradientView()
        gradientView.setColors([UIColor.clear, UIColor.white, UIColor.white, UIColor.clear])
        gradientView.startPoint = CGPoint(x: 0, y: 0.5)
        gradientView.endPoint = CGPoint(x: 1, y: 0.5)
        return gradientView
    }()

    // MARK: - Animation

    var maxAnimationDuration = 0.0

    // MARK: - Initialization

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    // MARK: - Configuration

    /// Sets the label text and their frames, returns the width of the longest label.
    func updateLabels(author: String, title: String) -> CGFloat {
        removeAnimations()
        authorLabelA.text = author
        authorLabelB.text = author

        let authorLabelSize = authorLabelA.intrinsicContentSize
        authorLabelA.frame = CGRect(
            x: Constants.gradientWidth,
            y: 0.0,
            width: Constants.gradientWidth + authorLabelSize.width,
            height: authorLabelSize.height
        )

        authorLabelB.frame = CGRect(
            x: Constants.gradientWidth + authorLabelSize.width + Constants.padding,
            y: 0.0,
            width: authorLabelSize.width,
            height: authorLabelSize.height
        )

        titleLabelA.text = title
        titleLabelB.text = title

        let titleLabelSize = titleLabelA.intrinsicContentSize
        titleLabelA.frame = CGRect(
            x: Constants.gradientWidth,
            y: authorLabelSize.height,
            width: Constants.gradientWidth + titleLabelSize.width,
            height: titleLabelSize.height
        )

        titleLabelB.frame = CGRect(
            x: Constants.gradientWidth + titleLabelSize.width + Constants.padding,
            y: authorLabelSize.height,
            width: titleLabelSize.width,
            height: titleLabelSize.height
        )

        return max(authorLabelA.frame.size.width, titleLabelA.frame.size.width)
    }

    // MARK: - Animation

    func scroll() {
        let shouldAnimateAuthor = floor(authorLabelA.frame.size.width) > floor(frame.size.width)
        let shouldAnimateTitle = floor(titleLabelA.frame.size.width) > floor(frame.size.width)

        if shouldAnimateAuthor || shouldAnimateTitle {
            addGradientView()
        }

        authorLabelB.isHidden = !shouldAnimateAuthor
        titleLabelB.isHidden = !shouldAnimateTitle

        if shouldAnimateAuthor {
            animate(aLabel: authorLabelA, bLabel: authorLabelB)
        }

        if shouldAnimateTitle {
            animate(aLabel: titleLabelA, bLabel: titleLabelB)
        }
    }

    // MARK:
    // MARK: - Private

    // MARK: - Initialization

    fileprivate func setup() {
        authorLabelA.font = Constants.authorFont
        authorLabelB.font = Constants.authorFont
        titleLabelA.font = Constants.titleFont
        titleLabelB.font = Constants.titleFont

        addSubview(authorLabelA)
        addSubview(authorLabelB)
        addSubview(titleLabelA)
        addSubview(titleLabelB)

        backgroundColor = UIColor.clear
        clipsToBounds = true
    }

    // MARK: - Animation

    fileprivate func animate(aLabel: UILabel, bLabel: UILabel) {
        let labelSize = aLabel.intrinsicContentSize
        let paddedWidth = labelSize.width + Constants.padding

        let endALabelFrame = aLabel.frame.offsetBy(dx: -paddedWidth, dy: 0.0)
        let endBLabelFrame = aLabel.frame

        let initialDelay = 3.0
        let duration = animationDuration(for: paddedWidth)
        maxAnimationDuration = max(maxAnimationDuration, duration + initialDelay)

        UIView.animate(withDuration: duration, delay: initialDelay, options: .curveLinear, animations: {
            aLabel.frame = endALabelFrame
            bLabel.frame = endBLabelFrame
        }) { [weak self] (finished) in
            if finished {
                self?.maxAnimationDuration = 0.0
            }
        }
    }

    fileprivate func animationDuration(for width: CGFloat) -> Double {
        let speed = 30.0
        return Double(width) / speed
    }

    fileprivate func removeAnimations() {
        maxAnimationDuration = 0.0
        authorLabelA.layer.removeAllAnimations()
        authorLabelB.layer.removeAllAnimations()
        titleLabelA.layer.removeAllAnimations()
        titleLabelB.layer.removeAllAnimations()
    }

    // MARK: - Configuration

    fileprivate func addGradientView() {
        gradientView.frame = bounds
        let stop = Constants.gradientWidth / frame.size.width
        let nextStop = 1.0 - stop
        gradientView.locations = [0.0, stop, nextStop, 1.0]
        mask = gradientView
    }
}
