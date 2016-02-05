//
//  PaginatedObjectType.swift
//  victorious
//
//  Created by Patrick Lynch on 1/20/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// An abstraction of any NSManagedObject subclasses that existing within
/// paginated endpoints.  This allows some behavior related to display order
/// to be abstracted and shared.
@objc protocol PaginatedObjectType: class {
    
    // TODO: Audit nullability or re-write models in Swift to remove force unwrap (null_unspecified)
    var displayOrder: NSNumber! { get set }
}

// Provide conformance models that already have defined `displayOrder` property

extension VComment: PaginatedObjectType {}
extension VMessage: PaginatedObjectType {}
extension VStreamItemPointer: PaginatedObjectType {}
extension VConversation: PaginatedObjectType {}
extension VFollowedHashtag: PaginatedObjectType {}
extension VFollowedUser: PaginatedObjectType {}
extension VNotification: PaginatedObjectType {}
extension VSequenceLiker: PaginatedObjectType {}

func ==(lhs: VUser, rhs: VUser) -> Bool {
    return lhs.remoteId == rhs.remoteId
}
