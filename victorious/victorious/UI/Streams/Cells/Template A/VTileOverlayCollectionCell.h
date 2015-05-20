//
//  VTileOverlayCollectionCell.h
//  victorious
//
//  Created by Michael Sena on 5/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"
#import "VHasManagedDependencies.h"
#import "VBackgroundContainer.h"
#import "VStreamCellSpecialization.h"
#import "VStreamCellFocus.h"

@class VSequence;

/**
 *  VTileOverlayCollectionCell a.k.a. Template A cell.
 */
@interface VTileOverlayCollectionCell : VBaseCollectionViewCell <VHasManagedDependencies, VBackgroundContainer, VStreamCellComponentSpecialization, VStreamCellFocus>

/**
 *  Sizing method. All parameters are required.
 */
+ (CGSize)actualSizeWithCollectionViewBounds:(CGRect)bounds
                                    sequence:(VSequence *)sequence
                           dependencyManager:(VDependencyManager *)dependencyManager;

/**
 *  The sequence for this VTileOverlayCollectionCell to represent.
 */
@property (nonatomic, strong) VSequence *sequence;

@end
