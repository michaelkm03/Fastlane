//
//  VListShelfCollectionViewFlowLayout.swift
//  victorious
//
//  Created by Sharif Ahmed on 8/15/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

/// A simple collection flow layout that creates a grid of cells such that the left-most
/// cell is twice the size (+ the space between cells) by comparison to the other cells.
class VListShelfCollectionViewFlowLayout: UICollectionViewFlowLayout {
   
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        scrollDirection = UICollectionViewScrollDirection.Horizontal
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElementsInRect(rect) else {
            return nil
        }
        
        if let firstCellAttributes = attributes.first?.copy() as? UICollectionViewLayoutAttributes {
            var updatedAttributes = attributes
            firstCellAttributes.frame.origin.y = 0
            updatedAttributes[0] = firstCellAttributes
            return updatedAttributes
        }
        return attributes
    }
    
}
