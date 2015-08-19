//
//  KIFUtils.swift
//  victorious
//
//  Created by Patrick Lynch on 8/4/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

extension XCTestCase {
    func tester(_ file : String = __FILE__, _ line : Int = __LINE__) -> KIFUITestActor {
        return KIFUITestActor(inFile: file, atLine: line, delegate: self)
    }
    
    func system(_ file : String = __FILE__, _ line : Int = __LINE__) -> KIFSystemTestActor {
        return KIFSystemTestActor(inFile: file, atLine: line, delegate: self)
    }
}

extension KIFTestActor {
    func tester(_ file : String = __FILE__, _ line : Int = __LINE__) -> KIFUITestActor {
        return KIFUITestActor(inFile: file, atLine: line, delegate: self)
    }
    
    func system(_ file : String = __FILE__, _ line : Int = __LINE__) -> KIFSystemTestActor {
        return KIFSystemTestActor(inFile: file, atLine: line, delegate: self)
    }
    
    func waitWithCountdownForInterval( interval:NSTimeInterval ) {
        println( "Waiting for \(Int(interval)) seconds..." )
        for i in 0..<Int(interval) {
            self.tester().waitForTimeInterval( 1.0 )
            println( "\(Int(interval)-i)..." )
        }
    }
    
    func acknowledgeSystemAlert() {
        self.tester().tapViewWithAccessibilityLabel( "OK" )
    }
}