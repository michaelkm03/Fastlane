//
//  UIView+ShakeAnimation.swift
//  victorious
//
//  Created by Darvish Kamalia on 5/18/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

extension UIView {
    /// Performs a rapid shake animation
    func v_performShakeAnimation() {
        UIView.animateKeyframes(withDuration: 0.35, delay: 0.0, options: .calculationModeCubic,
            animations: {
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.3) {
                    self.layer.setAffineTransform(CGAffineTransform(translationX: -5.0, y: 0.0))
                }
                
                UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.3) {
                    self.layer.setAffineTransform(CGAffineTransform(translationX: 5.0, y: 0.0))
                }
                
                UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.3) {
                    self.layer.setAffineTransform(CGAffineTransform(translationX: 0.0, y: 0.0))
                }
            },
            completion: nil
        )
    }
}
