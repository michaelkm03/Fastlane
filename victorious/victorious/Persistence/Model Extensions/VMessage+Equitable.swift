//
//  VMessage+Equitable.swift
//  victorious
//
//  Created by Patrick Lynch on 2/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

// Because messages may exist without a remoteId, we need to check equality differently:
func ==(lhs: VMessage, rhs: VMessage) -> Bool {
    return lhs.postedAt == rhs.postedAt && lhs.text == rhs.text && lhs.conversation == rhs.conversation
}
