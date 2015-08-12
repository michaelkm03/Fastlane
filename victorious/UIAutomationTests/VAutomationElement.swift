//
//  VAutomationElement.swift
//  victorious
//
//  Created by Patrick Lynch on 8/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

protocol VSearchableAutomationElement {
    func v_elementWithAccessbilityIdentifier( identifier: String ) -> VAutomationElement?
    func v_viewWithAccessbilityIdentifier( identifier: String ) -> UIView?
    var children: [AnyObject] { get }
}

extension UIResponder : VSearchableAutomationElement {
    
    var children: [AnyObject] {
        fatalError( "Subclasses must override this" )
    }
    
    func v_elementWithAccessbilityIdentifier( identifier: String ) -> VAutomationElement? {
        println( "Checking \(self.dynamicType)(\(self.accessibilityLabel)) for \(identifier)")
        for obj in self.children {
            if let element = obj as? VAutomationElement {
                if let accessibilityIdentifier = element.v_accessibilityIdentifier
                    where accessibilityIdentifier == identifier {
                            return element
                }
                else if let searchableElement = obj as? VSearchableAutomationElement,
                    let subElement = searchableElement.v_elementWithAccessbilityIdentifier( identifier ) {
                        return subElement
                }
            }
        }
        return nil
    }

    func v_viewWithAccessbilityIdentifier( identifier: String ) -> UIView? {
        return self.v_elementWithAccessbilityIdentifier( identifier ) as? UIView
    }
}

extension UIView : VSearchableAutomationElement {
    
    override var children: [AnyObject] {
        return self.subviews
    }
}

extension UIViewController : VSearchableAutomationElement {
    
    override var children: [AnyObject] {
        let leftItems = self.navigationItem.leftBarButtonItems ?? []
        let rightItems = self.navigationItem.rightBarButtonItems ?? []
        let tabbarItems = (self.navigationController?.viewControllers as? [UIViewController] ?? []).map { $0.tabBarItem } as? [UITabBarItem] ?? []
        return self.view.subviews + leftItems + rightItems + tabbarItems
    }
}

extension UIApplication : VSearchableAutomationElement {
    
    override var children: [AnyObject] {
        return self.windows
    }
}