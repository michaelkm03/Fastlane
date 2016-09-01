//
//  CollectionLoadingView.swift
//  victorious
//
//  Created by Jarod Long on 8/31/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

final class CollectionLoadingView: UICollectionReusableView {
    
    // MARK: - Constants
    
    private struct Constants {
        static let preferredHeight = CGFloat(70.0)
    }
    
    // MARK: - Initializing
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        addSubview(activityIndicatorView)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.centerXAnchor.constraintEqualToAnchor(centerXAnchor).active = true
        activityIndicatorView.centerYAnchor.constraintEqualToAnchor(centerYAnchor).active = true
        activityIndicatorView.startAnimating()
    }
    
    // MARK: - Views
    
    private let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    
    // MARK: - Configuration
    
    var color: UIColor? {
        get {
            return activityIndicatorView.color
        }
        set {
            activityIndicatorView.color = newValue
        }
    }
    
    var isLoading: Bool {
        get {
            return activityIndicatorView.isAnimating()
        }
        set {
            if newValue {
                activityIndicatorView.startAnimating()
            }
            else {
                activityIndicatorView.stopAnimating()
            }
        }
    }
    
    // MARK: - Registering
    
    static func register(in collectionView: UICollectionView, forSupplementaryViewKind kind: String) {
        collectionView.registerClass(self, forSupplementaryViewOfKind: kind, withReuseIdentifier: defaultReuseIdentifier)
    }
    
    // MARK: - Dequeueing
    
    static func dequeue(from collectionView: UICollectionView, forSupplementaryViewKind kind: String, at indexPath: NSIndexPath) -> CollectionLoadingView {
        return collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: defaultReuseIdentifier, forIndexPath: indexPath) as! CollectionLoadingView
    }
    
    // MARK: - Sizing
    
    static func preferredSize(in bounds: CGRect) -> CGSize {
        return CGSize(width: bounds.width, height: Constants.preferredHeight)
    }
}
