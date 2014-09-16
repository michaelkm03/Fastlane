//
//  VContentViewViewModel.h
//  victorious
//
//  Created by Michael Sena on 9/15/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSequence.h"

/**
 *  Posted whenever new comments are made available for a given sequence. This can be initial/update/pagination.
 */
UIKIT_EXTERN NSString * const VContentViewViewModelDidUpdateCommentsNotification;

/**
 *  An enumeration of the various content types supported by VContentViewModel.
 */
typedef NS_ENUM(NSInteger, VContentViewType)
{
    /**
     *  Invalid content type,
     */
    VContentViewTypeInvalid,
    /**
     *  Image content type.
     */
    VContentViewTypeImage,
    /**
     *  Video content type.
     */
    VContentViewTypeVideo,
    /**
     *  Poll content type.
     */
    VContentViewTypePoll
};

@interface VContentViewViewModel : NSObject

/**
 *  The designated initializer for VContentViewViewModel. Will interrogate the sequence object for content type and prepare for a contentView to be displayed.
 *
 *  @param sequence The sequence that this viewModel corresponds to.
 *
 *  @return An initialized VContentViewModel.
 */
- (instancetype)initWithSequence:(VSequence *)sequence;

/**
 *  The corresponding sequence for this view model.
 */
@property (nonatomic, strong, readonly) VSequence *sequence;

/**
 *  The type of asset we are currently viewing.
 */
@property (nonatomic, assign, readonly) VContentViewType type;

/**
 *  For content type image this will be a convenient url request for setting the image.
 */
@property (nonatomic, readonly) NSURLRequest *imageURLRequest;

/**
 *  For content type video this will be a convenient url for the videoplayer.
 */
@property (nonatomic, readonly) NSURL *videoURL;

/**
 *  If a video content has any real time comments this will be YES.
 */
@property (nonatomic, readonly) BOOL shouldShowRealTimeComents;

/**
 *  The number of comments on this particular sequence.
 */
@property (nonatomic, readonly) NSInteger commentCount;

/**
 *  Returns the corrensponding comment body for the given commentIndex. Might return nil if comment has no body text.
 *
 *  @param commentIndex The index of the comment.
 *
 *  @return The comment body for the corresponding comment.
 */
- (NSString *)commentBodyForCommentIndex:(NSInteger)commentIndex;

/**
 *  Returns the corresponding name for the user who posted the comment at the specified index.
 *
 *  @param commentIndex The index of the comment.
 *
 *  @return The user's name who posted a given comment.
 */
- (NSString *)commenterNameForCommentIndex:(NSInteger)commentIndex;

/**
 *  Returns the avatar URL for the user who posted a given comment. May return nil if no avatar URL exists.
 *
 *  @param commentIndex The index of the comment.
 *
 *  @return The avatar URL for the given user.
 */
- (NSURL *)commenterAvatarULRForCommentIndex:(NSInteger)commentIndex;

/**
 *  Returns a boolean determining if a given comment has any media (such as a photo or video) attached.
 *
 *  @param commentIndex The index of the comment.
 *
 *  @return A determination of the comment's media.
 */
- (BOOL)commentHasMediaForCommentIndex:(NSInteger)commentIndex;

@end
