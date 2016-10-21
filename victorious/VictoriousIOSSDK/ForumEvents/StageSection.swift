//
//  StageSection.swift
//  victorious
//
//  Created by Sebastian Nystorm on 29/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Represents the two different Stages.
public enum StageSection {
    case vip
    case main
    
    init?(section: String) {
        switch section.lowercased() {
            case "vip_stage":
                self = .vip
            case "main_stage":
                self = .main
            default:
                return nil
        }
    }
}
