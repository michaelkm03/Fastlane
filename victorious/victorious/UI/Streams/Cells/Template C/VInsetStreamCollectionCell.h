//
//  VInsetStreamCollectionCell.h
//  victorious
//
//  Created by Josh Hinman on 3/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"
#import "VHasManagedDependencies.h"
#import "VBackgroundContainer.h"
#import "VStreamCellSpecialization.h"
#import "VFocusable.h"
#import "VStreamCellTracking.h"
#import "VHighlightContainer.h"

@class VSequence, VSequencePreviewView;

/**
 *  VInsetStreamCollectionCell a.k.a. Template C Cell.
 */
@interface VInsetStreamCollectionCell : VBaseCollectionViewCell  <VHasManagedDependencies, VBackgroundContainer, VStreamCellComponentSpecialization, VFocusable, VStreamCellTracking, VHighlighting>

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
