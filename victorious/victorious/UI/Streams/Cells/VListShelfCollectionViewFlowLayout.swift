//
//  VListShelfCollectionViewFlowLayout.swift
//  victorious
//
//  Created by Sharif Ahmed on 8/15/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

class VListShelfCollectionViewFlowLayout: UICollectionViewFlowLayout {
   
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        scrollDirection = UICollectionViewScrollDirection.Horizontal
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
        if let attributes = super.layoutAttributesForElementsInRect(rect) as? [UICollectionViewLayoutAttributes]
        {
            attributes.first?.frame.origin.y = 0
            return attributes
        }
        return nil
    }
    
}
