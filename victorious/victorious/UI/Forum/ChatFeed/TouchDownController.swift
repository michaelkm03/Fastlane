//
//  TouchDownController.swift
//  victorious
//
//  Created by Patrick Lynch on 4/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

class TouchDownController: NSObject, UIGestureRecognizerDelegate {
    
    var isTouchDown: Bool = false
    
    func detectTouchDown(view: UIView) {
        
        let touchUp = UITapGestureRecognizer(target: self, action: #selector(onTouchUp(_:)))
        touchUp.delegate = self
        touchUp.cancelsTouchesInView = false
        view.addGestureRecognizer(touchUp)
        
        let touchDown = TouchDownGestureRecognizer(target: self, action: #selector(onTouchDown(_:)))
        touchDown.delegate = self
        view.addGestureRecognizer(touchDown)
    }
    
    func onTouchDown(gestureRecognizer: UIGestureRecognizer) {
        isTouchDown = true
    }
    
    func onTouchUp(gestureRecognizer: UIGestureRecognizer) {
        isTouchDown = false
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

private class TouchDownGestureRecognizer: UIGestureRecognizer {
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if state == .Possible {
            state = .Recognized
        }
    }
}
