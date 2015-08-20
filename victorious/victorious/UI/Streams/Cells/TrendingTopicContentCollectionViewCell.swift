//
//  VTrendingTopicContentCollectionViewCell.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 8/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

class TrendingTopicContentCollectionViewCell: VShelfContentCollectionViewCell {
    
    required init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        previewViewContainer.backgroundColor = UIColor.blackColor()
    }
    
}

extension TrendingTopicContentCollectionViewCell: VStreamCellComponentSpecialization {
    
    override class func reuseIdentifierForStreamItem(streamItem: VStreamItem, baseIdentifier: String?, dependencyManager: VDependencyManager?) -> String {
        let updatedIdentifier = self.identifier(baseIdentifier, className: NSStringFromClass(self))
        return super.reuseIdentifierForStreamItem(streamItem, baseIdentifier: updatedIdentifier, dependencyManager: dependencyManager)
    }
}

