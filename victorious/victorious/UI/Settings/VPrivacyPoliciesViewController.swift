//
//  VPrivacyPoliciesViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 3/19/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import WebKit

extension VPrivacyPoliciesViewController {
    
    func loadPrivacyPolicy() {
        let operation = PrivacyPolicyOperation()
        operation.queue() { results, error, cancelled in
            guard let htmlString = operation.resultHTMLString where error == nil else {
                self.setFailureWithError(error)
                return
            }
            self.webView.loadHTMLString(htmlString, baseURL: operation.request.publicBaseURL)
        }
    }
}
