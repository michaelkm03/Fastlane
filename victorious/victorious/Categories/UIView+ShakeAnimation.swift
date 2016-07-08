//
//  UIView+ShakeAnimation.swift
//  victorious
//
//  Created by Darvish Kamalia on 5/18/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import UIKit


extension UIView {
    
    /// Performs a rapid shake animation
    
    func v_performShakeAnimation() {
        
        UIView.animateKeyframesWithDuration(0.35, delay: 0.0, options: .CalculationModeCubic,
                                            
            animations: {
            
                UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.3) {
                    self.layer.setAffineTransform(CGAffineTransformMakeTranslation(-5.0, 0.0))
                }
                
                UIView.addKeyframeWithRelativeStartTime(0.3, relativeDuration: 0.3) {
                    self.layer.setAffineTransform(CGAffineTransformMakeTranslation(5.0, 0.0))
                }
                
                UIView.addKeyframeWithRelativeStartTime(0.6, relativeDuration: 0.3) {
                    self.layer.setAffineTransform(CGAffineTransformMakeTranslation(0.0, 0.0))
                }
            
            }, completion: nil)
        
    }
    
}
