//
//  FilterNameLocalization.swift
//  victorious
//
//  Created by Josh Hinman on 4/21/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

class FilterNameLocalization: NSObject {
    
    private enum FilterNames: String {
        case barcelona = "Barcelona"
        case london = "London"
        case paris = "Paris"
        case oslo = "Oslo"
        case rio = "Rio"
        case sydney = "Sydney"
        case tokyo = "Tokyo"
        case rome = "Rome"
        case newYork = "New York"
        case la = "LA"
        case athens = "Athens"
        case moritz = "St. Moritz"
        case helsinki = "Helsinki"
        case seoul = "Seoul"
        case montreal = "Montreal"
    }
    
    func localizedString(forFilterName filterName: String) -> String {
        
        if let filterNameEnum = FilterNames(rawValue: filterName) {
            // This seemingly unnecessarily verbose code is here because genstrings requires only literal arguments to NSLocalizedString
            switch filterNameEnum {
                case .barcelona:
                    return NSLocalizedString("Barcelona", comment: "")
                case .london:
                    return NSLocalizedString("London", comment: "")
                case .paris:
                    return NSLocalizedString("Paris", comment: "")
                case .oslo:
                    return NSLocalizedString("Oslo", comment: "")
                case .rio:
                    return NSLocalizedString("Rio", comment: "")
                case .sydney:
                    return NSLocalizedString("Sydney", comment: "")
                case .tokyo:
                    return NSLocalizedString("Tokyo", comment: "")
                case .rome:
                    return NSLocalizedString("Rome", comment: "")
                case .newYork:
                    return NSLocalizedString("New York", comment: "")
                case .la:
                    return NSLocalizedString("LA", comment: "")
                case .athens:
                    return NSLocalizedString("Athens", comment: "")
                case .moritz:
                    return NSLocalizedString("St. Moritz", comment: "")
                case .helsinki:
                    return NSLocalizedString("Helsinki", comment: "")
                case .seoul:
                    return NSLocalizedString("Seoul", comment: "")
                case .montreal:
                    return NSLocalizedString("Montreal", comment: "")
            }
        } else {
            return "(Unnamed Filter)"
        }
    }
}
