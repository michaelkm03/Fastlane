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

        let rawMessageContainer: WebSocketRawMessageContainer

        private lazy var clearButton: UIButton = {
            let clearButton = UIButton(type: .System)
            clearButton.setTitle("Clear", forState: .Normal)
            clearButton.addTarget(self, action: #selector(clear), forControlEvents: .TouchUpInside)
            return clearButton
        }()

        private lazy var refreshBarButtonItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: #selector(refresh))

        private lazy var closeButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(close))

        init(rawMessageContainer: WebSocketRawMessageContainer) {
            self.rawMessageContainer = rawMessageContainer
            super.init(style: .Plain)
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        // MARK: - UIViewController Lifecycle

        override func viewWillAppear(animated: Bool) {
            super.viewWillAppear(animated)
            navigationController?.setNavigationBarHidden(false, animated: animated)
        }

        override func viewDidLoad() {
            super.viewDidLoad()
            navigationItem.titleView = clearButton
            navigationItem.rightBarButtonItem = refreshBarButtonItem
            navigationItem.leftBarButtonItem = closeButton

            tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: Constants.cellReuseIdentifier)
        }

        // MARK: - UITableViewDataSource

        override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return rawMessageContainer.messageContainer.count
        }

        override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCellWithIdentifier(Constants.cellReuseIdentifier)!
            let currentRow = indexPath.row
            guard rawMessageContainer.messageCount > currentRow else {
                v_log("Trying to get an event out of bounds of the current events array")
                cell.textLabel?.text = "error"
                cell.detailTextLabel?.text = "error"
                return cell
            }
            let message = rawMessageContainer.messageContainer[currentRow]
            cell.textLabel?.font = UIFont(name: "Menlo-Regular", size: 9)
            cell.textLabel?.text = message.messageString
            cell.detailTextLabel?.text = "\(message.creationDate)"

            return cell
        }

        // MARK: - UITableViewDelegate

        override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            let message = rawMessageContainer.messageContainer[indexPath.row]
            let detailedViewController = WebSocketMessageDetailViewController.newWithMessage(message)
            showViewController(detailedViewController, sender: nil)
        }

        // MARK: - Event response

        @objc private func refresh() {
            tableView.reloadData()
        }
        
        @objc private func clear() {
            rawMessageContainer.clearMessages()
            refresh()
        }
        
        @objc private func close() {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
#endif
