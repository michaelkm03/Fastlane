//
//  ListMenuSectionCell.swift
//  victorious
//
//  Created by Tian Lan on 4/19/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Conformers to this protocol are the custom collection view cells which show up in a list menu component
protocol ListMenuSectionCell {
    
    /// Preferred height of the type of cell according to design spec
    static var preferredHeight: CGFloat { get }
}
