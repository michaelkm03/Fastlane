////
////  ContentUpvoteToggleOperation.swift
////  victorious
////
////  Created by Vincent Ho on 5/23/16.
////  Copyright © 2016 Victorious. All rights reserved.
////
//
//import UIKit
//
//class ContentUpvoteToggleOperation: FetcherOperation {
//    private let contentID: String
//    
//    init(contentID: String) {
//        self.contentID = contentID
//    }
//    
//    override func main() {
//        
//        persistentStore.createBackgroundContext().v_performBlockAndWait({ context in
//            guard let content: VContent = context.v_findObjects( [ "remoteId" : self.contentID] ).first else {
//                    return
//            }
//            
//            if content.isLikedByMainUser.boolValue {
//                ContentUnupvoteOperation
//            }
//            else {
//                
//            }
//            
//            
//        })
//    }
//}
