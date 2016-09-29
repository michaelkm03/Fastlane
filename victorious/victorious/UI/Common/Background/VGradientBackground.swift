//
//  VGradientBackground.swift
//  victorious
//
//  Created by Patrick Lynch on 3/18/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

@objc enum VGradientBackgroundDirection: Int {
    case horizontal
    case vertical
}

class VGradientBackground: VBackground {
    
    fileprivate let dependencyManager: VDependencyManager
    fileprivate let gradientView = VLinearGradientView()
    
    required init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
        super.init()
        
        updateStyle()
    }
    
    fileprivate func updateStyle() {
        gradientView.setColors( [dependencyManager.startColor, dependencyManager.endColor] )
        switch dependencyManager.direction {
        case .vertical:
            gradientView.startPoint = CGPoint(x: 0.5, y: 0.0)
            gradientView.endPoint = CGPoint(x: 0.5, y: 1.0)
        case .horizontal:
            gradientView.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientView.endPoint = CGPoint(x: 1.0, y: 0.5)
        }
    }

    override func viewForBackground() -> UIView! {
        return gradientView
    }
}

private extension VDependencyManager {
    
    var direction: VGradientBackgroundDirection {
        switch string(forKey: "direction") ?? "" {
        case "horizontal":
            return .horizontal
        case "vertical":
            return .vertical
        default:
            return .vertical
        }
    }
    
    var startColor: UIColor {
        return color(forKey: "color.start")
    }
    
    var endColor: UIColor {
        return color(forKey: "color.end")
    }
}
