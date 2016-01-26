//
//  PaginatedDataSourceTests.swift
//  victorious
//
//  Created by Patrick Lynch on 12/23/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
@testable import victorious
import VictoriousIOSSDK

class PaginatedDataSourceTests: XCTestCase {
    
    var paginatedDataSource: PaginatedDataSource!
    var paginatedDataSourceUpdateCount: Int = 0
    var paginatedDataSourceDidUpdateBlock: ((oldValue: NSOrderedSet, newValue: NSOrderedSet) -> Void)? = nil
    
    func paginatedDataSource( paginatedDataSource: PaginatedDataSource, didUpdateVisibleItemsFrom oldValue: NSOrderedSet, to newValue: NSOrderedSet) {
        self.paginatedDataSourceDidUpdateBlock?( oldValue: oldValue, newValue: newValue )
    }
    
    override func setUp() {
        super.setUp()
        
        paginatedDataSourceUpdateCount = 0
        paginatedDataSource = PaginatedDataSource()
    }
    
    override func tearDown() {
        super.tearDown()
    }
}
