//
//  VDependencyManager+SearchBar.swift
//  victorious
//
//  Created by Patrick Lynch on 1/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension VDependencyManager {
    
    var userHashtagSearchKey: String { return "userHashtagSearch" }
    var searchIconImageName: String { return "D_search_small_icon" }
    var searchClearImageName: String { return "search_clear_icon" }
    
    func configureSearchBar(searchBar: UISearchBar) {
        
        searchBar.showsCancelButton = true
        searchBar.tintColor = self.colorForKey(VDependencyManagerSecondaryTextColorKey)
        searchBar.v_textField?.tintColor = self.colorForKey(VDependencyManagerLinkColorKey)
        searchBar.v_textField?.font = self.fontForKey(VDependencyManagerLabel3FontKey)
        searchBar.v_textField?.textColor = self.colorForKey(VDependencyManagerSecondaryTextColorKey)
        searchBar.v_textField?.backgroundColor = self.colorForKey(VDependencyManagerSecondaryAccentColorKey)
        searchBar.v_textField?.attributedPlaceholder = NSAttributedString(
            string: NSLocalizedString("Start a new conversation", comment: ""),
            attributes: [NSForegroundColorAttributeName: self.colorForKey(VDependencyManagerPlaceholderTextColorKey)]
        )
        
        // Made 2 UIImage instances with the same image asset because we cannot
        // set the same instance for .Highlight and .Normal
        guard var searchIconImage = UIImage(named: searchIconImageName),
            var searchClearImageHighlighted = UIImage(named: searchClearImageName),
            var searchClearImageNormal = UIImage(named: searchClearImageName) else {
                return
        }
        
        searchIconImage = searchIconImage.v_tintedTemplateImageWithColor(self.colorForKey(VDependencyManagerPlaceholderTextColorKey))
        searchBar.setImage(searchIconImage, forSearchBarIcon: .Search, state: .Normal)
        
        searchClearImageHighlighted = searchClearImageHighlighted.v_tintedTemplateImageWithColor(self.colorForKey(VDependencyManagerPlaceholderTextColorKey).colorWithAlphaComponent(0.5))
        searchBar.setImage(searchClearImageHighlighted, forSearchBarIcon: .Clear, state: .Highlighted)
        
        searchClearImageNormal = searchClearImageNormal.v_tintedTemplateImageWithColor(self.colorForKey(VDependencyManagerPlaceholderTextColorKey))
        searchBar.setImage(searchClearImageNormal, forSearchBarIcon: .Clear, state: .Normal)
    }
}
