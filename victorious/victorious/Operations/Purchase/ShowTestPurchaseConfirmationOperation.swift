//
//  ShowTestPurchaseConfirmationOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

final class ShowTestPurchaseConfirmationOperation: AsyncOperation<Void> {
    
    private let type: VPurchaseType
    private let title: String?
    private let price: String?
    private let duration: String?
    
    // MARK: - ActionConfirmationOperation
    
    var didConfirmAction: Bool = false
    
    init(type: VPurchaseType, title: String?, duration: String?, price: String?) {
        self.type = type
        self.price = price
        self.title = title
        self.duration = duration
    }
    
    override var executionQueue: Queue {
        return .main
    }
    
    override func execute(finish: (result: OperationResult<Void>) -> Void) {
        let alertController = UIAlertController(
            title: type.tite,
            message: type.messageWithTitle(title ?? "[ITEM]", duration: duration ?? "[DESCRIPTION]", price: price ?? "[PRICE]") + "\n\n[Simulated for testing]",
            preferredStyle: .Alert
        )
        alertController.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .Cancel,
                handler: { [weak self] action in
                    self?.cancelDependentOperations()
                    finish(result: .cancelled)
                }
            )
        )
        alertController.addAction(
            UIAlertAction(
                title: type.confirmTitle,
                style: .Default,
                handler: { [weak self] action in
                    self?.didConfirmAction = true
                    finish(result: .success())
                }
            )
        )
        if let rootVC = (UIApplication.sharedApplication().delegate as! AppDelegate).window?.rootViewController {
            let targetVC = rootVC.presentedViewController ?? rootVC
            targetVC.presentViewController(alertController, animated: true, completion: nil)
        }
    }
}

private extension VPurchaseType {
    
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
    
    func messageWithTitle(title: String, duration: String, price: String) -> String {
        switch self {
        case .Subscription:
            return "Do you want to subscribe to \(title) for \(duration) for \(price)?  This subscription will automatically renew until canceled."
        case .Product:
            return "Do you want to buy \(title) for \(price)"
        }
    }
}
