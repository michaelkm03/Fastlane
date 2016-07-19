//
//  DraggableBehaviour.swift
//  victorious
//
//  Created by Sebastian Nystorm on 14/7/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

/// Abstracts away the logics for panning something on the screen using UIDynamics. By setting the `targetPoint` or `velocity`
/// the underlying behaviours will update. 
/// Can be used together with a `UIGestureRecognizer` to transfer the velocity of the item being dragged over to UIDynamics.
class DraggableBehaviour: UIDynamicBehavior {

    /// Setting targetPoint will change the anchorPoint of the item with this behaviour attached.
    var targetPoint = CGPointZero {
        didSet {
            attachmentBehaviour?.anchorPoint = targetPoint
        }
    }

    var velocity = CGPointZero {
        didSet {
            if let currentVelocity = itemBehaviour?.linearVelocityForItem(item) {
                let velocityDelta = CGPoint(x: velocity.x - currentVelocity.x, y: velocity.y - currentVelocity.y)
                itemBehaviour?.addLinearVelocity(velocityDelta, forItem: item)
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
    private var attachmentBehaviour: UIAttachmentBehavior?
    private var itemBehaviour: UIDynamicItemBehavior?
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
        let attachmentBehaviour = UIAttachmentBehavior(item: item, attachedToAnchor: CGPointZero)
        attachmentBehaviour.frequency = parameters.frequency
        attachmentBehaviour.damping = parameters.damping
        attachmentBehaviour.length = parameters.length
        self.addChildBehavior(attachmentBehaviour)
        self.attachmentBehaviour = attachmentBehaviour

        let itemBehaviour = UIDynamicItemBehavior(items: [item])
        itemBehaviour.density = parameters.density
        itemBehaviour.resistance = parameters.resistance
        self.addChildBehavior(itemBehaviour)
        self.itemBehaviour = itemBehaviour
    }
}
