//
//  VTOSViewController.swift
//  victorious
//
//  Created by Michael Sena on 12/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import WebKit

extension VTOSViewController {
    
    func loadTermsOfService() {
        let termsOfServiceOperation = TermsOfServiceOperation()
        termsOfServiceOperation.queue() { results, error, cancelled in
            guard let htmlString = termsOfServiceOperation.resultHTMLString where error == nil else {
                self.setFailureWithError(error)
                return
            }
            self.webView.loadHTMLString(htmlString, baseURL: NSURL(string: "http://www.victorious.com/")!)
        }
    }
}
