//
//  VPublishShareCollectionViewCell.h
//  victorious
//
//  Created by Sharif Ahmed on 6/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"

@class VShareItemCollectionViewCell, VDependencyManager;

@protocol VPublishShareCollectionViewCellDelegate <NSObject>

- (void)shareCollectionViewSelectedShareItemCell:(VShareItemCollectionViewCell *)shareItemCell;

@end

@interface VPublishShareCollectionViewCell : VBaseCollectionViewCell

+ (CGSize)desiredSizeForCollectionWithBounds:(CGRect)bounds sectionInsets:(UIEdgeInsets)insets andDependencyManager:(VDependencyManager *)dependencyManager;
- (void)setHorizontalInset:(CGFloat)horizontalInset;

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, weak) id <VPublishShareCollectionViewCellDelegate> delegate;
@property (nonatomic, readonly) NSIndexSet *selectedShareTypes;

@end
