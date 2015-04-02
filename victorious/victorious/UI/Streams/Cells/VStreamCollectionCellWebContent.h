//
//  VStreamCollectionCellWebContent.h
//  victorious
//
//  Created by Patrick Lynch on 11/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"
#import "VBackgroundContainer.h"

@class VSequence;

@interface VStreamCollectionCellWebContent : VBaseCollectionViewCell <VBackgroundContainer>

@property (nonatomic, strong) VSequence *sequence;

@end
