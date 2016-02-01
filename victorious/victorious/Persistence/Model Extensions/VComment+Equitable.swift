//
//  VComment+Equitable.swift
//  victorious
//
//  Created by Patrick Lynch on 2/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

// Because comments may exist without a remoteId, we need to check equality differently:
func ==(lhs: VComment, rhs: VComment) -> Bool {
    return lhs.postedAt == rhs.postedAt && lhs.text == rhs.text && lhs.sequence == rhs.sequence
}
