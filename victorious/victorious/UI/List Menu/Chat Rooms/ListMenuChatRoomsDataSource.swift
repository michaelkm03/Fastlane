//
//  ListMenuChatRoomsDataSource.swift
//  victorious
//
//  Created by Alex Tamoykin on 9/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

final class ListMenuChatRoomsDataSource: ListMenuSectionDataSource {

    // MARK: - ListMenuSectionDataSource

    typealias Cell = ListMenuChatRoomCollectionViewCell
    let dependencyManager: VDependencyManager
    weak var delegate: ListMenuSectionDataSourceDelegate?
    private(set) var state: ListMenuDataSourceState = .loading
    private(set) var visibleItems: [ChatRoom] = [] {
        didSet {
            state = visibleItems.isEmpty ? .noContent : .items
            delegate?.didUpdateVisibleItems(forSection: .chatRooms)
        }
    }

    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
        self.requestExecutor = MainRequestExecutor()
    }

    func fetchRemoteData() {
        guard
            let apiPath = dependencyManager.networkResources?.apiPathForKey(Constants.Keys.chatRoomsURL),
            let request = ChatRoomsRequest(apiPath: apiPath)
        else {
            Log.warning("Missing chat rooms API path")
            return
        }

        let operation = RequestOperation(request: request)
        operation.requestExecutor = requestExecutor
        operation.queue() { [weak self] result in
            switch result {
                case .success(let chatRooms):
                    self?.visibleItems = chatRooms
                    self?.onFetchDataSuccess?()

                case .failure(let error):
                    self?.state = .failed(error: error)
                    self?.delegate?.didUpdateVisibleItems(forSection: .chatRooms)

                case .cancelled:
                    self?.delegate?.didUpdateVisibleItems(forSection: .chatRooms)
            }
        }
    }

    // MARK: - DependencyManager properties

    var chatRoomStreamAPIPath: APIPath {
        return dependencyManager.apiPathForKey(Constants.Keys.chatRoomStreamURL) ?? APIPath(templatePath: "")
    }

    var chatRoomStreamTrackingURLs: [String] {
        return dependencyManager.trackingURLsForKey(Constants.Keys.chatRoomViewTrackingURL) as? [String] ?? []
    }

    // MARK: - Internals

    var onFetchDataSuccess: (() -> ())?
    var requestExecutor: RequestExecutorType = MainRequestExecutor()
    private struct Constants {
        struct Keys {
            static let chatRoomsURL = "chat.rooms.URL"
            static let chatRoomStreamURL = "streamURL"
            static let chatRoomViewTrackingURL = "view"
        }
    }
}
