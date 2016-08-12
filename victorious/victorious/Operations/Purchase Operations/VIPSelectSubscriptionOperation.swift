//
//  VIPSelectSubscriptionOperation.swift
//  victorious
//
//  Created by Sharif Ahmed on 7/20/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class VIPSelectSubscriptionOperation: AsyncOperation<VProduct>, UIAlertViewDelegate {
    let products: [VProduct]
    
    let originViewController: UIViewController
    
    let willShowPrompt: Bool
    
    init(products: [VProduct], originViewController: UIViewController) {
        self.products = products
        self.willShowPrompt = products.count > 1
        self.originViewController = originViewController
    }
    
    override var executionQueue: NSOperationQueue {
        return NSOperationQueue.mainQueue()
    }
    
    override func execute(finish: (result: OperationResult<VProduct>) -> Void) {
        guard willShowPrompt else {
            if let firstProduct = products.first {
                finish(result: .success(firstProduct))
            }
            else {
                let error = NSError(domain: "No valid product", code: -1, userInfo: ["products: ": products])
                finish(result: .failure(error))
            }
            return
        }
        
        let alert = UIAlertController(title: Strings.alertTitle, message: Strings.alertMessage, preferredStyle: .Alert)
        for product in self.products {
            let action = UIAlertAction(title: product.price + " " + product.localizedDescription, style: .Default) { action in
                finish(result: .success(product))
            }
            alert.addAction(action)
        }
        
        let action = UIAlertAction(title: Strings.cancel, style: .Default) { action in
            finish(result: .cancelled)
        }
        alert.addAction(action)
        self.originViewController.presentViewController(alert, animated: true, completion: nil)
    }
    
    private struct Strings {
        static let alertTitle = NSLocalizedString("Become a VIP", comment: "Prompt for purchasing VIP subscription")
        static let alertMessage = NSLocalizedString("Select payment schedule", comment: "Subtitle for VIP subscription dialog")
        static let cancel = NSLocalizedString("Cancel", comment: "Cancel on VIP subscription dialog")

    }
}
