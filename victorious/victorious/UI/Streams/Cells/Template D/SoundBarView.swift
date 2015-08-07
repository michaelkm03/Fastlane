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
    
    var numberOfBars = 5 {
        didSet {
            numberOfBars = max(numberOfBars, 1)
            reset()
            setNeedsLayout()
        }
    }
    
    var distanceBetweenBars = 1.0 {
        didSet {
            distanceBetweenBars = max(distanceBetweenBars, 0.0)
            reset()
            setNeedsLayout()
        }
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        for index in 0...numberOfBars-1 {
            let bar = CAShapeLayer()
            let path = barPath(index, endpoint: randomEndpoint()).CGPath
            bar.path = path
            bar.fillColor = UIColor.whiteColor().CGColor
            self.layer.addSublayer(bar)
            barLayers.append(bar)
        }
        
        startAnimating()
    }
    
    // MARK: Functions
    
    func startAnimating() {
        
        if (isAnimating) {
            return
        }
        
        isAnimating = true
        
        for (index, bar) in enumerate(barLayers) {
            let barWidth = Double (CGRectGetWidth(self.bounds)) / Double (numberOfBars)
            
            let currentPath = UIBezierPath(CGPath: bar.path)
            let currentEndpoint = Double (currentPath.bounds.height)
            
            var newRandomEndpoint = currentEndpoint
            while (abs(currentEndpoint - newRandomEndpoint) < Double (CGRectGetHeight(self.bounds) / 4.0)) {
                newRandomEndpoint = randomEndpoint()
            }
            
            let newPath = barPath(index, endpoint: newRandomEndpoint)
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
    
    func stopAnimating() {
        barPaths = [UIBezierPath]()
        counter = 0
        for (index, bar) in enumerate(barLayers) {
            bar.removeAllAnimations()
        }
        isAnimating = false
    }
    
    // MARK: Helpers
    
    private func reset() {
        stopAnimating()
        for bar in barLayers {
            bar.removeFromSuperlayer()
        }
        barLayers = [CAShapeLayer]()
    }
    
    func barPath(barIndex: Int, endpoint: Double) -> UIBezierPath {
        let gapsWidth = distanceBetweenBars * Double (numberOfBars - 1)
        let totalBarWidth = Double (CGRectGetWidth(self.bounds)) - gapsWidth
        let barWidth = totalBarWidth / Double (numberOfBars)
        return UIBezierPath(rect: CGRect(x: (barWidth + distanceBetweenBars) * Double (barIndex), y:  Double (CGRectGetHeight(self.bounds)), width: barWidth, height: -endpoint))
    }
    
    func randomEndpoint() -> Double {
        return Double (Int (arc4random()) % Int (CGRectGetHeight(self.bounds)))
    }
    
    // MARK: Animation Delegate
    
    override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {

        if (flag) {
            let bar = barLayers[counter]
            bar.path = barPaths[counter].CGPath
            counter++
            if (counter == barLayers.count) {
                stopAnimating()
                startAnimating()
            }
        }
    }
}