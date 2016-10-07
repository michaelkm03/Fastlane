//
//  WebSocketMessageDetailViewController.swift
//  victorious
//
//  Created by Sharif Ahmed on 5/13/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

#if V_ENABLE_WEBSOCKET_DEBUG_MENU

    import UIKit
    import VictoriousIOSSDK

    class WebSocketMessageDetailViewController: UIViewController {

        @IBOutlet private weak var dateLabel: UILabel!
        @IBOutlet private weak var messageTextView: UITextView!
        @IBOutlet private weak var rawJSONTextView: UITextView!

        private(set) var message: WebSocketRawMessage?

        static func newWithMessage(message: WebSocketRawMessage) -> WebSocketMessageDetailViewController {
            let modelDetailVC: WebSocketMessageDetailViewController = v_initialViewControllerFromStoryboard()
            modelDetailVC.message = message
            return modelDetailVC
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            navigationController?.setNavigationBarHidden(false, animated: animated)
        }

        override func viewDidLoad() {
            super.viewDidLoad()

            if let message = message {
                dateLabel.text = String(describing: message.creationDate)
                messageTextView.text = message.messageString
                rawJSONTextView.text = message.json?.debugDescription
            }
        }
    }
    
#endif
