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
        static let attachmentFrequency = CGFloat(3.5)
        // TODO: fill in
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
        attachmentBehaviour.frequency = Constants.attachmentFrequency
        attachmentBehaviour.damping = 0.4
        attachmentBehaviour.length = 10
        self.addChildBehavior(attachmentBehaviour)
        self.attachmentBehaviour = attachmentBehaviour

        let itemBehaviour = UIDynamicItemBehavior(items: [item])
        itemBehaviour.density = 100
        itemBehaviour.resistance = 10
        self.addChildBehavior(itemBehaviour)
        self.itemBehaviour = itemBehaviour
    }
}



