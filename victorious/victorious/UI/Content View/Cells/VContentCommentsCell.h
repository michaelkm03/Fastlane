//
//  VContentCommentsCell.h
//  victorious
//
//  Created by Michael Sena on 9/15/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"
#import "VComment.h"

@class VCommentTextAndMediaView;

/**
 *  UICollectionViewCell for representing a general comment on an item.
 */
@interface VContentCommentsCell : VBaseCollectionViewCell

@property (nonatomic, strong) VComment *comment;
@property (nonatomic, readonly) NSURL *mediaURL;

@property (nonatomic, copy) void (^onMediaTapped)();
@property (nonatomic, copy) void (^onUserProfileTapped)();

@property (nonatomic, readonly) UIImage *previewImage;
@property (nonatomic, readonly) UIView *previewView;
@property (nonatomic, readonly) BOOL mediaIsVideo;

@property (weak, nonatomic) IBOutlet VCommentTextAndMediaView *commentAndMediaView;

+ (NSCache *)sharedImageCached;

+ (void)clearSharedImageCache;

/**
 *  Sizing method for delegates.
 *
 *  @param width       The full width that will be provided to the cell. The cell grows vertically so only width is needed.
 *  @param commentBody The text of the comment.
 *  @param hasMedia    A boolean if the comment has media or not.
 *
 *  @return The size required to display the cell at full size.
 */
+ (CGSize)sizeWithFullWidth:(CGFloat)width
                commentBody:(NSString *)commentBody
                andHasMedia:(BOOL)hasMedia;

@end
