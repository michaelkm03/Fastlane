//
//  VContentViewViewModel.h
//  victorious
//
//  Created by Michael Sena on 9/15/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSequence.h"
#import "VAdViewControllerType.h"
#import "VExperienceEnhancerController.h"
#import "VPublishParameters.h"

/**
 *  An enumeration of the various content types supported by VContentViewModel.
 */
typedef NS_ENUM(NSInteger, VContentViewType)
{
    VContentViewTypeInvalid,
    VContentViewTypeImage,
    VContentViewTypeVideo,
    VContentViewTypeGIFVideo,
    VContentViewTypePoll,
    VContentViewTypeText
};

typedef NS_ENUM(NSInteger, VPollAnswer)
{
    VPollAnswerInvalid,
    VPollAnswerA,
    VPollAnswerB,
};

@class ContentViewContext, VLargeNumberFormatter;

@protocol VContentViewViewModelDelegate <NSObject>

- (void)didUpdateSequence;
- (void)didUpdatePoll;
- (void)didUpdateCommentsWithDeepLink:(NSNumber *)commentId;

@end

/**
 The VContentViewViewModel is the interface between the UI layer for a given sequenc eand
 the model layer for that same sequence. The ContentViewViewModel provides a convenient API
 for accesing the important information from model layer while hiding many implementation
 details from the UI.
 */
@interface VContentViewViewModel : NSObject

- (instancetype)initWithContext:(ContentViewContext *)context NS_DESIGNATED_INITIALIZER;

- (CGSize)contentSizeWithinContainerSize:(CGSize)containerSize;

@property (nonatomic, readonly) ContentViewContext *context;
@property (nonatomic, readonly) NSURL *sourceURLForCurrentAssetData;
@property (nonatomic, readonly) NSInteger nodeID;
@property (nonatomic, strong) NSString *followersText;
@property (nonatomic, readonly) VUser *user;
@property (nonatomic, weak) id<VContentViewViewModelDelegate> delegate;

/**
 *  The corresponding sequence for this view model.
 */
@property (nonatomic, strong, readonly) VSequence *sequence;

/**
 *  The id of the stream containing the corresponding sequence for this view model.
 */
@property (nonatomic, strong, readonly) NSString *streamId;

/**
 *  The type of asset we are currently viewing.
 */
@property (nonatomic, assign, readonly) VContentViewType type;

@property (nonatomic, strong, readonly) VExperienceEnhancerController *experienceEnhancerController;

/**
 *  For content type image this will be a convenient url request for setting the image.
 */
@property (nonatomic, readonly) NSURLRequest *imageURLRequest;

@property (nonatomic, readonly) NSString *name; //< The name of the sequence.
@property (nonatomic, readonly) BOOL shouldShowTitle;
@property (nonatomic, strong, readonly) VNode *currentNode;
@property (nonatomic, readonly) BOOL isCurrentUserOwner;
@property (nonatomic, assign) BOOL isLoadingComments;
@property (nonatomic, assign) BOOL hasReposted;
@property (nonatomic, readonly) NSString *memeCountText;
@property (nonatomic, readonly) NSString *repostCountText;
@property (nonatomic, readonly) NSString *shareCountText;
@property (nonatomic, readonly) NSString *authorName;
@property (nonatomic, readonly) NSString *authorCaption;
@property (nonatomic, readonly) NSString *analyticsContentTypeText;
@property (nonatomic, readonly) NSURL *shareURL;
@property (nonatomic, readonly) UIColor *textBackgroundColor;
@property (nonatomic, readonly) NSString *textContent;
@property (nonatomic, readonly) NSURL *textBackgroundImageURL;
@property (nonatomic, readonly) NSInteger totalVotes;
@property (nonatomic, strong, readonly) VLargeNumberFormatter *largeNumberFormatter;
@property (nonatomic, readonly) float speed;
@property (nonatomic, readonly) BOOL loop;
@property (nonatomic, readonly) BOOL playerControlsDisabled; //< Determines whether the video player will show its toolbar with play controls.
@property (nonatomic, readonly) BOOL audioMuted; //< Determines whether the video will play with audio.

@property (nonatomic, readonly) NSString *answerALabelText;
@property (nonatomic, readonly) NSString *answerBLabelText;
@property (nonatomic, readonly) NSURL *answerAThumbnailMediaURL;
@property (nonatomic, readonly) NSURL *answerBThumbnailMediaURL;
@property (nonatomic, readonly) BOOL answerAIsVideo;
@property (nonatomic, readonly) BOOL answerBIsVideo;
@property (nonatomic, readonly) NSURL *answerAVideoUrl;
@property (nonatomic, readonly) NSURL *answerBVideoUrl;
@property (nonatomic, readonly) BOOL votingEnabled;
@property (nonatomic, readonly) CGFloat answerAPercentage;
@property (nonatomic, readonly) CGFloat answerBPercentage;
@property (nonatomic, readonly) NSString *numberOfVotersText;
@property (nonatomic, assign, readonly) VPollAnswer favoredAnswer; //< By the current user.
@property (nonatomic, strong) NSArray *pollResults;

- (NSURL *)avatarForAuthorWithSize:(CGSize)size;

/**
 Set a comment ID using this property after initializtion to scroll to and highlight
 that comment when the content view loads.
 */
@property (nonatomic, strong) NSNumber *deepLinkCommentId;

/**
 Stores tracking data necessary to track events that occur during the receiver's lifecycle.
 To enable tracking, it is required that this property be set by calling code.
 */
@property (nonatomic, strong) VTracking *trackingData;

@end
