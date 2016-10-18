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
    
    fileprivate func highlightFrame(forIdentifier identifier: String) -> CGRect? {
        return nil
    }
    
    fileprivate func presentCoachmark(from viewController: CoachmarkViewController) {}
    
    fileprivate func triggerCoachmark(withContext context: String?) {}
}

class CoachmarkManagerTests: XCTestCase {
    func createTestManager() -> CoachmarkManager  {
       let file = Bundle(for: CoachmarkManagerTests.self).path(forResource: "coachmarks", ofType: "json")
        
        var configuration = [AnyHashable: Any]()
        do {
            configuration =  try JSONSerialization.jsonObject(with: Data(contentsOf: URL(fileURLWithPath: file!)), options: []) as! [AnyHashable: Any]
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
        let initialShownCoachmarks = CoachmarkManager.fetchShownCoachmarkIDs()
        XCTAssertEqual(initialShownCoachmarks.count, 0)
        
        manager.setupCoachmark(in: DummyDisplayer(), withContainerView: UIView(frame: CGRect.zero))
        
        let finalShownCoachmarks = CoachmarkManager.fetchShownCoachmarkIDs()
        XCTAssertEqual(finalShownCoachmarks.count, 1)
        
    }
    
}
