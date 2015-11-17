//
//  SequenceLikeHelper.swift
//  victorious
//
//  Created by Patrick Lynch on 11/17/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import UIKit

@objc class SequenceLikeHelper: NSObject {
    
    func likeSequence(sequence: VSequence, triggeringView: UIView, originViewController: UIViewController, dependencyManager: VDependencyManager, completion: ((Bool) -> Void)?) {
        
        if sequence.isLikedByMainUser?.boolValue ?? false {
            UnlikeSequenceOperation( sequenceID: Int64(sequence.remoteId)! ).queue() { error in
                completion?( error == nil )
            }
        } else {
            let context = LikeSequenceOperation.UIContext(
                originViewController: originViewController,
                dependencyManager: dependencyManager,
                triggeringView: triggeringView
            )
            LikeSequenceOperation( sequenceID: Int64(sequence.remoteId)!, context: context ).queue() { error in
                completion?( error == nil )
            }
        }
    }
}