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

        NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidEnterBackgroundNotification, object: nil, queue: nil) { [weak self] (notification) in
            self?.tearDown()
        }

        NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationWillEnterForegroundNotification, object: nil, queue: nil) { [weak self] (notification) in
            if self?.isSetUp == false && self?.childEventReceivers.isEmpty == false {
                self?.setUp()
            }
        }
    }
    
    // MARK: - Configuration

    private struct Reconnect {
        /// The initial time to wait before reconnecting upon disconnection.
        static let initialTimeout = NSTimeInterval(2)

        /// A randomized reconnect padding is added so all clients won't reconnect at the same time.
        static let timeoutPadding = UInt32(3)

        /// The cap that the reconnect timeout can increase to.
        static let maxTimeout = NSTimeInterval(15)

        static func increaseReconnectTimeout(reconnectTimeout: NSTimeInterval) -> NSTimeInterval {
            let increasedReconnectTimeout = reconnectTimeout + NSTimeInterval(arc4random_uniform(Reconnect.timeoutPadding)) + 1
            return min(increasedReconnectTimeout, maxTimeout)
        }
    }

    /// The reconnect timeout used at the moment, will reset when we explicitly close the WS. Set to 0 to disable reconnecting.
    private var currentReconnectTimeout: NSTimeInterval = Reconnect.initialTimeout

    // MARK: - ForumEventReceiver
    
    private(set) var childEventReceivers = [ForumEventReceiver]()
    
    func receive(event: ForumEvent) {
        switch event {
            case .websocket(let websocketEvent):
                switch websocketEvent {
                    case .disconnected(let webSocketError):
                        receiveDisconnectEventWithError(webSocketError)
                    default: break
                }
            default:
                break
        }
    }
    
    private func receiveDisconnectEventWithError(error: WebSocketError?) {
        guard let _ = error where currentReconnectTimeout > 0 && VCurrentUser.isLoggedIn() else {
            return
        }

        currentReconnectTimeout = Reconnect.increaseReconnectTimeout(currentReconnectTimeout)
        dispatch_after(currentReconnectTimeout) { [weak self] in
            self?.setUpIfNeeded()
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

        // The reconnect timeout is reset whenever the WS is closed explicitly.
        currentReconnectTimeout = Reconnect.initialTimeout
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
