//
//  VIPSelectSubscriptionOperation.swift
//  victorious
//
//  Created by Sharif Ahmed on 7/20/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

final class VIPSelectSubscriptionOperation: AsyncOperation<VProduct>, UIAlertViewDelegate {
    let products: [VProduct]
    
    let originViewController: UIViewController
    
    let willShowPrompt: Bool
    
    init(products: [VProduct], originViewController: UIViewController) {
        self.products = products
        self.willShowPrompt = products.count > 1
        self.originViewController = originViewController
    }
    
    override var executionQueue: Queue {
        return .main
    }
    
    override func execute(_ finish: @escaping (_ result: OperationResult<VProduct>) -> Void) {
        guard willShowPrompt else {
            if let firstProduct = products.first {
                finish(.success(firstProduct))
            }
            else {
                let error = NSError(domain: "No valid product", code: -1, userInfo: ["products: ": products])
                finish(.failure(error))
            }
            return
        }
        
        let alert = UIAlertController(title: Strings.alertTitle, message: Strings.alertMessage, preferredStyle: .alert)
        for product in products {
            // We only add a product to selection if there's valid price and description
            guard let price = product.price, let description = product.localizedDescription else {
                Log.warning("A Subscription Product doesn't have valid price or localizedDescription. Product: \(product)")
                continue
            }
            
            let action = UIAlertAction(title: price + " " + description, style: .default) { action in
                finish( .success(product))
            }
            
            alert.addAction(action)
        }
        
        // If we added no product to the selection, that means we don't have any valid products.
        guard alert.actions.count > 0 else {
            finish(.failure(NSError(domain: "Incomplete product information", code: -2, userInfo: ["products: ": products])))
            return
        }
        
        let action = UIAlertAction(title: Strings.cancel, style: .default) { action in
            finish(.cancelled)
        }
        alert.addAction(action)
        originViewController.present(alert, animated: true, completion: nil)
    }
    
    fileprivate struct Strings {
        static let alertTitle = NSLocalizedString("Become a VIP", comment: "Prompt for purchasing VIP subscription")
        static let alertMessage = NSLocalizedString("Select payment schedule", comment: "Subtitle for VIP subscription dialog")
        static let cancel = NSLocalizedString("Cancel", comment: "")
    }
}
