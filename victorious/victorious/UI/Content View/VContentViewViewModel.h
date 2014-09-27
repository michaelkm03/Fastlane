//
//  VContentViewViewModel.h
//  victorious
//
//  Created by Michael Sena on 9/15/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSequence.h"

#import "VRealtimeCommentsViewModel.h"

/**
 *  Posted whenever new comments are made available for a given sequence.
 */
UIKIT_EXTERN NSString * const VContentViewViewModelDidUpdateCommentsNotification;

/**
 *  An enumeration of the various content types supported by VContentViewModel.
 */
typedef NS_ENUM(NSInteger, VContentViewType)
{
    /**
     *  Invalid content type, use to fail gracefully.
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

/**
 * The VContentViewViewModel is the interface between the UI layer for a given sequenceand the model layer for that same sequence. The ContentViewViewModel provides a convenient API for accesing the important information from model layer while hiding many implementation details from the UI.
 * 
 * The VContentViewViewModel arranges the comments associated with a given sequence into an ordered list sorted by most recent. Use the "___ForCommentIndex:" methods to gain access to this list.
 *
 
NOTE: Currently this VContentViewViewModel only supports single node, single asset sequences.
 */
@interface VContentViewViewModel : NSObject

/**
 *  The designated initializer for VContentViewViewModel. Will interrogate the sequence object for content type and prepare for a contentView to be displayed.
 *
 *  @param sequence The sequence that this viewModel corresponds to.
 *
 *  @return An initialized VContentViewModel.
 */
- (instancetype)initWithSequence:(VSequence *)sequence;

- (void)addCommentWithText:(NSString *)text
                  mediaURL:(NSURL *)mediaURL
                completion:(void (^)(BOOL succeeded))completion;

/**
 *  The corresponding sequence for this view model.
 */
@property (nonatomic, strong, readonly) VSequence *sequence;

/**
 *  The type of asset we are currently viewing.
 */
@property (nonatomic, assign, readonly) VContentViewType type;

/**
 *  A view model for the real time comments for the given sequence.
 */
@property (nonatomic, strong, readonly) VRealtimeCommentsViewModel *realTimeCommentsViewModel;

/**
 *  For content type image this will be a convenient url request for setting the image.
 */
@property (nonatomic, readonly) NSURLRequest *imageURLRequest;

/**
 *  The name of the sequence.
 */
@property (nonatomic, readonly) NSString *name;

@property (nonatomic, strong, readonly) VNode *currentNode;

@property (nonatomic, readonly) BOOL isCurrentUserOwner;

@property (nonatomic, readonly) NSString *remixCountText;
@property (nonatomic, readonly) NSString *repostCountText;
@property (nonatomic, readonly) NSString *shareCountText;

@property (nonatomic, readonly) NSString *authorName;
@property (nonatomic, readonly) NSString *authorCaption;
@property (nonatomic, readonly) NSURL *avatarForAuthor;

@property (nonatomic, readonly) NSString *shareText;
@property (nonatomic, readonly) NSString *analyticsContentTypeText;
@property (nonatomic, readonly) NSURL *shareURL;

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
 *  Fetches the all comments and realtime comments for this viewModel's sequence.
 */
- (void)fetchComments;

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
 *  Returns the text to place in the time ago/ time since label for a given comment view.
 *
 *  @param commentIndex The corresponding index of the comment.
 *
 *  @return The formatted time ago text for the given coment.
 */
- (NSString *)commentTimeAgoTextForCommentIndex:(NSInteger)commentIndex;


/**
 *  Returns the text to place in the real time comment label for a given comment view.
 *
 *  @param commentIndex The corresponding index of the comment.
 *
 *  @return The formatted real time comment text for the given coment.
 */
- (NSString *)commentRealTimeCommentTextForCommentIndex:(NSInteger)commentIndex;

/**
 *  Returns the avatar URL for the user who posted a given comment. May return nil if no avatar URL exists.
 *
 *  @param commentIndex The index of the comment.
 *
 *  @return The avatar URL for the given user.
 */
- (NSURL *)commenterAvatarURLForCommentIndex:(NSInteger)commentIndex;

/**
 *  Returns a boolean determining if a given comment has any media (such as a photo or video) attached.
 *
 *  @param commentIndex The index of the comment.
 *
 *  @return A determination of the comment's media.
 */
- (BOOL)commentHasMediaForCommentIndex:(NSInteger)commentIndex;

/**
 *  Returns a preview image url for the media for a given comment. Raises an exception if comment has no media.
 *
 *  @param commentIndex The index of the comment.
 *
 *  @return The preview image URL.
 */
- (NSURL *)commentMediaPreviewUrlForCommentIndex:(NSInteger)commentIndex;

- (NSURL *)mediaURLForCommentIndex:(NSInteger)commentIndex;

/**
 *  Returns a determination of whetehr or not the media for a given comment is a video or not. Raises an exception if comment has no media.
 *
 *  @param commentIndex The index of the comment.
 *
 *  @return Whether or not the media for the comment is a video.
 */
- (BOOL)commentMediaIsVideoForCommentIndex:(NSInteger)commentIndex;

@end
