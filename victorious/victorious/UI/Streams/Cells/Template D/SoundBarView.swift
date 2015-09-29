//
//  SoundBarView.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 8/5/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

class SoundBarView : UIView {
    
    private var barLayers = [CAShapeLayer]()
    private var barPaths = [UIBezierPath]()
    private var isAnimating = false
    private var counter = 0
    
    /// Total number of vertical bars
    var numberOfBars = 4 {
        didSet {
            numberOfBars = max(numberOfBars, 1)
            reset(true)
            setNeedsLayout()
        }
    }
    
    /// Distance in points between sound bars
    var distanceBetweenBars = 1.0 {
        didSet {
            distanceBetweenBars = max(distanceBetweenBars, 0.0)
            reset(true)
            setNeedsLayout()
        }
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        for index in 0..<numberOfBars {
            let bar = CAShapeLayer()
            let path = pathForBarAtIndex(index, endpoint: randomEndpoint()).CGPath
            bar.path = path
            bar.fillColor = UIColor(red: 247, green: 247, blue: 247, alpha: 0.8).CGColor
            self.layer.addSublayer(bar)
            barLayers.append(bar)
        }
        
        startAnimating()
    }
    
    // MARK: Functions
    
    /// Start the animation
    func startAnimating() {
        
        if isAnimating {
            return
        }
        
        isAnimating = true
        
        for (index, bar) in barLayers.enumerate() {
            
            guard let barPath = bar.path else {
                continue
            }
            let currentPath = UIBezierPath(CGPath: barPath)
            let currentEndpoint = Double(currentPath.bounds.height)
            
            var newRandomEndpoint = currentEndpoint
            while abs(currentEndpoint - newRandomEndpoint) < Double(self.bounds.height / 4.0) {
                newRandomEndpoint = randomEndpoint()
            }
            
            let newPath = pathForBarAtIndex(index, endpoint: newRandomEndpoint)
            barPaths += [newPath]
            
            let animation = CABasicAnimation(keyPath: "path")
            animation.toValue = newPath.CGPath
            animation.duration = 0.3
            animation.delegate = self
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            animation.fillMode = kCAFillModeForwards
            animation.removedOnCompletion = false
            
            bar.addAnimation(animation, forKey: animation.keyPath)
        }
    }
    
    /// Stop the animation
    func stopAnimating() {
        for bar in barLayers {
            bar.removeAllAnimations()
        }
        isAnimating = false
    }
    
    // MARK: Helpers
    
    private func reset(clearBars: Bool) {
        
        barPaths = [UIBezierPath]()
        counter = 0
        isAnimating = false
        
        if clearBars {
            for bar in barLayers {
                bar.removeFromSuperlayer()
            }
            barLayers = [CAShapeLayer]()
        }
    }
    
    private func pathForBarAtIndex(barIndex: Int, endpoint: Double) -> UIBezierPath {
        let gapsWidth = distanceBetweenBars * Double(numberOfBars - 1)
        let totalBarWidth = Double(self.bounds.width) - gapsWidth
        let barWidth = totalBarWidth / Double(numberOfBars)
        return UIBezierPath(rect: CGRect(x: (barWidth + distanceBetweenBars) * Double(barIndex), y:  Double(self.bounds.height), width: barWidth, height: -endpoint))
    }
    
    private func randomEndpoint() -> Double {
        return Double(arc4random_uniform(UInt32(self.bounds.height)))
    }
    
    // MARK: Animation Delegate
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {

        if flag {
            let bar = barLayers[counter]
            bar.path = barPaths[counter].CGPath
            counter++
            if counter >= barLayers.count || counter >= barPaths.count {
                reset(false)
                startAnimating()
            }
        }
    }
}
