//
//  VIPSelectSubscriptionOperation.swift
//  victorious
//
//  Created by Sharif Ahmed on 7/20/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class VIPSelectSubscriptionOperation: AsyncWaitingOperation, UIAlertViewDelegate {
    let products: [VProduct]
    
    let originViewController: UIViewController
    
    let willShowPrompt: Bool
    
    private(set) var selectedProduct: VProduct?
    
    init(products: [VProduct], originViewController: UIViewController) {
        self.products = products
        self.willShowPrompt = products.count > 1
        self.originViewController = originViewController
    }
    
    private func selectionHandler(for product: VProduct?) -> (UIAlertAction -> ()) {
        return { [weak self] (alertAction: UIAlertAction) in
            self?.asyncCallBack()
            self?.selectedProduct = product
        }
    }
    
    override func main() {
        guard willShowPrompt else {
            selectedProduct = products.first
            return
        }
        
        performUITask { [unowned self] in
            let alert = UIAlertController(title: Strings.alertTitle, message: Strings.alertMessage, preferredStyle: .Alert)
            for product in self.products {
                let action = UIAlertAction(title: product.price + " " + product.localizedDescription, style: .Default, handler: self.selectionHandler(for: product))
                alert.addAction(action)
            }
            let action = UIAlertAction(title: Strings.cancel, style: .Default, handler: self.selectionHandler(for: nil))
            alert.addAction(action)
            self.originViewController.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    private struct Strings {
        static let alertTitle = NSLocalizedString("Become a VIP", comment: "Prompt for purchasing VIP subscription")
        static let alertMessage = NSLocalizedString("Select payment schedule", comment: "Subtitle for VIP subscription dialog")
        static let cancel = NSLocalizedString("Cancel", comment: "Cancel on VIP subscription dialog")

    }
}
