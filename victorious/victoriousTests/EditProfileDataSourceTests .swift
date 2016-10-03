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
    fileprivate struct Constants {
        static let testUsername = "asdf"
    }
    
    func createTestDataSource() -> EditProfileDataSource {
        let dependencyManager = VDependencyManager(parentManager: nil, configuration: nil, dictionaryOfClassesByTemplateName: nil)
        let viewController: EditProfileViewController = EditProfileViewController.v_initialViewControllerFromStoryboard()
        viewController.loadViewIfNeeded()
        let tableView = viewController.tableView
        XCTAssertNotNil(tableView)
        return EditProfileDataSource(dependencyManager: dependencyManager!, tableView: tableView!, userModel: User(id: 1, username: Constants.testUsername))
    }
    
    func testInit() {
        let dataSource = createTestDataSource()
        XCTAssertEqual(dataSource.nameAndLocationCell.username, Constants.testUsername)
        XCTAssertEqual(dataSource.aboutMeCell.tagline, "")
    }
    
    func testTableViewDataSourceMethods() {
        let dataSource = createTestDataSource()
        XCTAssertEqual(dataSource.tableView(UITableView(), numberOfRowsInSection: 0), 2)
        
        let nameCellIndexPath = IndexPath(row: 0, section: 0)
        let nameCell = dataSource.tableView(UITableView(), cellForRowAt: nameCellIndexPath) as? DisplaynameLocationAvatarCell
        XCTAssertNotNil(nameCell)
        
        let aboutMeCellIndexPath = IndexPath(row: 1, section: 0)
        let aboutMeCell = dataSource.tableView(UITableView(), cellForRowAt: aboutMeCellIndexPath)
        XCTAssertNotNil(aboutMeCell)
        
        XCTAssertNotEqual(aboutMeCell, nameCell)
    }
    
    func testValidUsernamesAndDisplayNames() {
        let dataSource = createTestDataSource()
        dataSource.nameAndLocationCell.username = "a_1"
        dataSource.nameAndLocationCell.displayname = "Victorious L. Jackson"
        XCTAssertNil(dataSource.localizedError)
        
        dataSource.nameAndLocationCell.displayname = "012345678901234567890123456789"
        dataSource.nameAndLocationCell.username = "a"
        XCTAssertNil(dataSource.localizedError)
    }
    
    func testInvalidUsernamesAndDisplayNames() {
        let dataSource = createTestDataSource()
        dataSource.nameAndLocationCell.username = "  % &^                       "
        dataSource.nameAndLocationCell.displayname = "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789"
        XCTAssertNotNil(dataSource.localizedError)
        
        dataSource.nameAndLocationCell.username = ""
        XCTAssertNotNil(dataSource.localizedError)
        
        dataSource.nameAndLocationCell.username = "🏓"
        XCTAssertNotNil(dataSource.localizedError)
        
        dataSource.nameAndLocationCell.displayname = ""
        XCTAssertNotNil(dataSource.localizedError)
        
        let testDataPath = Bundle(for: EditProfileDataSourceTests.self).path(forResource: "LoremIpsum", ofType: "txt")
        XCTAssertNotNil(testDataPath)
        
        do {
            let contents = try NSString(contentsOfFile: testDataPath!, usedEncoding: nil)
            dataSource.nameAndLocationCell.displayname = String(contents)
            XCTAssertNotNil(dataSource.localizedError)
        }
        
        catch {
            XCTFail("Could not create test")
        }
    }
}
