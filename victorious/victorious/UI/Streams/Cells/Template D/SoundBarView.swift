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
    private var hasLaidOut = false
    private var shouldRepeat = true
    private var isAnimating = false
    
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
        self.numberOfBars = 4
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
                self.addSubview(bar)
                soundBars.append(bar)
            }
        }
    }
    
    // MARK: Functions
    
    /// Stops the animation
    func stopAnimating() {
        shouldRepeat = false
    }
    
    /// Start the animation
    func startAnimating() {
        
        if isAnimating {
            return
        }
        
        shouldRepeat = true
        isAnimating = true
        UIView.animateWithDuration(0.3,
            delay: 0,
            options: [.BeginFromCurrentState, .CurveEaseInOut],
            animations: {
                for index in 0..<self.numberOfBars {
                    let view = self.soundBars[index]
                    let currentEndpoint = view.frame.height
                    var newRandomEndpoint = currentEndpoint
                    while abs(currentEndpoint - newRandomEndpoint) < self.bounds.height / 4.0 {
                        newRandomEndpoint = CGFloat(self.randomEndpoint())
                    }
                    
                    view.frame = self.rectForBarAtIndex(index, endpoint: newRandomEndpoint)
                }
            },
            completion: { completed in
                self.isAnimating = false
                if self.shouldRepeat {
                    self.startAnimating()
                }
            })
    }
    
    private func rectForBarAtIndex(barIndex: Int, endpoint: CGFloat) -> CGRect {
        let gapsWidth = distanceBetweenBars * Double(numberOfBars - 1)
        let totalBarWidth = Double(self.bounds.width) - gapsWidth
        let barWidth = totalBarWidth / Double(numberOfBars)
        return CGRect(x: (barWidth + distanceBetweenBars) * Double(barIndex), y:  Double(self.bounds.height), width: barWidth, height: -Double(endpoint))
    }
    
    private func randomEndpoint() -> Double {
        return Double(arc4random_uniform(UInt32(self.bounds.height)))
    }
}
