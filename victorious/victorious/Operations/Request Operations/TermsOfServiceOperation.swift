//
//  TermsOfServiceOperation.swift
//  victorious
//
//  Created by Michael Sena on 12/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class TermsOfServiceOperation: RequestOperation {
    
    let request = TermsOfServiceRequest()
    var resultHTMLString: String?
    
    override func main() {
        executeRequest(request, onComplete: self.onComplete)
    }
    
    private func onComplete( htmlString: TermsOfServiceRequest.ResultType, completion: () -> () ) {
        resultHTMLString = htmlString
        completion()
    }
}
