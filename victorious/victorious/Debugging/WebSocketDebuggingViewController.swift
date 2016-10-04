//
//  WebSocketDebuggingViewController.swift
//  victorious
//
//  Created by Sebastian Nystorm on 13/5/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

#if V_ENABLE_WEBSOCKET_DEBUG_MENU

    import UIKit
    import MessageUI

    class WebSocketDebuggingViewController: UITableViewController, MFMailComposeViewControllerDelegate {

        private struct Constants {
            static let cellReuseIdentifier = "DebuggingCell"
            static let defaultEmailRecipients = ["qa@getvictorious.com"]
        }

        var rawMessageContainer: WebSocketRawMessageContainer?

        private lazy var clearButton: UIButton = {
            let clearButton = UIButton(type: .system)
            clearButton.setTitle("Clear", for: .normal)
            clearButton.addTarget(self, action: #selector(clear), for: .touchUpInside)
            return clearButton
        }()

        private lazy var closeButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(close))
        private lazy var exportButton: UIBarButtonItem = UIBarButtonItem(title: "Export", style: .plain, target: self, action: #selector(export))

        private var mailComposerViewController: MFMailComposeViewController?

        // MARK: - UIViewController Lifecycle

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            navigationController?.setNavigationBarHidden(false, animated: animated)
            
            VTimerManager.scheduledTimerManager(withTimeInterval: 1, target: self, selector: #selector(refresh), userInfo: nil, repeats: true)
        }

        override func viewDidLoad() {
            super.viewDidLoad()
            navigationItem.titleView = clearButton
            navigationItem.leftBarButtonItem = closeButton
            navigationItem.rightBarButtonItem = exportButton

            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = 60
        }

        // MARK: - UITableViewDataSource

        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            guard let rawMessageContainer = rawMessageContainer else {
                return 0
            }
            return rawMessageContainer.messageContainer.count
        }

        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellReuseIdentifier) as! DebugCell
            let currentRow = indexPath.row
            guard let rawMessageContainer = rawMessageContainer else {
                assertionFailure("we should have a message container")
                return UITableViewCell()
            }
            
            guard rawMessageContainer.messageCount > currentRow else {
                cell.textLabel?.text = "error"
                cell.detailTextLabel?.text = "error"
                return cell
            }
            let message = rawMessageContainer.messageContainer[currentRow]
            cell.data = DebugCell.ViewData(message: message.messageString, creationDate: message.creationDate as Date)
            return cell
        }

        // MARK: - UITableViewDelegate

        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            guard let rawMessageContainer = rawMessageContainer else {
                assertionFailure("we should have a message container")
                return
            }
            
            let message = rawMessageContainer.messageContainer[indexPath.row]
            let detailedViewController = WebSocketMessageDetailViewController.newWithMessage(message: message)
            show(detailedViewController, sender: nil)
        }

        // MARK: - Event response

        @objc private func refresh() {
            tableView.reloadData()
        }
        
        @objc private func clear() {
            rawMessageContainer?.clearMessages()
            refresh()
        }
        
        @objc private func close() {
            dismiss(animated: true, completion: nil)
        }

        @objc private func export() {
            if let allMessagesString = rawMessageContainer?.exportAllMessages() , MFMailComposeViewController.canSendMail() {
                let mailComposerViewController = MFMailComposeViewController()
                mailComposerViewController.mailComposeDelegate = self
                mailComposerViewController.setSubject("WebSocket messages log 4 u <3")
                mailComposerViewController.setToRecipients(Constants.defaultEmailRecipients)
                mailComposerViewController.setMessageBody(allMessagesString, isHTML: false)

                self.mailComposerViewController = mailComposerViewController
                present(mailComposerViewController, animated: true, completion: nil)
            }
        }

        // MARK: - MFMailComposeViewControllerDelegate

        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true, completion: nil)
        }
    }
    
    class DebugCell: UITableViewCell {
        
        struct ViewData {
            let message: String
            let creationDate: Date
        }
        
        var data: ViewData? {
            didSet {
                dateLabel.text = data?.creationDate.stringDescribingTimeIntervalSinceNow(format: .concise, precision: .seconds)
                messageLabel.text = data?.message
            }
        }
        
        @IBOutlet private weak var dateLabel: UILabel!
        @IBOutlet private weak var messageLabel: UILabel!
        
    }
    
#endif
