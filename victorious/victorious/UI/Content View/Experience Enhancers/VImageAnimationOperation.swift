//
//  VImageAnimationOperation.swift
//  victorious
//
//  Created by Vincent Ho on 1/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

@objc protocol VImageAnimationOperationDelegate {
    // Should remove imageview after this call
    func animation(animation: VImageAnimationOperation, didFinishAnimating completed:Bool)
    
    // Should update UIImageView
    func animation(animation: VImageAnimationOperation, updatedToImage image:UIImage?)
}

class VImageAnimationOperation: Operation {
    
    
    weak var delegate: VImageAnimationOperationDelegate?
    
    var animationImageView: UIImageView
    var animationDuration: Float
    private var currentFrame: Int
    private var animationTimer: NSTimer?
    private var _animationSequence: NSArray
    var ballisticAnimationBlock: (( ()->() )->(Void))?

    required init(animationDuration duration: Float) {
        _animationSequence = NSArray()
        animationImageView = UIImageView()
        animationDuration = duration
        currentFrame = -1
        animationTimer = nil
        super.init()
    }
    
    func setAnimationSequence(animationSequence: NSArray) {
        _animationSequence = animationSequence
    }
    
    func isAnimating() -> Bool {
        if completedAnimation() {
            return false
        }
        return currentFrame != -1
    }
    
    // If nil or empty animation sequence, by default the animation is done.
    func completedAnimation() -> Bool {
        if _animationSequence.count == 0 {
            return true
        }
        return currentFrame == _animationSequence.count
    }
    
    func updateFrame() {
        currentFrame++
        updateImageFrame()
    }
    
    func updateImageFrame() {
        if cancelled {
            stopAnimating()
        }
        if completedAnimation() {
            stopAnimating()
        }
        else {
            let image: UIImage? = _animationSequence[currentFrame] as? UIImage
            delegate?.animation(self, updatedToImage: image)
        }
    }
    
    func beginAnimation() {
        if let _ = ballisticAnimationBlock {
            ballisticAnimationBlock!({
                self.currentFrame = 0
                NSRunLoop.mainRunLoop().addTimer(self.animationTimer!, forMode: NSDefaultRunLoopMode)
            })
        }
        else {
            currentFrame = 0
            NSRunLoop.mainRunLoop().addTimer(animationTimer!, forMode: NSDefaultRunLoopMode)
        }
    }
    
    func startAnimating() {
        if _animationSequence.count == 0 {
            stopAnimating()
        }
        else {
            let frameDuration: Float = animationDuration/Float(_animationSequence.count)
            animationTimer = NSTimer(timeInterval: NSTimeInterval(frameDuration), target: self, selector: "updateFrame", userInfo: nil, repeats: true)
            beginAnimation()
        }
    }
    
    func stopAnimating() {
        let finishedAnimation: Bool = currentFrame == _animationSequence.count
        delegate?.animation(self, didFinishAnimating:finishedAnimation)
        animationTimer!.invalidate()
        finishedExecuting()
    }
    
    override func start() {
        startAnimating()
        super.start()
    }
    
    override func cancel() {
        stopAnimating()
        super.cancel()
    }
    
}
