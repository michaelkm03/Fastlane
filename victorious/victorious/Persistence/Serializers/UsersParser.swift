//
//  UsersParser.swift
//  victorious
//
//  Created by Patrick Lynch on 12/19/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

/// Helper class that parses a list of network model users into persistence model users
struct UsersParser {
    
    func parse( users: [User], inStore persistentStore: PersistentStoreType, completion: [VUser] -> Void ) {
        
        var userObjectIDs = [NSManagedObjectID]()
        
        persistentStore.backgroundContext.v_performBlock() { context in
            for user in users {
                let uniqueElements = [ "remoteId" : NSNumber( longLong: user.userID ) ]
                let user: VUser = context.v_findOrCreateObject( uniqueElements )
                userObjectIDs.append( user.objectID )
            }
            context.v_save()
            
            persistentStore.mainContext.v_performBlock() { context in
                var users = [VUser]()
                for objectID in userObjectIDs {
                    if let user = context.objectWithID( objectID ) as? VUser {
                        users.append( user )
                    }
                }
                completion( users )
            }
        }
    }
}
