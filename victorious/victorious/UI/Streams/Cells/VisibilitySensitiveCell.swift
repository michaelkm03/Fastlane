//
//  VisibilitySensitiveCell.swift
//  victorious
//
//  Created by Sharif Ahmed on 8/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

@objc protocol VisibilitySensitiveCell {
    
    func onDidBecomeVisible();
    
    func onStoppedBeingVisible();
    
}
