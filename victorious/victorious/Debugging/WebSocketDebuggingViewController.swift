//
//  WebSocketDebuggingViewController.swift
//  victorious
//
//  Created by Sebastian Nystorm on 13/5/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

#if V_ENABLE_WEBSOCKET_DEBUG_MENU

    import UIKit

    class WebSocketDebuggingViewController: UITableViewController {

        private struct Constants {
            static let cellReuseIdentifier = "DebuggingCell"
        }

        var rawMessageContainer: WebSocketRawMessageContainer?

        private lazy var clearButton: UIButton = {
            let clearButton = UIButton(type: .System)
            clearButton.setTitle("Clear", forState: .Normal)
            clearButton.addTarget(self, action: #selector(clear), forControlEvents: .TouchUpInside)
            return clearButton
        }()

        private lazy var closeButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(close))

        // MARK: - UIViewController Lifecycle

        override func viewWillAppear(animated: Bool) {
            super.viewWillAppear(animated)
            navigationController?.setNavigationBarHidden(false, animated: animated)
            
            VTimerManager.scheduledTimerManagerWithTimeInterval(1, target: self, selector: #selector(refresh), userInfo: nil, repeats: true)
        }

        override func viewDidLoad() {
            super.viewDidLoad()
            navigationItem.titleView = clearButton
            navigationItem.leftBarButtonItem = closeButton

            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = 60
        }

        // MARK: - UITableViewDataSource

        override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            guard let rawMessageContainer = rawMessageContainer else {
                return 0
            }
            return rawMessageContainer.messageContainer.count
        }

        override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCellWithIdentifier(Constants.cellReuseIdentifier) as! DebugCell
            let currentRow = indexPath.row
            guard let rawMessageContainer = rawMessageContainer else {
                assertionFailure("we should have a message container")
                return UITableViewCell()
            }
            
            guard rawMessageContainer.messageCount > currentRow else {
                v_log("Trying to get an event out of bounds of the current events array")
                cell.textLabel?.text = "error"
                cell.detailTextLabel?.text = "error"
                return cell
            }
            let message = rawMessageContainer.messageContainer[currentRow]
            cell.data = DebugCell.ViewData(message: message.messageString, creationDate: message.creationDate)
            return cell
        }

        // MARK: - UITableViewDelegate

        override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            guard let rawMessageContainer = rawMessageContainer else {
                assertionFailure("we should have a message container")
                return
            }
            
            let message = rawMessageContainer.messageContainer[indexPath.row]
            let detailedViewController = WebSocketMessageDetailViewController.newWithMessage(message)
            showViewController(detailedViewController, sender: nil)
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
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    class DebugCell: UITableViewCell {
        
        struct ViewData {
            let message: String
            let creationDate: NSDate
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
