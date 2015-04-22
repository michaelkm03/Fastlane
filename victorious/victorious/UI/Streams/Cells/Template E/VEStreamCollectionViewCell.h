//
//  VEStreamCollectionViewCell.h
//  victorious
//
//  Created by Michael Sena on 4/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAbstractStreamCollectionCell.h"

// Protocols
#import "VBackgroundContainer.h"
#import "VHasManagedDependencies.h"

@class VSequence;

@interface VEStreamCollectionViewCell : VAbstractStreamCollectionCell <VBackgroundContainer, VHasManagedDependencies>

@property (nonatomic, strong) VSequence *sequence;

@end
