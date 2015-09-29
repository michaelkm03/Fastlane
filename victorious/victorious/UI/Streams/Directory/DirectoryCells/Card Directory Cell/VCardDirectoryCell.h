//
//  VCardDirectoryCell.h
//  victorious
//
//  Created by Will Long on 9/11/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"
#import "VStreamCellSpecialization.h"

extern const CGFloat VDirectoryItemBaseHeight;
extern const CGFloat VDirectoryItemStackHeight;
extern const CGFloat VDirectoryItemBaseWidth;

@class VStreamItem, VDependencyManager;

/**
 A cell for the VDirectoryCollectionViewController.
 */
@interface VCardDirectoryCell : VBaseCollectionViewCell <VStreamCellComponentSpecialization>

/**
 The desired height for a directory item cell that has space for a stack-style extension at the bottom.
 */
+ (CGFloat)desiredStreamOfStreamsHeightForWidth:(CGFloat)width;

/**
 The desired height for a directory item cell that is just a stream of content.
 */
+ (CGFloat)desiredStreamOfContentHeightForWidth:(CGFloat)width;

/**
 Returns whether or not a stack background is expected to display behind a stream item
 
 @param streamItem The stream item that could cause a stack to display on the cell
 
 @return YES when a stack is expected to be shown for the provided streamItem, NO otherwise
 */
+ (BOOL)wantsToShowStackedBackgroundForStreamItem:(VStreamItem *)streamItem;

/**
 Setting to YES will cause the video play icon to display on top of the content
 */
@property (nonatomic, assign) BOOL showVideo;

/**
 Setting to YES will cause the stacked background to show 
 */
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

/**
 The stream item that will be represented by this cell.
 */
@property (nonatomic, strong) VStreamItem *streamItem;

/**
 The dependency manager used to style this cell
 */
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end
