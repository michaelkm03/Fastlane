//
//  CoachmarkManagerTests.swift
//  victorious
//
//  Created by Darvish Kamalia on 7/21/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

private class DummyDisplayer: CoachmarkDisplayer {
    
    var dependencyManager: VDependencyManager! = nil
    var coachmarkContainerView = UIView()
    
    var screenIdentifier: String {
        return "578d299a4323f"
    }
    
    private func highlightFrame(forIdentifier identifier: String) -> CGRect? {
        return nil
    }
    
    private func presentCoachmark(from viewController: CoachmarkViewController) {}
    
    private func triggerCoachmark(withContext context: String?) {}
}

class CoachmarkManagerTests: XCTestCase {

    func createTestManager() -> CoachmarkManager  {
       let file = NSBundle(forClass: CoachmarkManagerTests.self).pathForResource("coachmarks", ofType: "json")
        
        var configuration = [NSObject: AnyObject]()
        do {
            configuration =  try NSJSONSerialization.JSONObjectWithData(NSData(contentsOfFile: file!)!, options: []) as! [NSObject: AnyObject]
        }
        catch {
            XCTFail("Error parsing coachmark JSON")
        }
        
        let manager = CoachmarkManager(dependencyManager: VDependencyManager(parentManager: nil, configuration: configuration, dictionaryOfClassesByTemplateName: nil))
        return manager
    }
    

    func testSetup() {
        let manager = createTestManager()
        XCTAssertEqual(manager.coachmarks.count, 1)
    }
    
    func testSetsCoachmarkShown() {
        let manager = createTestManager()
        manager.resetShownCoachmarks()
        let initialShownCoachmarks = manager.fetchShownCoachmarkIDs()
        XCTAssertEqual(initialShownCoachmarks.count, 0)
        
        manager.setupCoachmark(in: DummyDisplayer(), withContainerView: UIView(frame: CGRectZero))
        
        let finalShownCoachmarks = manager.fetchShownCoachmarkIDs()
        XCTAssertEqual(finalShownCoachmarks.count, 1)
        
    }
    
}
