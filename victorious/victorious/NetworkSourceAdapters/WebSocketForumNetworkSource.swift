//
//  WebSocketForumNetworkSource.swift
//  victorious
//
//  Created by Sebastian Nystorm on 12/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousCommon

class WebSocketForumNetworkSource: NSObject, ForumNetworkSource {

    private struct Constants {
        static let appIdExpander = "%%APP_ID%%"
        static let tokenExpander = "%%AUTH_TOKEN%%"
    }
    
    private var webSocketController = WebSocketController.sharedInstance
    
    private let dependencyManager: VDependencyManager
    
    // MARK: - Initialization
    
    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager.networkResources!
        super.init()
        
        // Connect this link in the event chain.
        nextSender = webSocketController
        webSocketController.addChildReceiver(self)

        // Device ID is needed for tracking calls on the backend.
        let deviceID = UIDevice.currentDevice().v_authorizationDeviceID
        webSocketController.setDeviceID(deviceID)
    }
    
    // MARK: - Configuration
    
    /// The amount of time to wait before reconnecting upon disconnection. Set to nil to disable automatic reconnection.
    var reconnectTimeout: NSTimeInterval? = 5.0
    
    // MARK: - ForumEventReceiver
    
    private(set) var childEventReceivers = [ForumEventReceiver]()
    
    func receive(event: ForumEvent) {
        switch event {
        case .websocket(let websocketEvent):
            switch websocketEvent {
                case .disconnected(_):
                    receiveDisconnectEvent()
                default: break
            }
        default:
            break
        }
    }
    
    private func receiveDisconnectEvent() {
        guard let reconnectTimeout = reconnectTimeout else {
            return
        }
        
        if (VCurrentUser.isLoggedIn()) { //Try to reconnect only if the user is still logged in 
            dispatch_after(reconnectTimeout) { [weak self] in
                self?.setUpIfNeeded()
            }
        }
    }
    
    // MARK: - ForumEventSender
    
    weak var nextSender: ForumEventSender?
    
    // MARK: - ForumNetworkSource
    
    func setUp() {
        refreshToken()
    }
    
    func tearDown() {
        webSocketController.tearDown()
    }
    
    var isSetUp: Bool {
        return webSocketController.isSetUp
    }
    
    func addChildReceiver(receiver: ForumEventReceiver) {
        if !childEventReceivers.contains({ $0 === receiver }) {
            childEventReceivers.append(receiver)
        }
    }

    func removeChildReceiver(receiver: ForumEventReceiver) {
        if let index = childEventReceivers.indexOf({ $0 === receiver }) {
            childEventReceivers.removeAtIndex(index)
        }
    }
    
    // MARK: ForumNetworkSourceWebSocket
    
    var webSocketMessageContainer: WebSocketRawMessageContainer {
        return webSocketController.webSocketMessageContainer
    }

    // MARK: Private
    
    private func expandWebSocketURLString(url: String, withToken token: String, applicationID: String) -> NSURL? {
        let webSocketEndPointUserID = url.stringByReplacingOccurrencesOfString(Constants.appIdExpander, withString: applicationID)
        let webSocketEndPoint = webSocketEndPointUserID.stringByReplacingOccurrencesOfString(Constants.tokenExpander, withString: token)
        return NSURL(string: webSocketEndPoint)
    }
    
    private func refreshToken() {
        guard let currentUserID = VCurrentUser.user()?.remoteId
        where VCurrentUser.isLoggedIn() else {
            assertionFailure("No current user is logged in, how did they even get this far?")
            return
        }

        if let operation = CreateChatServiceTokenOperation(expandableURLString: dependencyManager.expandableTokenURL, currentUserID: currentUserID.integerValue) {
            operation.queue() { [weak self] results, error, canceled in
                guard let strongSelf = self,
                    let token = results?.first as? String where !token.characters.isEmpty else {
                        v_log("Failed to parse the token from the response. Results -> \(results)")
                        return
                }

                let currentApplicationID = VEnvironmentManager.sharedInstance().currentEnvironment.appID
                v_log("strongSelf.dependencyManager.expandableSocketURL -> \(strongSelf.dependencyManager.expandableSocketURL)  appId -> \(currentApplicationID.stringValue)")
                guard let url = strongSelf.expandWebSocketURLString(strongSelf.dependencyManager.expandableSocketURL, withToken: token, applicationID: currentApplicationID.stringValue) else {
                    v_log("Failed to generate the WebSocket endpoint using token (\(token)), userID (\(currentUserID)) and template URL (\(strongSelf.dependencyManager.expandableSocketURL)))")
                    return
                }
                
                strongSelf.webSocketController.replaceEndPoint(url)
                strongSelf.webSocketController.setUp()
            }
        }
    }
}

private extension VDependencyManager {
    var expandableTokenURL: String {
        return stringForKey("authURL")
    }
    
    var expandableSocketURL: String {
        return stringForKey("socketURL")
    }
}
