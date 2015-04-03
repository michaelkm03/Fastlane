//
//  VBaseMarqueeStreamItemCell.h
//  victorious
//
//  Created by Sharif Ahmed on 3/25/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VSharedCollectionReusableViewMethods.h"

@class VStreamItem, VUser, VAbstractMarqueeStreamItemCell, VDependencyManager;

@interface VAbstractMarqueeStreamItemCell : UICollectionViewCell <VSharedCollectionReusableViewMethods>

@property (nonatomic, strong) VStreamItem *streamItem; ///<Stream item to display
@property (nonatomic, weak) IBOutlet UIImageView *previewImageView;
@property (nonatomic, weak) IBOutlet UIImageView *pollOrImageView;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end
