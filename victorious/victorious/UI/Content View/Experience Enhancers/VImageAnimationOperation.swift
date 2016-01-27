//
//  VImageAnimationOperation.swift
//  victorious
//
//  Created by Vincent Ho on 1/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

@objc protocol VImageAnimationOperationDelegate {
//    Should remove imageview after this call
    func animation(animation: VImageAnimationOperation, didFinishAnimating completed:Bool)
}

class VImageAnimationOperation: Operation {
    private(set) var animationImageView: UIImageView
    
    private var animationTimer: NSTimer?
    private var _contentMode: UIViewContentMode?
    private var currentFrame: Int
    
    var animationSequence: NSArray?
    weak var delegate: VImageAnimationOperationDelegate?
    var animationDuration: Float
    
    var flightImage: UIImage?
    var flightDuration: NSTimeInterval?
    var flightDestination: CGPoint?
    
    var contentMode: UIViewContentMode {
        get {
            return self._contentMode!
        }
        set {
            self._contentMode = newValue
            animationImageView.contentMode = contentMode
        }
    }
    
    init(frame: CGRect) {
        animationImageView = UIImageView(frame: frame)
        animationDuration = 1
        currentFrame = -1
        animationTimer = nil
        _contentMode = nil
        animationSequence = nil
        super.init()
    }
    
    func isAnimating() -> Bool {
        return currentFrame != -1
    }
    
    func updateFrame() {
        currentFrame++
        updateImageFrame()
    }
    
    func updateImageFrame() {
        if cancelled {
            stopAnimating()
        }
        if currentFrame == animationSequence?.count {
            stopAnimating()
        }
        else if currentFrame >= 0 {
            animationImageView.image = animationSequence?[currentFrame] as! UIImage
        }
        else {
            animationImageView.image = nil
        }
    }
    
    func addFlightFor(flightDuration: NSTimeInterval, destination:CGPoint, image: UIImage) {
        self.flightImage = image
        self.animationImageView.image = image
        self.flightDuration = flightDuration
        self.flightDestination = destination
    }
    
    func beginAnimation() {
        currentFrame = 0
        let frameDuration: Float = animationDuration/Float(animationSequence!.count)
        animationTimer = NSTimer(timeInterval: NSTimeInterval(frameDuration), target: self, selector: "updateFrame", userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(animationTimer!, forMode: NSDefaultRunLoopMode)
    }
    
    func startAnimating() {
        if let _ = animationSequence {
            if animationSequence?.count == 0 {
                self.stopAnimating()
                return
            }
            if let _ = flightImage {
                dispatch_async(dispatch_get_main_queue(), {
                    UIView.animateWithDuration(self.flightDuration!, animations: {
                        self.animationImageView.center = self.flightDestination!
                        }, completion: { completed in
                            self.beginAnimation()
                    })
                })
            }
            else {
                beginAnimation()
            }
        }
        else {
            return
        }
    }
    
    func stopAnimating() {
        delegate?.animation(self, didFinishAnimating: currentFrame == animationSequence?.count)
        currentFrame = -1
        animationTimer?.invalidate()
        updateImageFrame()
        finishedExecuting()
        animationSequence = nil
    }
    
    override func start() {
//        NSLog("%@ start", self)
        startAnimating()
        super.start()
    }
    
    override func cancel() {
        stopAnimating()
        super.cancel()
    }
    
    deinit {
//        NSLog("deinit")
    }
    
}
