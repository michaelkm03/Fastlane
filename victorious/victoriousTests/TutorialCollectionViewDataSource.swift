//
//  TutorialCollectionViewDataSource.swift
//  victorious
//
//  Created by Jarod Long on 9/20/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest

@testable import victorious

class TutorialCollectionViewDataSourceTests: XCTestCase, ForumEventReceiver {
    let dataSource = TutorialCollectionViewDataSource(dependencyManager: VDependencyManager(dictionary: [:]))
    
    let collectionView = UICollectionView(
        frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 200.0),
        collectionViewLayout: UICollectionViewFlowLayout()
    )
    
    override func setUp() {
        super.setUp()
        collectionView.dataSource = dataSource
        dataSource.registerCells(for: collectionView)
    }
    
    func testHidesReplyButton() {
        let networkDataSource = dataSource.networkDataSource as! TutorialNetworkDataSource
        
        networkDataSource.visibleItems = [ChatFeedContent(
            content: Content(text: "yo"),
            width: 100.0,
            dependencyManager: VDependencyManager(dictionary: [:])
        )!]
        
        let cell = dataSource.collectionView(collectionView, cellForItemAtIndexPath: IndexPath(forItem: 0, inSection: 0)) as! ChatFeedMessageCell
        XCTAssertFalse(cell.showsReplyButton)
    }
}
