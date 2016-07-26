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
    weak var originViewController: UIViewController?
    
    weak var delegate: VIPSubscriptionHelperDelegate?
    
    let subscriptionFetchURL: String
    
    init(subscriptionFetchURL: String, delegate: VIPSubscriptionHelperDelegate, originViewController: UIViewController) {
        self.subscriptionFetchURL = subscriptionFetchURL
        self.delegate = delegate
        self.originViewController = originViewController
    }
    
    func subscribe() {
        do {
            let subscriptionFetchOperation = try VIPFetchSubscriptionRemoteOperation(urlString: subscriptionFetchURL)
            delegate?.setIsLoading(true, title: nil)
            subscriptionFetchOperation.queue() { [weak self] results, error, canceled in
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
                self?.fetchProductsForIdentifiers(productIdentifiers)
            }
        } catch let error as NSError {
            originViewController?.showSubscriptionAlert(for: error)
        }
    }
    
    private func fetchProductsForIdentifiers(identifiers: [String]) {
        let productFetchOperation = ProductFetchOperation(productIdentifiers: identifiers)
        productFetchOperation.queue() { [weak self] _ in
            
            guard let products = productFetchOperation.products else {
                self?.delegate?.setIsLoading(false, title: nil)
                self?.originViewController?.showSubscriptionAlert(for: productFetchOperation.error)
                return
            }
            
            self?.showSubscriptionSelectionForProducts(products)
        }
    }
    
    private func showSubscriptionSelectionForProducts(products: [VProduct]) {
        guard let originViewController = originViewController else {
            return
        }
        
        let selectSubscription = VIPSelectSubscriptionOperation(products: products, originViewController: originViewController)
        if selectSubscription.willShowPrompt {
            delegate?.setIsLoading(false, title: nil)
        }
        selectSubscription.queue() { [weak self] _ in
            guard let selectedProduct = selectSubscription.selectedProduct else {
                self?.delegate?.setIsLoading(false, title: nil)
                if let error = selectSubscription.error {
                    originViewController.showSubscriptionAlert(for: error)
                }
                return
            }
            self?.delegate?.setIsLoading(true, title: nil)
            self?.subscribeToProduct(selectedProduct)
        }
    }
    
    private func subscribeToProduct(product: VProduct) {
        let subscribe = VIPSubscribeOperation(product: product)
        subscribe.queue() { [weak self] error, canceled in
            self?.delegate?.setIsLoading(false, title: nil)
            guard let strongSelf = self where !canceled else {
                return
            }
            
            if let error = error {
                strongSelf.originViewController?.showSubscriptionAlert(for: error)
            }
            else {
                strongSelf.delegate?.VIPSubscriptionHelperCompletedSubscription(strongSelf)
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
