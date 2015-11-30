//
//  GIFSearchRequestOperation.swift
//  victorious
//
//  Created by Tian Lan on 11/30/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class GIFSearchRequestOperation: RequestOperation<GIFSearchRequest> {
    
    init(searchText: String) {
        super.init(request: GIFSearchRequest(searchTerm: searchText))
    }
}
