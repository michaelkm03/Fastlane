//
//  DebugMenuHandler.swift
//  victorious
//
//  Created by Sebastian Nystorm on 19/5/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

#if V_ENABLE_WEBSOCKET_DEBUG_MENU
    import Foundation
    import VictoriousIOSSDK

    /// Type of debug menu to be shown.
    enum DebugMenuType {
        case webSocket(messageContainer: WebSocketRawMessageContainer)
    }

    class DebugMenuHandler {

        private struct Constants {
            static let numberOfTapsRequired = 3
            static let numberOfTouchesRequired = 1
        }

        private var currentDebugMenuType: DebugMenuType?

        private var targetViewController: UIViewController

        init(targetViewController: UIViewController) {
            self.targetViewController = targetViewController
        }

        func setupCurrentDebugMenu(debugMenuType: DebugMenuType, targetView: UIView) {
            currentDebugMenuType = debugMenuType

            let tripleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(presentCurrentDebugMenu))
            tripleTapRecognizer.numberOfTapsRequired = Constants.numberOfTapsRequired
            tripleTapRecognizer.numberOfTouchesRequired = Constants.numberOfTouchesRequired
            targetView.addGestureRecognizer(tripleTapRecognizer)
        }

        @objc func presentCurrentDebugMenu() {
            guard let currentDebugMenuType = currentDebugMenuType else {
                return
            }

            switch currentDebugMenuType {
            case .webSocket(let messageContainer):
                
                let debuggingViewController: WebSocketDebuggingViewController = WebSocketDebuggingViewController.v_initialViewControllerFromStoryboard()
                debuggingViewController.rawMessageContainer = messageContainer
                let navigationController = UINavigationController(rootViewController: debuggingViewController)
                targetViewController.present(navigationController, animated: true, completion: nil)
            }
        }
    }
    
#endif
