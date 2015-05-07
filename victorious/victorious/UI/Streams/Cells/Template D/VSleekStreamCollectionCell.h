//
//  VSleekStreamCollectionCell.h
//  victorious
//
//  Created by Sharif Ahmed on 3/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VStreamCollectionCell.h"
#import "VHasManagedDependencies.h"

@class VSequence;

/**
 * VSleekStreamCollectionCell is a stream cell component more commonly known as 
 *  template D or Hera. It represents a sequence.
 */
@interface VSleekStreamCollectionCell : VBaseCollectionViewCell <VHasManagedDependencies>

/**
 *  Sizing method. All parameters are required.
 */
+ (CGSize)actualSizeWithCollectionViewBounds:(CGRect)bounds
                                    sequence:(VSequence *)sequence
                           dependencyManager:(VDependencyManager *)dependencyManager;

/**
 *  The sequence for this VSleekStreamCollectionCell to represent.
 */
@property (nonatomic, strong) VSequence *sequence;

@end
