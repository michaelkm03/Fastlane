//
//  VIPSelectSubscriptionOperation.swift
//  victorious
//
//  Created by Sharif Ahmed on 7/20/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class VIPSelectSubscriptionOperation: MainQueueOperation, UIAlertViewDelegate {
    let products: [VProduct]
    
    let originViewController: UIViewController
    
    let willShowPrompt: Bool
    
    private(set) var selectedProduct: VProduct?
    
    init(products: [VProduct], originViewController: UIViewController) {
        self.products = products
        self.willShowPrompt = products.count != 1
        self.originViewController = originViewController
    }
    
    override func main() {
        guard willShowPrompt else {
            selectedProduct = products.first
            finishedExecuting()
            return
        }
        
        // TODO: Replace / localize strings from Erin
        let alert = UIAlertController(title: "subscribe", message: "select a subscription", preferredStyle: .Alert)
        for product in products {
            let action = UIAlertAction(title: product.price + " " + product.localizedDescription, style: .Default, handler: selectionHandler(for: product))
            alert.addAction(action)
        }
        let action = UIAlertAction(title: "Cancel", style: .Default, handler: selectionHandler(for: nil))
        alert.addAction(action)
        originViewController.presentViewController(alert, animated: true, completion: nil)
    }
    
    private func selectionHandler(for product: VProduct?) -> (UIAlertAction -> ()) {
        return { (alertAction: UIAlertAction) in
            self.selectedProduct = product
            self.finishedExecuting()
        }
    }
}
