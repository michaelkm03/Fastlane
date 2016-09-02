//
//  VIPSubscriptionHelper.swift
//  victorious
//
//  Created by Sharif Ahmed on 7/21/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol VIPSubscriptionHelperDelegate: class {
    func setIsLoading(isLoading: Bool, title: String?)
    func VIPSubscriptionHelperCompletedSubscription(helper: VIPSubscriptionHelper)
}

class VIPSubscriptionHelper {
    
    // MARK: - Constants
    
    // MARK: - Initializing
    
    init(subscriptionFetchURL: String, delegate: VIPSubscriptionHelperDelegate, originViewController: UIViewController, dependencyManager: VDependencyManager) {
        self.subscriptionFetchURL = subscriptionFetchURL
        self.delegate = delegate
        self.originViewController = originViewController
        self.dependencyManager = dependencyManager
    }
    
    // MARK: - Delegate
    
    weak var delegate: VIPSubscriptionHelperDelegate?
    
    // MARK: - Dependency manager
    
    private let dependencyManager: VDependencyManager
    
    // MARK: - Navigating
    
    private weak var originViewController: UIViewController?
    
    // MARK: - Fetching products
    
    private let subscriptionFetchURL: String
    private var products: [VProduct]?
    
    func fetchProducts(completion: ([VProduct]?) -> Void) {
        guard let subscriptionFetchOperation = VIPFetchSubscriptionRemoteOperation(urlString: subscriptionFetchURL) else {
            originViewController?.showSubscriptionAlert(for: VIPFetchSubscriptionRemoteOperation.initError)
            return
        }
        
        delegate?.setIsLoading(true, title: nil)
        
        subscriptionFetchOperation.queue { [weak self] results, error, canceled in
            guard !canceled else {
                self?.delegate?.setIsLoading(false, title: nil)
                return
            }
            
            guard
                let productIdentifiers = results as? [String]
                where error == nil
            else {
                self?.delegate?.setIsLoading(false, title: nil)
                self?.originViewController?.showSubscriptionAlert(for: error)
                return
            }
            
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
    
    private func showSubscriptionSelectionForProducts(products: [VProduct]) {
        guard let originViewController = originViewController else {
            delegate?.setIsLoading(false, title: nil)
            return
        }
        
        let selectSubscription = VIPSelectSubscriptionOperation(products: products, originViewController: originViewController)
        let willShowPrompt = selectSubscription.willShowPrompt
        if willShowPrompt {
            delegate?.setIsLoading(false, title: nil)
        }
        selectSubscription.queue() { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            
            let selectionDependency = strongSelf.dependencyManager.selectionDialogDependency
            
            switch result {
                case .success(let selectedProduct):
                    if willShowPrompt {
                        selectionDependency?.trackButtonEvent(.tap)
                    }
                    self?.delegate?.setIsLoading(true, title: nil)
                    self?.subscribeToProduct(selectedProduct)
                case .failure(let error):
                    if willShowPrompt {
                        selectionDependency?.trackButtonEvent(.cancel)
                    }
                    strongSelf.delegate?.setIsLoading(false, title: nil)
                    originViewController.showSubscriptionAlert(for: error as NSError)
                    self?.delegate?.setIsLoading(false, title: nil)
                    originViewController.showSubscriptionAlert(for: error as NSError)
                case .cancelled:
                    self?.delegate?.setIsLoading(false, title: nil)
            }
        }
    }
    
    private func subscribeToProduct(product: VProduct) {
        let subscribe = VIPSubscribeOperation(product: product, validationURL: dependencyManager.validationURL)
        subscribe.queue() { [weak self] result in
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

// MARK: - String Constants

private struct Strings {
    static let subscriptionFailed       = NSLocalizedString("SubscriptionFailed", comment: "")
    static let subscriptionFetchFailed  = NSLocalizedString("SubscriptionFetchFailed", comment: "")
}

private extension UIViewController {
    func showSubscriptionAlert(for error: NSError?) {
        v_showErrorWithTitle(Strings.subscriptionFailed, message: error?.localizedDescription)
    }
}

private extension VDependencyManager {
    var purchaseDialogDependency: VDependencyManager? {
        return childDependencyForKey("native.store.dialog")
    }
    
    var selectionDialogDependency: VDependencyManager? {
        return childDependencyForKey("multiple.sku.dialog")
    }
    
    var validationURL: NSURL? {
        guard
            let urlString = networkResources?.stringForKey("purchaseURL"),
            let url = NSURL(string: urlString)
        else {
            return nil
        }
        return url
    }
}
