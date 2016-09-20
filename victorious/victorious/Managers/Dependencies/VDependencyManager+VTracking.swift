//
//  VDependencyManager+Tracking.swift
//  victorious
//
//  Created by Jarod Long on 9/20/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

private var associatedObjectViewWasHiddenKey = "viewWasHidden"

extension VDependencyManager {
    
    // MARK: - Keys
    
    // TODO: Migrate from objc
    
    // MARK: - API paths
    
    /// The default key to use for tracking components in the template.
    static var defaultTrackingKey: String {
        return "tracking"
    }
    
    /// Returns a list of tracking API paths for the given keys, or nil if the paths cannot be found.
    ///
    /// The `trackingKey` is the key for the object that contains entries for each tracking event, which should be an
    /// immediate descendent of `self`. The `eventKey` is the key that should be used inside the tracking object for
    /// the specific event that you're looking for.
    ///
    /// For example, if the structure of `self` looks like this:
    ///
    /// ```
    /// {
    ///     "tracking": {
    ///         "view": ["http://some-tracking-url.com"]
    ///     }
    /// }
    /// ```
    ///
    /// Then `trackingKey` would be "tracking" and `eventKey` would be "view".
    ///
    func trackingAPIPaths(forEventKey eventKey: String, trackingKey: String = VDependencyManager.defaultTrackingKey) -> [APIPath]? {
        guard let tracking = templateValueOfType(NSDictionary.self, forKey: trackingKey) as? [String: AnyObject] else {
            return nil
        }
        
        guard let urlStrings = tracking[eventKey] as? [String] else {
            return nil
        }
        
        return urlStrings.map { APIPath(templatePath: $0) }
    }
    
    // MARK: - View lifecycle
    
    func trackViewWillAppear(for viewController: UIViewController, parameters: [String: AnyObject] = [:]) {
        let wasHidden = (objc_getAssociatedObject(viewController, &associatedObjectViewWasHiddenKey) as? NSNumber)?.boolValue == true
        
        guard !wasHidden else {
            return
        }
        
        guard let apiPaths = trackingAPIPaths(forEventKey: "view") where apiPaths.count > 0 else {
            return
        }
        
        var parameters = parameters
        parameters[VTrackingKeyUrls] = apiPaths.map { $0.templatePath }
        VTrackingManager.sharedInstance().trackEvent(VTrackingEventComponentDidBecomeVisible, parameters: parameters)
        
        objc_setAssociatedObject(viewController, &associatedObjectViewWasHiddenKey, NSNumber(bool: true), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    func trackViewWillDisappear(for viewController: UIViewController) {
        let navigationStack = viewController.navigationController?.viewControllers ?? []
        
        let navigationStackAfterViewController = navigationStack.indexOf(viewController).flatMap {
            Array(navigationStack[$0 ..< navigationStack.count])
        } ?? []
        
        let wasHidden = navigationStackAfterViewController.count > 1 || viewController.presentedViewController != nil
        objc_setAssociatedObject(viewController, &associatedObjectViewWasHiddenKey, NSNumber(bool: wasHidden), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    // MARK: - Objective-C compatibility
    
    func trackingURLsForKey(key: String) -> [String] {
        return trackingAPIPaths(forEventKey: key)?.flatMap { $0.url?.absoluteString } ?? []
    }
    
    func trackViewWillAppear(viewController: UIViewController) {
        trackViewWillAppear(for: viewController)
    }
    
    func trackViewWillDisappear(viewController: UIViewController) {
        trackViewWillDisappear(for: viewController)
    }
}
