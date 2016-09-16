//
//  ListMenuChatRoomsDataSource.swift
//  victorious
//
//  Created by Alex Tamoykin on 9/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

final class ListMenuChatRoomsDataSource: ListMenuSectionDataSource {
    typealias Cell = ListMenuChatRoomCollectionViewCell

    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
    }

    var dependencyManager: VDependencyManager
    weak var delegate: ListMenuSectionDataSourceDelegate?
    var state: ListMenuDataSourceState = .loading
    private(set) var visibleItems: [ChatRoom] = []
    func fetchRemoteData() {
    }
}
