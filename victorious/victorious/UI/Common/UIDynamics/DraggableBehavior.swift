//
//  DraggableBehavior.swift
//  victorious
//
//  Created by Sebastian Nystorm on 14/7/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

/// Abstracts away the logics for panning something on the screen using UIDynamics. By setting the `targetPoint` or `velocity`
/// the underlying behaviors will update. 
/// Can be used together with a `UIGestureRecognizer` to transfer the velocity of the item being dragged over to UIDynamics.
class DraggableBehavior: UIDynamicBehavior {

    /// Setting targetPoint will change the anchorPoint of the item with this behavior attached.
    var targetPoint = CGPoint.zero {
        didSet {
            attachmentBehavior?.anchorPoint = targetPoint
        }
    }

    var velocity = CGPoint.zero {
        didSet {
            if let currentVelocity = itemBehavior?.linearVelocity(for: item) {
                let velocityDelta = CGPoint(x: velocity.x - currentVelocity.x, y: velocity.y - currentVelocity.y)
                itemBehavior?.addLinearVelocity(velocityDelta, for: item)
            }
        }
    }

    struct Parameters {
       var frequency = CGFloat(3.5)
       var damping = CGFloat(0.4)
       var length = CGFloat(0)
       var density = CGFloat(100)
       var resistance = CGFloat(10)
    }

    private var item: UIDynamicItem
    private var attachmentBehavior: UIAttachmentBehavior?
    private var itemBehavior: UIDynamicItemBehavior?
    private var parameters: Parameters

    /// Initialize with a `UIDynamicItem` which will be the item dragged around on the screen. 
    /// Pass in a `Parameters` struct in order to tweak the values that feeds into the physics engine.
    init(with item: UIDynamicItem, and parameters: Parameters = Parameters()) {
        self.item = item
        self.parameters = parameters
        super.init()
        setup()
    }

    private func setup() {
        let attachmentBehavior = UIAttachmentBehavior(item: item, attachedToAnchor: CGPoint.zero)
        attachmentBehavior.frequency = parameters.frequency
        attachmentBehavior.damping = parameters.damping
        attachmentBehavior.length = parameters.length
        self.addChildBehavior(attachmentBehavior)
        self.attachmentBehavior = attachmentBehavior

        let itemBehavior = UIDynamicItemBehavior(items: [item])
        itemBehavior.density = parameters.density
        itemBehavior.resistance = parameters.resistance
        self.addChildBehavior(itemBehavior)
        self.itemBehavior = itemBehavior
    }
}
