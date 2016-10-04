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
    var paginatedDataSourceDidUpdateBlock: ((_ oldValue: NSOrderedSet, _ newValue: NSOrderedSet) -> Void)? = nil
    
    func paginatedDataSource( _ paginatedDataSource: PaginatedDataSource, didUpdateVisibleItemsFrom oldValue: NSOrderedSet, to newValue: NSOrderedSet) {
        self.paginatedDataSourceDidUpdateBlock?( oldValue, newValue )
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
