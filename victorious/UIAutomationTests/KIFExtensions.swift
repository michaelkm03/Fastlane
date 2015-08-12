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
        println( "Waiting for \(interval) seconds..." )
        for i in 0..<Int(interval) {
            self.tester().waitForTimeInterval( 1.0 )
            println( "\(i)" )
        }
    }
}

extension KIFUITestActor {
    
    func waitForViewWithAccessbilityIdentifier( identifier: String, timeout:NSTimeInterval = 10.0 ) -> UIView {
        var view: UIView? = nil
        self.runBlock({ (error) -> KIFTestStepResult in
            let app = UIApplication.sharedApplication()
            view = app.v_viewWithAccessbilityIdentifier( identifier )
            return view != nil ? KIFTestStepResult.Success : KIFTestStepResult.Wait
        }, timeout: timeout )
        return view!
    }
    
    
    func waitForObjectWithAccessbilityIdentifier( identifier: String, timeout:NSTimeInterval = 10.0 ) -> VAutomationElement {
        var view: UIView? = nil
        self.runBlock({ (error) -> KIFTestStepResult in
            let app = UIApplication.sharedApplication()
            view = app.v_elementWithAccessbilityIdentifier( identifier )
            return view != nil ? KIFTestStepResult.Success : KIFTestStepResult.Wait
        }, timeout: timeout )
        return view!
    }
    
    func enterText( text: String, intoViewWithAccessibilityIdentifier identifier:String ) {
        let view = self.tester().waitForViewWithAccessbilityIdentifier( identifier )
        view.becomeFirstResponder()
        self.waitForTimeInterval( 0.25 )
        self.enterTextIntoCurrentFirstResponder( text )
        self.expectView( view, toContainText: text )
    }
}