//
//  VIPSelectSubscriptionOperation.swift
//  victorious
//
//  Created by Sharif Ahmed on 7/20/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import VictoriousIOSSDK

final class VIPSelectSubscriptionOperation: AsyncOperation<VProduct>, UIAlertViewDelegate {
    let products: [VProduct]
    let originViewController: UIViewController
    let willShowPrompt: Bool
    let dependencyManager: VDependencyManager
    
    init(products: [VProduct], originViewController: UIViewController, dependencyManager: VDependencyManager) {
        self.products = products
        self.willShowPrompt = products.count > 1
        self.originViewController = originViewController
        self.dependencyManager = dependencyManager
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
        
        let alert = UIAlertController(title: dependencyManager.selectionTitle, message: dependencyManager.selectionDetails, preferredStyle: .alert)
        
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
        
        let action = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default) { action in
            finish(.cancelled)
        }
        alert.addAction(action)
        
        originViewController.present(alert, animated: true, completion: nil)
    }
}

private extension VDependencyManager {
    var selectionTitle: String? {
        return string(forKey: "title.text")
    }
    
    var selectionDetails: String? {
        return string(forKey: "details.text")
    }
}
