//
//  WebSocketForumNetworkSource.swift
//  victorious
//
//  Created by Sebastian Nystorm on 12/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousCommon
import VictoriousIOSSDK

class WebSocketForumNetworkSource: NSObject, ForumNetworkSource {

    private struct Constants {
        static let appIdExpander = "%%APP_ID%%"
        static let tokenExpander = "%%AUTH_TOKEN%%"
    }

    private var webSocketController = VIPWebSocketController.shared

    private let dependencyManager: VDependencyManager
    
    // MARK: - Initialization
    
    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager.networkResources!
        super.init()
        
        // Connect this link in the event chain.
        nextSender = webSocketController
        webSocketController.addChildReceiver(self)

        // Device ID is needed for tracking calls on the backend.
        let deviceID = UIDevice.current.v_authorizationDeviceID
        webSocketController.setDeviceID(deviceID: deviceID)

        NotificationCenter.default.addObserver(forName: .UIApplicationDidEnterBackground, object: nil, queue: nil) { [weak self] _ in
            self?.tearDown()
        }

        NotificationCenter.default.addObserver(forName: .UIApplicationWillEnterForeground, object: nil, queue: nil) { [weak self] _ in
            if self?.isSetUp == false && self?.childEventReceivers.isEmpty == false {
                self?.setUp()
            }
        }
    }
    
    // MARK: - Configuration

    private struct Reconnector {
        /// The initial time to wait before reconnecting upon disconnection.
        static let initialTimeout = TimeInterval(2)

        /// A randomized reconnect padding is added so all clients won't reconnect at the same time.
        static let timeoutPadding = UInt32(3)

        /// The cap that the reconnect timeout can increase to.
        static let maxTimeout = TimeInterval(25)

        static func increaseReconnectTimeout(_ reconnectTimeout: TimeInterval) -> TimeInterval {
            let increasedReconnectTimeout = reconnectTimeout + TimeInterval(arc4random_uniform(Reconnector.timeoutPadding)) + 1
            return min(increasedReconnectTimeout, maxTimeout)
        }
    }

    /// The reconnect timeout used at the moment, will reset when we explicitly close the WS. Set to 0 to disable reconnecting.
    private var currentReconnectTimeout: TimeInterval = Reconnector.initialTimeout

    // MARK: - ForumEventReceiver
    
    private(set) var childEventReceivers = [ForumEventReceiver]()
    
    func receive(_ event: ForumEvent) {
        switch event {
            case .websocket(let websocketEvent):
                switch websocketEvent {
                    case .connected:
                        currentReconnectTimeout = Reconnector.initialTimeout
                    case .disconnected(let webSocketError):
                        receiveDisconnectEventWithError(webSocketError)
                    default: break
                }
            default:
                break
        }
    }
    
    private func receiveDisconnectEventWithError(_ error: WebSocketError?) {
        guard let _ = error , currentReconnectTimeout > 0 && VCurrentUser.user != nil else {
            return
        }

        currentReconnectTimeout = Reconnector.increaseReconnectTimeout(currentReconnectTimeout)
        dispatch_after(currentReconnectTimeout) { [weak self] in
            self?.setUpIfNeeded()
        }
    }
    
    // MARK: - ForumEventSender
    
    weak var nextSender: ForumEventSender?
    
    // MARK: - ForumNetworkSource
    
    func setUp() {
        refreshToken()
        broadcast(.setOptimisticPostingEnabled(false))
        broadcast(.setChatActivityIndicatorEnabled(false))
    }
    
    func tearDown() {
        webSocketController.tearDown()

        // The reconnect timeout is reset whenever the WS is closed explicitly.
        currentReconnectTimeout = Reconnector.initialTimeout
    }
    
    var isSetUp: Bool {
        return webSocketController.isSetUp
    }
    
    func addChildReceiver(_ receiver: ForumEventReceiver) {
        if !childEventReceivers.contains(where: { $0 === receiver }) {
            childEventReceivers.append(receiver)
        }
    }

    func removeChildReceiver(_ receiver: ForumEventReceiver) {
        if let index = childEventReceivers.index(where: { $0 === receiver }) {
            childEventReceivers.remove(at: index)
        }
    }
    
    // MARK: ForumNetworkSourceWebSocket
    
    var webSocketMessageContainer: WebSocketRawMessageContainer {
        return webSocketController.webSocketMessageContainer
    }

    // MARK: Private
    
    private func expandWebSocketURLString(_ url: String, withToken token: String, applicationID: String) -> URL? {
        guard !url.isEmpty else {
            return nil
        }
        
        let webSocketEndPointUserID = url.replacingOccurrences(of: Constants.appIdExpander, with: applicationID)
        let webSocketEndPoint = webSocketEndPointUserID.replacingOccurrences(of: Constants.tokenExpander, with: token)
        return URL(string: webSocketEndPoint)
    }
    
    private func refreshToken() {
        guard let currentUserID = VCurrentUser.user?.id else {
            assertionFailure("No current user is logged in, how did they even get this far?")
            return
        }
        
        guard
            let apiPath = dependencyManager.expandableTokenAPIPath,
            let request = CreateChatServiceTokenRequest(apiPath: apiPath, currentUserID: currentUserID)
        else {
            return
        }
        
        RequestOperation(request: request).queue { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            
            switch result {
                case .success(let token):
                    let currentApplicationID = VEnvironmentManager.sharedInstance().currentEnvironment.appID
                    Log.verbose("strongSelf.dependencyManager.expandableSocketURL -> \(strongSelf.dependencyManager.expandableSocketURL)  appId -> \(currentApplicationID.stringValue)")
                    
                    guard let url = strongSelf.expandWebSocketURLString(strongSelf.dependencyManager.expandableSocketURL, withToken: token, applicationID: currentApplicationID.stringValue) else {
                        Log.warning("Failed to generate the WebSocket endpoint using token (\(token)), userID (\(currentUserID)) and template URL (\(strongSelf.dependencyManager.expandableSocketURL)))")
                        return
                    }
                    
                    strongSelf.webSocketController.replaceEndPoint(endPoint: url)
                    strongSelf.webSocketController.setUp()
                
                case .failure(let error):
                    Log.warning("Failed to parse the token from the response. Error -> \(error)")
                
                case .cancelled:
                    break
            }
        }
    }
}

private extension VDependencyManager {
    var expandableTokenAPIPath: APIPath? {
        return apiPath(forKey: "authURL")
    }
    
    var expandableSocketURL: String {
        return string(forKey: "socketURL") ?? ""
    }
}
