//
//  PrivacyPolicyOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/19/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class PrivacyPolicyOperation: FetchWebContentOperation, RequestOperation {
    
    let request: PrivacyPolicyRequest! = PrivacyPolicyRequest()
    
    override var publicBaseURL: NSURL {
        return request.publicBaseURL
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: onComplete, onError: nil )
    }
    
    private func onComplete( htmlString: PrivacyPolicyRequest.ResultType ) {
        resultHTMLString = htmlString
    }
}
