//
//  ShowTestPurchaseConfirmationOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

@objc enum VTestPurchaseConfirmationType: Int {
    case Subscription
    case Product
}

class ShowTestPurchaseConfirmationOperation: BackgroundOperation, ActionConfirmationOperation {
    
    private let type: VTestPurchaseConfirmationType
    private let title: String?
    private let price: String?
    
    // MARK: - ActionConfirmationOperation
    
    var didConfirmAction: Bool = false
    
    init(type: VTestPurchaseConfirmationType, title: String?, price: String?) {
        self.type = type
        self.price = price
        self.title = title
    }
    
    override func start() {
        beganExecuting()
        
        dispatch_async( dispatch_get_main_queue() ) {
            self.showAlert()
        }
    }
    
    private func showAlert() {
        
        let alertController = UIAlertController(
            title: type.tite,
            message: type.messageWithTitle(title ?? "[ITEM]", price: price ?? "[PRICE]") + "\n\n[Simulated for testing]",
            preferredStyle: .Alert
        )
        alertController.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .Cancel,
                handler: { action in
                    self.cancel()
                    self.finishedExecuting()
                }
            )
        )
        alertController.addAction(
            UIAlertAction(
                title: type.confirmTitle,
                style: .Default,
                handler: { action in
                    self.didConfirmAction = true
                    self.finishedExecuting()
                }
            )
        )
        if let rootVC = (UIApplication.sharedApplication().delegate as! VAppDelegate).window.rootViewController {
            var targetVC = rootVC.presentedViewController ?? rootVC
            if let nav = (targetVC as? VNavigationController)?.innerNavigationController {
                targetVC = nav.topViewController?.presentedViewController ?? nav.topViewController!
            }
            targetVC.presentViewController(alertController, animated: true, completion: nil)
        }
    }
}

private extension VTestPurchaseConfirmationType {
    
    var confirmTitle: String {
        switch self {
        case .Subscription:
            return "Confirm"
        case .Product:
            return "Buy"
        }
    }
    
    var tite: String {
        switch self {
        case .Subscription:
            return "Confirm Your Subscription"
        case .Product:
            return "Confirm You In-App Purchase"
        }
    }
    
    func messageWithTitle(title: String, price: String) -> String {
        switch self {
        case .Subscription:
            return "Do you want to subscribe to \(title) for 1 month for \(price)?  This subscription will automatically renew until canceled."
        case .Product:
            return "Do you want to buy \(title) for \(price)"
        }
    }
}
