//
//  MarqueeView.swift
//  victorious
//
//  Created by Mariana Lenetis on 8/24/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class MarqueeView: UIView {
    private var authorLabelA = UILabel()
    private var authorLabelB = UILabel()
    private var titleLabelA = UILabel()
    private var titleLabelB = UILabel()
    var maxAnimationDuration = 0.0

    private struct Constants {
        static let padding = CGFloat(10.0)
        static let gradientWidth = CGFloat(10.0)
        static let authorFont = UIFont.systemFontOfSize(14.0, weight: UIFontWeightSemibold)
        static let titleFont = UIFont.systemFontOfSize(12.0, weight: UIFontWeightRegular)
    }

    private lazy var gradientView: VLinearGradientView = {
        let gradientView = VLinearGradientView()
        gradientView.setColors([UIColor.clearColor(), UIColor.whiteColor(), UIColor.whiteColor(), UIColor.clearColor()])
        gradientView.startPoint = CGPoint(x: 0, y: 0.5)
        gradientView.endPoint = CGPoint(x: 1, y: 0.5)
        return gradientView
    }()

    required init?(coder aDecoder: NSCoder) {
        authorLabelA.font = Constants.authorFont
        authorLabelB.font = Constants.authorFont
        titleLabelA.font = Constants.titleFont
        titleLabelB.font = Constants.titleFont

        super.init(coder: aDecoder)

        addSubview(authorLabelA)
        addSubview(authorLabelB)
        addSubview(titleLabelA)
        addSubview(titleLabelB)

        backgroundColor = UIColor.clearColor()
        clipsToBounds = true
    }

    func update(author author: String, title: String) {
        removeAnimations()
        authorLabelA.text = author
        authorLabelB.text = author

        let authorLabelSize = authorLabelA.intrinsicContentSize()
        authorLabelA.frame = CGRect(x: Constants.gradientWidth,
                                    y: 0.0,
                                    width: authorLabelSize.width,
                                    height: authorLabelSize.height)

        authorLabelB.frame = CGRect(x: Constants.gradientWidth + authorLabelSize.width + Constants.padding,
                                    y: 0.0,
                                    width: authorLabelSize.width,
                                    height: authorLabelSize.height)

        titleLabelA.text = title
        titleLabelB.text = title

        let titleLabelSize = titleLabelA.intrinsicContentSize()
        titleLabelA.frame = CGRect(x: Constants.gradientWidth,
                                   y: authorLabelSize.height,
                                   width: titleLabelSize.width,
                                   height: titleLabelSize.height)

        titleLabelB.frame = CGRect(x: Constants.gradientWidth + titleLabelSize.width + Constants.padding,
                                   y: authorLabelSize.height,
                                   width: titleLabelSize.width,
                                   height: titleLabelSize.height)

        let shouldAnimateAuthor = authorLabelSize.width > frame.size.width
        let shouldAnimateTitle = titleLabelSize.width > frame.size.width

        addGradientView()

        authorLabelB.hidden = !shouldAnimateAuthor
        titleLabelB.hidden = !shouldAnimateTitle

        if shouldAnimateAuthor {
            animate(aLabel: authorLabelA, bLabel: authorLabelB)
        }

        if shouldAnimateTitle {
            animate(aLabel: titleLabelA, bLabel: titleLabelB)
        }
    }

    func removeAnimations() {
        maxAnimationDuration = 0.0
        authorLabelA.layer.removeAllAnimations()
        authorLabelB.layer.removeAllAnimations()
        titleLabelA.layer.removeAllAnimations()
        titleLabelB.layer.removeAllAnimations()
    }
}

// MARK: - Private

private extension MarqueeView {
    private func animate(aLabel aLabel: UILabel, bLabel: UILabel) {
        let labelSize = aLabel.intrinsicContentSize()
        let paddedWidth = labelSize.width + Constants.padding

        var endLabelAFrame = aLabel.frame
        endLabelAFrame.origin.x -= paddedWidth

        let endLabelBFrame = aLabel.frame

        let initialDelay = 3.0
        let duration = animationDuration(for: paddedWidth)
        maxAnimationDuration = max(maxAnimationDuration, duration + initialDelay)

        UIView.animateWithDuration(duration, delay: initialDelay, options: .CurveLinear, animations: {
            aLabel.frame = endLabelAFrame
            bLabel.frame = endLabelBFrame
        }) { (finish) in }
    }

    private func animationDuration(for width: CGFloat) -> Double {
        let speed = 30.0
        return Double(width) / speed
    }

    private func addGradientView() {
        gradientView.frame = bounds
        let stop = (Constants.gradientWidth)/frame.size.width
        let nextStop = 1.0 - stop
        gradientView.locations = [0.0, stop, nextStop, 1.0]
        maskView = gradientView
    }
}
