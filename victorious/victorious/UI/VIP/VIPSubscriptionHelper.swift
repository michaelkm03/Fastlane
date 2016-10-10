//
//  VIPSubscriptionHelper.swift
//  victorious
//
//  Created by Sharif Ahmed on 7/21/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

protocol VIPSubscriptionHelperDelegate: class {
    func setIsLoading(_ isLoading: Bool, title: String?)
    func VIPSubscriptionHelperCompletedSubscription(_ helper: VIPSubscriptionHelper)
}

class VIPSubscriptionHelper {
    
    // MARK: - Initializing
    
    init(subscriptionFetchAPIPath: APIPath, delegate: VIPSubscriptionHelperDelegate, originViewController: UIViewController, dependencyManager: VDependencyManager) {
        self.subscriptionFetchAPIPath = subscriptionFetchAPIPath
        self.delegate = delegate
        self.originViewController = originViewController
        self.dependencyManager = dependencyManager
    }
    
    // MARK: - Delegate
    
    weak var delegate: VIPSubscriptionHelperDelegate?
    
    // MARK: - Dependency manager
    
    fileprivate let dependencyManager: VDependencyManager
    
    // MARK: - Navigating
    
    fileprivate weak var originViewController: UIViewController?
    
    // MARK: - Fetching products
    
    fileprivate let subscriptionFetchAPIPath: APIPath
    fileprivate var products: [VProduct]?
    
    func fetchProducts(_ completion: @escaping ([VProduct]?) -> Void) {
        guard let request = VIPFetchSubscriptionRequest(apiPath: subscriptionFetchAPIPath) else {
            return
        }
        
        delegate?.setIsLoading(true, title: nil)
        
        RequestOperation(request: request).queue { [weak self] result in
            switch result {
                case .success(let productIdentifiers):
                    ProductFetchOperation(productIdentifiers: productIdentifiers).queue { [weak self] result in
                        self?.delegate?.setIsLoading(false, title: nil)
                        
                        switch result {
                            case .success(let products):
                                self?.products = products
                                completion(products)
                            case .failure(let error):
                                self?.originViewController?.showSubscriptionAlert(for: error as NSError)
                            case .cancelled: break
                        }
                    }
                
                case .failure(let error):
                    self?.originViewController?.showSubscriptionAlert(for: error as NSError)
                
                case .cancelled:
                    self?.delegate?.setIsLoading(false, title: nil)
            }
        }
    }
    
    // MARK: - Subscribing
    
    func subscribe() {
        if let products = products {
            showSubscriptionSelectionForProducts(products)
        }
        else {
            fetchProducts { [weak self] products in
                guard let products = products else {
                    return
                }
                
                self?.products = products
                self?.subscribe()
            }
        }
    }
    
    fileprivate func showSubscriptionSelectionForProducts(_ products: [VProduct]) {
        guard
            let originViewController = originViewController,
            let selectionDependency = dependencyManager.selectionDialogDependency
        else {
            Log.error("We want to show subscription selection dialog, but got invalid originViewController or selectionDependencyManager")
            delegate?.setIsLoading(false, title: nil)
            return
        }
        
        let selectSubscription = VIPSelectSubscriptionOperation(products: products, originViewController: originViewController, dependencyManager: selectionDependency)
        let willShowPrompt = selectSubscription.willShowPrompt
        if willShowPrompt {
            delegate?.setIsLoading(false, title: nil)
        }
        selectSubscription.queue() { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            
            switch result {
                case .success(let selectedProduct):
                    if willShowPrompt {
                        selectionDependency.trackButtonEvent(.tap)
                    }
                    self?.delegate?.setIsLoading(true, title: nil)
                    self?.subscribeToProduct(selectedProduct)
                case .failure(let error):
                    strongSelf.delegate?.setIsLoading(false, title: nil)
                    originViewController.showSubscriptionAlert(for: error as NSError)
                    self?.delegate?.setIsLoading(false, title: nil)
                    originViewController.showSubscriptionAlert(for: error as NSError)
                case .cancelled:
                    if willShowPrompt {
                        selectionDependency.trackButtonEvent(.cancel)
                    }
                    self?.delegate?.setIsLoading(false, title: nil)
            }
        }
    }
    
    fileprivate func subscribeToProduct(_ product: VProduct) {
        guard let validationAPIPath = dependencyManager.validationAPIPath else {
            return
        }
        
        let subscribe = VIPSubscribeOperation(product: product, validationAPIPath: validationAPIPath)
        
        subscribe.queue { [weak self] result in
            self?.delegate?.setIsLoading(false, title: nil)
            
            guard let strongSelf = self  else {
                return
            }
            
            switch result {
                case .success:
                    strongSelf.delegate?.VIPSubscriptionHelperCompletedSubscription(strongSelf)
                case .failure(let error):
                    strongSelf.originViewController?.showSubscriptionAlert(for: error as NSError)
                case .cancelled:
                    break
            }
        }
    }
}

private extension UIViewController {
    func showSubscriptionAlert(for error: NSError?) {
        v_showErrorWithTitle(
            NSLocalizedString("SubscriptionFailed", comment: "Subscription failed for the user"),
            message: NSLocalizedString("PleaseTryAgainLater", comment: "Tells the user to try again later")
        )
        Log.warning("Subscription failed with error: \(error)")
    }
}

private extension VDependencyManager {
    var purchaseDialogDependency: VDependencyManager? {
        return childDependency(forKey: "native.store.dialog")
    }
    
    var selectionDialogDependency: VDependencyManager? {
        return childDependency(forKey: "multiple.sku.dialog")
    }
    
    var validationAPIPath: APIPath? {
        return networkResources?.apiPath(forKey: "purchaseURL")
    }
}
