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
    
    var numberOfBars = 20 {
        didSet {
            setNeedsLayout()
        }
    }
    
    var distanceBetweenBars = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        
        reset(true)
        
        for index in 0...numberOfBars-1 {
            let rectangle = CAShapeLayer()
            rectangle.path = barPath(index, endpoint: randomEndpoint()).CGPath
            rectangle.fillColor = UIColor.redColor().CGColor
            self.layer.addSublayer(rectangle)
            barLayers.append(rectangle)
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
            animation.duration = 0.2
            animation.delegate = self
            animation.fillMode = kCAFillModeForwards
            animation.removedOnCompletion = false
            
            bar.addAnimation(animation, forKey: animation.keyPath)
        }
    }
    
    func stopAnimating() {
        reset(false)
    }
    
    // MARK: Helpers
    
    private func reset(clearBars: Bool) {
        isAnimating = false
        barPaths = [UIBezierPath]()
        counter = 0
        
        if (clearBars) {
            barLayers = [CAShapeLayer]()
        }
    }
    
    func barPath(barIndex: Int, endpoint: Double) -> UIBezierPath {
        let barWidth = Double (CGRectGetWidth(self.bounds)) / Double (numberOfBars)
        return UIBezierPath(rect: CGRect(x: barWidth * Double (barIndex), y:  Double (CGRectGetHeight(self.bounds)), width: barWidth, height: -endpoint))
    }
    
    func randomEndpoint() -> Double {
        return Double (Int (arc4random()) % Int (CGRectGetHeight(self.bounds)))
    }
    
    // MARK: Animation Delegate
    
    override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
        let bar = barLayers[counter]
        bar.path = barPaths[counter].CGPath
        counter++
        if (counter == numberOfBars) {
            reset(false)
            startAnimating()
        }
    }
}