//
//  ListMenuSectionCell.swift
//  victorious
//
//  Created by Tian Lan on 4/19/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Conformers to this protocol are the custom collection view cells which show up in a list menu component
protocol ListMenuSectionCell: class {
    /// Data to pass in to the cell for configuration
    associatedtype CellData
    
    /// Preferred height of the type of cell according to design spec
    static var preferredHeight: CGFloat { get }
    
    /// The cell's dependency manager
    var dependencyManager: VDependencyManager? { get set }
    
    /// Configure the content of the cell with a CellData
    func configureCell(with _: CellData)
    
    /// Update background color regarding to the cell being selected or not
    func updateCellBackgroundColor(to backgroundContainer: UIView, selectedColor color: UIColor?, isSelected: Bool)
}

extension ListMenuSectionCell {
    
    static var preferredHeight: CGFloat {
        return 38
    }
    
    func updateCellBackgroundColor(to backgroundContainer: UIView, selectedColor color: UIColor?, isSelected: Bool) {
        if isSelected {
            backgroundContainer.backgroundColor = color
        } else {
            backgroundContainer.backgroundColor = nil
        }
    }
}
