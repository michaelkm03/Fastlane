//
//  LogoutOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class LogoutLocally: Operation {
    
    override func start() {
        super.start()
        
        self.beganExecuting()

        let dataStore = PersistentStore.mainContext
        VUser.clearCurrentUser(inContext: dataStore)
        
        InterstitialManager.sharedInstance.clearAllRegisteredInterstitials()
        
        NSUserDefaults.standardUserDefaults().removeObjectForKey( kLastLoginTypeUserDefaultsKey )
        NSUserDefaults.standardUserDefaults().removeObjectForKey( kAccountIdentifierDefaultsKey )
        
        VStoredLogin().clearLoggedInUserFromDisk()
        VStoredPassword().clearSavedPassword()
        
        VTrackingManager.sharedInstance().trackEvent( VTrackingEventUserDidLogOut )
        VTrackingManager.sharedInstance().setValue(false, forSessionParameterWithKey:VTrackingKeyUserLoggedIn)
        
        NSNotificationCenter.defaultCenter().postNotificationName(kLoggedInChangedNotification, object: self)
        
        self.queueNext( LogoutOperation(), queue: Operation.defaultQueue )
        
        self.finishedExecuting()
    }
}

class LogoutOperation: RequestOperation<LogoutRequest> {
    
    init() {
        super.init( request: LogoutRequest() )
    }
    
    override func onResponse(result: LogoutRequest.ResultType) {
        
        let dataStore = PersistentStore.backgroundContext
        
        // TODO: Data cleanup, deleting stuff that belongs to main user
        
        //Delete all conversations / pollresults for the user!
        /*NSManagedObjectContext *context = [VObjectManager sharedManager].managedObjectStore.persistentStoreManagedObjectContext;
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
        }];*/
        
        dataStore.saveChanges()
    }
}
