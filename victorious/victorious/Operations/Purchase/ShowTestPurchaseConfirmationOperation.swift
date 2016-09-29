//
//  ShowTestPurchaseConfirmationOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

final class ShowTestPurchaseConfirmationOperation: AsyncOperation<Void> {
    
    fileprivate let type: VPurchaseType
    fileprivate let title: String?
    fileprivate let price: String?
    fileprivate let duration: String?
    
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
    
    override func execute(_ finish: @escaping (_ result: OperationResult<Void>) -> Void) {
        let alertController = UIAlertController(
            title: type.tite,
            message: type.messageWithTitle(title ?? "[ITEM]", duration: duration ?? "[DESCRIPTION]", price: price ?? "[PRICE]") + "\n\n[Simulated for testing]",
            preferredStyle: .alert
        )
        alertController.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .Cancel,
                handler: { action in
                    finish(.cancelled)
                }
            )
        )
        alertController.addAction(
            UIAlertAction(
                title: type.confirmTitle,
                style: .default,
                handler: { [weak self] action in
                    self?.didConfirmAction = true
                    finish(.success())
                }
            )
        )
        if let rootVC = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController {
            let targetVC = rootVC.presentedViewController ?? rootVC
            targetVC.present(alertController, animated: true, completion: nil)
        }
    }
    
}

private extension VPurchaseType {
    
    var confirmTitle: String {
        switch self {
        case .subscription:
            return "Confirm"
        case .product:
            return "Buy"
        }
    }
    
    var tite: String {
        switch self {
        case .subscription:
            return "Confirm Your Subscription"
        case .product:
            return "Confirm You In-App Purchase"
        }
    }
    
    func messageWithTitle(_ title: String, duration: String, price: String) -> String {
        switch self {
        case .subscription:
            return "Do you want to subscribe to \(title) for \(duration) for \(price)?  This subscription will automatically renew until canceled."
        case .product:
            return "Do you want to buy \(title) for \(price)"
        }
    }
}
