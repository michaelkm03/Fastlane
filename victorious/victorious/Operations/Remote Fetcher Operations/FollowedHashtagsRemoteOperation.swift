//
//  FollowedHashtagsRemoteOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

final class FollowedHashtagsRemoteOperation: RemoteFetcherOperation, PaginatedRequestOperation {
    
    let request: HashtagSubscribedToListRequest
    
    required init( request: HashtagSubscribedToListRequest ) {
        self.request = request
    }
    
    convenience init(paginator: StandardPaginator = StandardPaginator(pageNumber: 1, itemsPerPage: 30)) {
        self.init( request: HashtagSubscribedToListRequest( paginator: paginator ) )
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: onComplete, onError: nil )
    }
    
    func onComplete( hashtags: HashtagSubscribedToListRequest.ResultType) {
        // Removed body alongside deprecation of VFollowdHashtag
    }
}
