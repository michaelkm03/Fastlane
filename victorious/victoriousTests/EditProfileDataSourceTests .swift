//
//  EditProfileDataSourceTests .swift
//  victorious
//
//  Created by Darvish Kamalia on 7/29/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import XCTest
@testable import victorious

class EditProfileDataSourceTests: XCTestCase {
    func createTestDataSource() -> EditProfileDataSource {
        let dependencyManager = VDependencyManager(parentManager: nil, configuration: nil, dictionaryOfClassesByTemplateName: nil)
        let viewController = EditProfileViewController.v_initialViewControllerFromStoryboard()
        let tableView = viewController.view as? UITableView
        XCTAssertNotNil(tableView)
        return EditProfileDataSource(dependencyManager: dependencyManager, tableView: tableView!, userModel: User(id: 1))
    }
    
    func testInit() {
        let dataSource = createTestDataSource()
        XCTAssertEqual(dataSource.nameAndLocationCell.user?.id, 1)
        XCTAssertEqual(dataSource.aboutMeCell.tagline, "")
    }
    
    func testTableViewDataSourceMethods() {
        let dataSource = createTestDataSource()
        XCTAssertEqual(dataSource.tableView(UITableView(), numberOfRowsInSection: 0), 2)
        
        let nameCellIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        let nameCell = dataSource.tableView(UITableView(), cellForRowAtIndexPath: nameCellIndexPath) as? DisplaynameLocationAvatarCell
        XCTAssertNotNil(nameCell)
        
        let aboutMeCellIndexPath = NSIndexPath(forRow: 1, inSection: 0)
        let aboutMeCell = dataSource.tableView(UITableView(), cellForRowAtIndexPath: aboutMeCellIndexPath)
        XCTAssertNotNil(aboutMeCell)
        
        XCTAssertNotEqual(aboutMeCell, nameCell)
    }
    
    func testValidUsernames() {
        let dataSource = createTestDataSource()
        dataSource.nameAndLocationCell.displayname = "Vicky Victorious"
        XCTAssertTrue(dataSource.enteredDataIsValid)
        
        dataSource.nameAndLocationCell.displayname = "Vicky Victorious Vicky Victorious Vicky Victorious Vicky Victorious Vicky Victorious"
        XCTAssertTrue(dataSource.enteredDataIsValid)
    }
    
    func testInvalidUsernames() {
        let dataSource = createTestDataSource()
        dataSource.nameAndLocationCell.displayname = "                         "
        XCTAssertFalse(dataSource.enteredDataIsValid)
        
        let testDataPath = NSBundle(forClass: EditProfileDataSourceTests.self).pathForResource("LoremIpsum", ofType: "txt")
        XCTAssertNotNil(testDataPath)
        
        do {
            let contents = try NSString(contentsOfFile: testDataPath!, usedEncoding: nil)
            dataSource.nameAndLocationCell.displayname = String(contents)
            XCTAssertFalse(dataSource.enteredDataIsValid)
        }
        
        catch {
            XCTFail("Could not create test")
        }
    }
}
