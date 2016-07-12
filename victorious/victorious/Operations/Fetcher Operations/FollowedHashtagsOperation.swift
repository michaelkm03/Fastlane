//
//  FollowedHashtagsOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 12/19/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class FollowedHashtagsOperation: FetcherOperation, PaginatedOperation {
    
    let paginator: StandardPaginator
    
    required init(paginator: StandardPaginator = StandardPaginator()) {
        self.paginator = paginator
        super.init()
        
        if !localFetch {
            let request = HashtagSubscribedToListRequest(paginator: paginator)
            FollowedHashtagsRemoteOperation(request: request).before(self).queue()
        }
    }
    
    required convenience init(operation: FollowedHashtagsOperation, paginator: StandardPaginator) {
        self.init(paginator: paginator)
    }
    
    override func main() {
        // Removed body alongside deprecation of VFollowedHashtag
    }
}
