//
//  SequenceActionHelper.swift
//  victorious
//
//  Created by Patrick Lynch on 11/17/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import UIKit

@objc class SequenceActionHelper: NSObject {
    
    func likeSequence(sequence: VSequence, triggeringView: UIView, originViewController: UIViewController, dependencyManager: VDependencyManager, completion: ((Bool) -> Void)?) {
        
        if sequence.isLikedByMainUser?.boolValue ?? false {
            UnlikeSequenceOperation( sequenceID: Int64(sequence.remoteId)! ).queue() { error in
                completion?( error == nil )
            }
        } else {
            let uiContext = LikeSequenceOperation.UIContext(
                originViewController: originViewController,
                dependencyManager: dependencyManager,
                triggeringView: triggeringView
            )
            LikeSequenceOperation( sequenceID: Int64(sequence.remoteId)!, uiContext: uiContext ).queue() { error in
                completion?( error == nil )
            }
        }
    }
    
    func repostNode( node: VNode, completion: ((Bool) -> Void)?) {
        RepostSequenceOperation(nodeID: Int64(node.remoteId.integerValue) ).queue { error in
            completion?( error == nil )
        }
    }
    
    func flagSequence( sequence: VSequence, fromViewController viewController: UIViewController, completion:((Bool) -> Void)? ) {
        FlagSequenceOperation(sequenceID: Int64(sequence.remoteId)!, originViewController: viewController ).queue() { error in
            completion?( error == nil )
        }
    }
}