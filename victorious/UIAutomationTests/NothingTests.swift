//
//  Test.swift
//  victorious
//
//  Created by Patrick Lynch on 8/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import KIF
import UIKit

class NothingTests: VictoriousTestCase {
    
    override var testDescription: String {
        return "Tests nothing, it's just an empty test for testing."
    }
    
    func testNothingOne() {
        self.addNote( "Just an empty method, except for this note 1." )
        self.addNote( "Just an empty method, except for this note 2." )
    }
    
    func testNothingTwo() {
        self.addNote( "Just an empty method, except for this note 1." )
        self.addNote( "Just an empty method, except for this note 2." )
    }

}