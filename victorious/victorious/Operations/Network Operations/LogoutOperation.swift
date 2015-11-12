//
//  LogoutOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class LogoutOperation: NetworkOperation<OneWayRequest> {
    
    init() {
        super.init( request: OneWayRequest(url: NSURL(string: "/api/logout")! ) )
    }
    
    override func start() {
        super.start()
        
        // TODO: Cancel/remove other requests in network operaiton queue
    }
    
    override func onResponse(result: Void) {
        
        let dataStore = PersistentStore.backgroundContext
        VUser.clearCurrentUser(inContext: dataStore)
        
        // TODO: Data cleanup, deleting stuff that belongs to main user
        // TODO: Perhaps a `LoginCleanupOperation`?
        /*
        //Delete all conversations / pollresults for the user!
        NSManagedObjectContext *context = [VObjectManager sharedManager].managedObjectStore.persistentStoreManagedObjectContext;
        [context performBlockAndWait:^(void)
        {
        
        NSFetchRequest *allConversations = [[NSFetchRequest alloc] init];
        [allConversations setEntity:[NSEntityDescription entityForName:[VConversation entityName] inManagedObjectContext:context]];
        [allConversations setIncludesPropertyValues:NO]; //only fetch the managedObjectID
        
        NSArray *conversations = [context executeFetchRequest:allConversations error:nil];
        for (NSManagedObject *conversation in conversations)
        {
        [context deleteObject:conversation];
        }
        
        NSFetchRequest *allPollResults = [[NSFetchRequest alloc] init];
        [allPollResults setEntity:[NSEntityDescription entityForName:[VPollResult entityName] inManagedObjectContext:context]];
        [allPollResults setIncludesPropertyValues:NO]; //only fetch the managedObjectID
        
        NSArray *pollResults = [context executeFetchRequest:allPollResults error:nil];
        for (NSManagedObject *pollResult in pollResults)
        {
        [context deleteObject:pollResult];
        }
        
        [context save:nil];
        }];
        */
        
        dataStore.saveChanges()
    }
}