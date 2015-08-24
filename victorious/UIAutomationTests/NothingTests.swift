//
//  Test.swift
//  victorious
//
//  Created by Patrick Lynch on 8/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import KIF
import UIKit

private extension String {
    
    var camelCaseSeparatedString: String {
        if let regex = NSRegularExpression(pattern: "([a-z])([A-Z])", options: nil, error: nil) {
            return regex.stringByReplacingMatchesInString(self, options:nil, range: NSMakeRange(0, count(self)), withTemplate:"$1 $2")
        }
        return self
    }
    
    var strippedParenthesesString: String {
        return self.stringByReplacingOccurrencesOfString( "()", withString: "")
    }
}

class NothingTests: VictoriousTestCase {
    
    override var testDescription: String {
        return "Tests nothing, it's just an empty test for testing."
    }
    
    func testNothing() {
        self.addNote( "Just an empty method, except for this note." )
        
        
        let caseTitle = __FILE__.lastPathComponent.stringByDeletingPathExtension.camelCaseSeparatedString.capitalizedString
        let testTitle = __FUNCTION__.strippedParenthesesString.camelCaseSeparatedString.capitalizedString
        
        var text = ""
        text += "##\(caseTitle)\n"
        text += "\(self.testDescription)\n"
        text += "###\(testTitle)\n"
        for note in self.notes {
            text += "- \(note)"
        }
        
        let path = "/Users/patricklynch/development/VictoriousiOS.wiki/UI-Automation-Tests.md"
        var error: NSError?
        let success = text.writeToFile(path, atomically: false, encoding: NSUTF8StringEncoding, error: &error)
        XCTAssert( success, "Failed with error: \(error?.localizedDescription)" )
    }

}