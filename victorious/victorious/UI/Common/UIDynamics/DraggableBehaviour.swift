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

    private struct Constants {
        static let frequency = CGFloat(3.5)
        static let damping = CGFloat(0.4)
        static let length = CGFloat(0)
        static let density = CGFloat(100)
        static let resistance = CGFloat(10)
    }

    private var item: UIDynamicItem
    private var attachmentBehaviour: UIAttachmentBehavior?
    private var itemBehaviour: UIDynamicItemBehavior?

    init(with item: UIDynamicItem) {
        self.item = item
        super.init()
        setup()
    }

    private func setup() {
        let attachmentBehaviour = UIAttachmentBehavior(item: item, attachedToAnchor: CGPointZero)
        attachmentBehaviour.frequency = Constants.frequency
        attachmentBehaviour.damping = Constants.damping
        attachmentBehaviour.length = Constants.length
        self.addChildBehavior(attachmentBehaviour)
        self.attachmentBehaviour = attachmentBehaviour

        let itemBehaviour = UIDynamicItemBehavior(items: [item])
        itemBehaviour.density = Constants.density
        itemBehaviour.resistance = Constants.resistance
        self.addChildBehavior(itemBehaviour)
        self.itemBehaviour = itemBehaviour
    }
}



