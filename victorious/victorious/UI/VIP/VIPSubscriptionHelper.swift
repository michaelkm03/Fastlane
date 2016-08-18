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
    static let userVIPStatusChangedNotificationKey = "victorious.VIPSubscriptionHelper.userVIPStatusChangedNotificationKey"
    
    init(subscriptionFetchURL: String, delegate: VIPSubscriptionHelperDelegate, originViewController: UIViewController) {
        self.subscriptionFetchURL = subscriptionFetchURL
        self.delegate = delegate
        self.originViewController = originViewController
    }
    
    func subscribe() {
        guard let subscriptionFetchOperation = VIPFetchSubscriptionRemoteOperation(urlString: subscriptionFetchURL) else {
            originViewController?.showSubscriptionAlert(for: VIPFetchSubscriptionRemoteOperation.initError)
            return
        }
        
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
        selectSubscription.queue() { [weak self] result in
            switch result {
                case .success(let selectedProduct):
                    self?.delegate?.setIsLoading(true, title: nil)
                    self?.subscribeToProduct(selectedProduct)
                case .failure(let error):
                    self?.delegate?.setIsLoading(false, title: nil)
                    originViewController.showSubscriptionAlert(for: error as NSError)
                case .cancelled:
                    self?.delegate?.setIsLoading(false, title: nil)
            }
        }
    }
    
    private func subscribeToProduct(product: VProduct) {
        let subscribe = VIPSubscribeOperation(product: product)
        subscribe.queue() { [weak self] result in
            self?.delegate?.setIsLoading(false, title: nil)
            
            guard let strongSelf = self  else {
                return
            }
            
            switch result {
                case .success:
                    strongSelf.delegate?.VIPSubscriptionHelperCompletedSubscription(strongSelf)
                    NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: VIPSubscriptionHelper.userVIPStatusChangedNotificationKey, object: nil))
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
