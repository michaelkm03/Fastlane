//
//  VEStreamCollectionViewCell.h
//  victorious
//
//  Created by Michael Sena on 4/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"

#import "VBackgroundContainer.h"

@class VSequence;

@interface VEStreamCollectionViewCell : VBaseCollectionViewCell <VBackgroundContainer>

@property (nonatomic, strong) VSequence *sequence;

@end
