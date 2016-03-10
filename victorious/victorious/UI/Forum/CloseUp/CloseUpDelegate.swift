//
//  CloseUpDelegate.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Conformers will recieve messages related to interaction with close up buttons.
protocol CloseUpDelegate: class {
    
    func closeUpPressedDismiss(closeUp: CloseUp)
    
    func closeUp(closeUp: CloseUp, selectedOverflowMenuItem: CloseUpMenuItem)
}
