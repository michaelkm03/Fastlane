//
//  VCardDirectoryCell.h
//  victorious
//
//  Created by Will Long on 9/11/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VBaseCollectionViewCell.h"

extern const CGFloat VDirectoryItemBaseHeight;
extern const CGFloat VDirectoryItemStackHeight;
extern const CGFloat VDirectoryItemBaseWidth;

@class VStreamItem;

/**
 A cell for the VDirectoryCollectionViewController.
 */
@interface VCardDirectoryCell : VBaseCollectionViewCell

/**
 The desired height for a directory item cell that has space for a stack-style extension at the bottom.
 */
+ (CGFloat)desiredStreamOfStreamsHeightForWidth:(CGFloat)width;

/**
 The desired height for a directory item cell that is just a stream of content.
 */
+ (CGFloat)desiredStreamOfContentHeightForWidth:(CGFloat)width;

- (void)setPreviewImagePath:(NSString *)previewImagePath placeholderImage:(UIImage *)placeholderImage;

+ (BOOL)wantsToShowStackedBackgroundForStreamItem:(VStreamItem *)streamItem;

@property (nonatomic, assign) BOOL showVideo;

@property (nonatomic, assign) BOOL showStackedBackground;

/**
 The label that will hold the stream name
 */
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;

/**
 The label that will display the stream's count
 */
@property (nonatomic, weak) IBOutlet UILabel *countLabel;

/**
 The background color of the 1 or more stacked views that can indicate multiple
 subitems in the stream or stream of streams being displayed.
 */
@property (nonatomic, strong) UIColor *stackBackgroundColor;

/**
 The border color of each of the 1 or more stacked views that can indicate
 multiple subitems in the stream or stream of streams being displayed.
 */
@property (nonatomic, strong) UIColor *stackBorderColor;

@end
