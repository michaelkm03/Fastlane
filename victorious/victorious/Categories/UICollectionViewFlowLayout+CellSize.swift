//
//  UICollectionViewFlowLayout+CellSize.swift
//  victorious
//
//  Created by Jarod Long on 4/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

extension UICollectionViewFlowLayout {
    /// Returns the optimal size of a square cell that fits into a collection view with this layout that has the given
    /// width and number of cells per row.
    func v_cellSize(fittingWidth containerWidth: CGFloat, cellsPerRow: Int) -> CGSize {
        let outerSpacing = sectionInset.left + sectionInset.right
        let innerSpacing = minimumInteritemSpacing * CGFloat(cellsPerRow - 1)
        let length       = floor((containerWidth - outerSpacing - innerSpacing) / CGFloat(cellsPerRow))
        return CGSize(width: length, height: length)
    }
}
