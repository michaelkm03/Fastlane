//
//  CustomInputAreaState.swift
//  victorious
//
//  Created by Sharif Ahmed on 9/20/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

// Describes the currently display state of an input area
enum CustomInputAreaState {
    case Hidden
    case Visible(inputController: CustomInputDisplayOptions)
    
    var visibleInputController: CustomInputDisplayOptions? {
        switch self {
            case .Visible(let inputController):
                return inputController
            default:
                return nil
        }
    }
}

func ==(lhs: CustomInputAreaState, rhs: CustomInputAreaState) -> Bool {
    return lhs.visibleInputController == rhs.visibleInputController
}
