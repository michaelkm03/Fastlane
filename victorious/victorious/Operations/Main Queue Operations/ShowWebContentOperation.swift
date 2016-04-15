//
//  ShowWebContentOperation.swift
//  victorious
//
//  Created by Jarod Long on 4/13/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
import WebKit

class ShowWebContentOperation: MainQueueOperation {
    private let originViewController: UIViewController
    private let title: String
    private let createFetchOperation: () -> FetchWebContentOperation
    private let forceModal: Bool
    private let animated: Bool
    
    init(originViewController: UIViewController, title: String, createFetchOperation: () -> FetchWebContentOperation, forceModal: Bool = false, animated: Bool = true) {
        self.originViewController = originViewController
        self.title = title
        self.createFetchOperation = createFetchOperation
        self.forceModal = forceModal
        self.animated = animated
    }
    
    override func start() {
        beganExecuting()
        
        guard !cancelled else {
            finishedExecuting()
            return
        }
        
        let viewController = VWebContentViewController(nibName: nil, bundle: nil)

        let fetchOperation = createFetchOperation()

        fetchOperation.after(self).queue { [weak fetchOperation] results, error, cancelled in
            guard let fetchOperation = fetchOperation else {
                return
            }

            guard let htmlString = fetchOperation.resultHTMLString where error == nil else {
                viewController.setFailureWithError(error)
                return
            }
            
            viewController.loadViewIfNeeded()

            viewController.webView.loadHTMLString(htmlString, baseURL: fetchOperation.publicBaseURL)
        }
        
        viewController.shouldShowLoadingState = true
        viewController.automaticallyAdjustsScrollViewInsets = false
        viewController.edgesForExtendedLayout = .All
        viewController.extendedLayoutIncludesOpaqueBars = true
        viewController.title = title
        
        if let navigationController = (originViewController as? UINavigationController) ?? originViewController.navigationController where !forceModal {
            navigationController.pushViewController(viewController, animated: animated)
            finishedExecuting()
        }
        else {
            let navigationController = UINavigationController(rootViewController: viewController)
            
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .Done,
                target: viewController,
                action: #selector(VWebContentViewController.dismissSelf)
            )
            
            originViewController.presentViewController(navigationController, animated: animated) {
                self.finishedExecuting()
            }
        }
    }
}
