//
//  VTabScaffoldViewControllerTests.swift
//  victorious
//
//  Created by Michael Sena on 9/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

class VTabScaffoldViewControllerTests: VictoriousTestCase {
    
    override var testDescription: String {
        return "Tests some configurations of the scaffold."
    }
    
    override func configureTemplate(defaultTemplateDecorator: VTemplateDecorator) -> (VTemplateDecorator) {
        println("configuring scaffold tests!")
        return defaultTemplateDecorator
    }
    
    func testAutoShowLogin() {
        
        
    }
    
    
    
}

