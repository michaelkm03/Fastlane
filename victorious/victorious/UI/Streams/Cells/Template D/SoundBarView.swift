//
//  SoundBarView.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 8/5/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

class SoundBarView : UIView {
    
    private var soundBars = [UIView]()
    private var endHeights = [CGFloat]()
    private var hasLaidOut = false
    private var isAnimating = false
    private let duration = 0.9
    
    /// Total number of vertical bars
    private var numberOfBars: Int!
    
    /// Distance in points between sound bars
    private var distanceBetweenBars: Double!
    
    init(numberOfBars: Int, distanceBetweenBars: Double) {
        super.init(frame: CGRectZero)
        self.numberOfBars = numberOfBars
        self.distanceBetweenBars = distanceBetweenBars
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.numberOfBars = 3
        self.distanceBetweenBars = 1.0
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        if !hasLaidOut {
            hasLaidOut = true
            
            for index in 0..<numberOfBars {
                let bar = UIView(frame: rectForBarAtIndex(index, endpoint: CGFloat(randomEndpoint())))
                bar.backgroundColor = UIColor(red: 247, green: 247, blue: 247, alpha: 0.8)
                addSubview(bar)
                soundBars.append(bar)
            }
        }
    }
    
    // MARK: Functions
    
    /// Stops the animation
    func stopAnimating() {
        
        if (!isAnimating) {
            return
        }
        
        for view in soundBars {
            view.layer.removeAllAnimations()
        }
        isAnimating = false
    }
    
    /// Starts the animation
    func startAnimating() {
        
        if isAnimating {
            return
        }
        
        isAnimating = true
        for index in 0..<numberOfBars {
            let view = soundBars[index]
            let originalFrame = view.frame
            let currentEndpoint = view.frame.height
            let ratio = Double(currentEndpoint) / Double(bounds.height)
            let adjustedDuration = (1.0 - ratio)  * duration
            UIView.animateKeyframesWithDuration(adjustedDuration, delay: 0, options: [.Repeat], animations: { () in
                UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0.5) {
                    view.frame = self.rectForBarAtIndex(index, endpoint: self.bounds.height)
                }
                UIView.addKeyframeWithRelativeStartTime(0.5, relativeDuration: 0.5) {
                    view.frame = originalFrame
                }
            },
            completion: nil)
        }
    }
    
    private func rectForBarAtIndex(barIndex: Int, endpoint: CGFloat) -> CGRect {
        let gapsWidth = distanceBetweenBars * Double(numberOfBars - 1)
        let totalBarWidth = Double(bounds.width) - gapsWidth
        let barWidth = totalBarWidth / Double(numberOfBars)
        return CGRect(x: (barWidth + distanceBetweenBars) * Double(barIndex), y:  Double(self.bounds.height), width: barWidth, height: -Double(endpoint))
    }
    
    private func randomEndpoint() -> Double {
        return Double(arc4random_uniform(40)) / 100.0 * Double(bounds.height)
    }
}
