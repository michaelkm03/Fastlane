//
//  VIPSubscriptionSuccessOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class VIPSubscriptionSuccessOperation: FetcherOperation {
    
    override func main() {
        
        persistentStore.createBackgroundContext().v_performBlockAndWait() { context in
            VCurrentUser.user(inManagedObjectContext: context)?.isVIPSubscriber = true
            context.v_save()
        }
        
        ValidateReceiptOperation().after(self).queue()
    }
}
