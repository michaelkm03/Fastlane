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
    private struct Constants {
        static let testUsername = "asdf"
    }
    
    func createTestDataSource() -> EditProfileDataSource {
        let dependencyManager = VDependencyManager(parentManager: nil, configuration: nil, dictionaryOfClassesByTemplateName: nil)
        let viewController: EditProfileViewController = EditProfileViewController.v_initialViewControllerFromStoryboard()
        viewController.loadViewIfNeeded()
        let tableView = viewController.tableView
        XCTAssertNotNil(tableView)
        return EditProfileDataSource(dependencyManager: dependencyManager, tableView: tableView!, userModel: User(id: 1, username: Constants.testUsername))
    }
    
    func testInit() {
        let dataSource = createTestDataSource()
        XCTAssertEqual(dataSource.nameAndLocationCell.username, Constants.testUsername)
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
    
    func testValidUsernamesAndDisplayNames() {
        let dataSource = createTestDataSource()
        dataSource.nameAndLocationCell.username = "a_1"
        dataSource.nameAndLocationCell.displayname = nil
        XCTAssertTrue(dataSource.dataSourceStatus.valid)
        
        dataSource.nameAndLocationCell.displayname = "012345678901234567890123456789"
        dataSource.nameAndLocationCell.username = "a"
        XCTAssertTrue(dataSource.dataSourceStatus.valid)
    }
    
    func testInvalidUsernamesAndDisplayNames() {
        let dataSource = createTestDataSource()
        dataSource.nameAndLocationCell.username = "  % &^                       "
        dataSource.nameAndLocationCell.displayname = "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789"
        XCTAssertFalse(dataSource.dataSourceStatus.valid)
        
        dataSource.nameAndLocationCell.username = ""
        XCTAssertFalse(dataSource.dataSourceStatus.valid)
        
        dataSource.nameAndLocationCell.username = "🏓"
        XCTAssertFalse(dataSource.dataSourceStatus.valid)
        
        let testDataPath = NSBundle(forClass: EditProfileDataSourceTests.self).pathForResource("LoremIpsum", ofType: "txt")
        XCTAssertNotNil(testDataPath)
        
        do {
            let contents = try NSString(contentsOfFile: testDataPath!, usedEncoding: nil)
            dataSource.nameAndLocationCell.displayname = String(contents)
            XCTAssertFalse(dataSource.dataSourceStatus.valid)
        }
        
        catch {
            XCTFail("Could not create test")
        }
    }
}
