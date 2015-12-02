//
//  VContentViewViewModel.h
//  victorious
//
//  Created by Michael Sena on 9/15/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSequence.h"
#import "VRealtimeCommentsViewModel.h"
#import "VAdViewController.h"
#import "VExperienceEnhancerController.h"
#import "VAbstractFilter+RestKit.h"
#import "VPublishParameters.h"
#import "VEndCardModel.h"
#import "VMonetizationPartner.h"

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

@class ContentViewContext;

@protocol VContentViewViewModelDelegate <NSObject>

/**
 * Called whenever new comments are updated.
 * @param pageType The pagination context for which the comments fetch occurred.
 */
- (void)didUpdateCommentsWithPageType:(VPageType)pageType;

/**
 * Called when a page of comments is loaded that contains the comment Id,
 * currently designed to work with deep linking.
 */
- (void)didUpdateCommentsWithDeepLink:(NSNumber *)commentId;

/**
 * Called whenever the server returns an updated state of this content.
 */
- (void)didUpdateContent;

/**
 * Called whenever new poll data is made available.
 */
- (void)didUpdatePollsData;

@end

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
- (instancetype)initWithContext:(ContentViewContext *)context;

- (void)loadNextSequenceSuccess:(void(^)(VSequence *))success failure:(void(^)(NSError *))failure;

- (void)addCommentWidhText:(NSString *)text
         publishParameters:(VPublishParameters *)publishParameters
                completion:(void (^)(BOOL succeeded))completion;

- (void)addCommentWithText:(NSString *)text
         publishParameters:(VPublishParameters *)publishParameters
               currentTime:(Float64)currentTime
                completion:(void (^)(BOOL succeeded))completion;

- (void)updateEndcard;

- (void)setupAdChain;

@property (nonatomic, readonly) ContentViewContext *context;

@property (nonatomic, readonly) NSURL *sourceURLForCurrentAssetData;

@property (nonatomic, readonly) NSInteger nodeID;

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

/**
 *  A view model for the real time comments for the given sequence.
 */
@property (nonatomic, strong, readonly) VRealtimeCommentsViewModel *realTimeCommentsViewModel;

@property (nonatomic, strong, readonly) VExperienceEnhancerController *experienceEnhancerController;

#pragma mark - Interface Properties

/**
 *  For content type image this will be a convenient url request for setting the image.
 */
@property (nonatomic, readonly) NSURLRequest *imageURLRequest;

/**
 *  The name of the sequence.
 */
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) BOOL shouldShowTitle;
@property (nonatomic, strong, readonly) VNode *currentNode;
@property (nonatomic, readonly) BOOL isCurrentUserOwner;
@property (nonatomic, assign) BOOL hasReposted;
@property (nonatomic, readonly) NSString *memeCountText;
@property (nonatomic, readonly) NSString *gifCountText;
@property (nonatomic, readonly) NSString *repostCountText;
@property (nonatomic, readonly) NSString *shareCountText;
@property (nonatomic, readonly) NSString *authorName;
@property (nonatomic, readonly) NSString *authorCaption;
@property (nonatomic, readonly) NSURL *avatarForAuthor;
@property (nonatomic, readonly) NSString *analyticsContentTypeText;
@property (nonatomic, readonly) NSURL *shareURL;
@property (nonatomic, readonly) UIColor *textBackgroundColor;
@property (nonatomic, readonly) NSString *textContent;
@property (nonatomic, readonly) NSURL *textBackgroundImageURL;
@property (nonatomic, readonly) NSInteger totalVotes;

@property (nonatomic, assign, readonly) VMonetizationPartner monetizationPartner;
@property (nonatomic, assign, readonly) NSArray *monetizationDetails;

#pragma mark - Videos

/**
 All the data necessary to display and populate the end card
 after a video has finished playing.  If this is `nil`, then there is
 no end card for this video and it should not be displayed.
 */
@property (nonatomic, strong, readwrite) VEndCardModel *endCardViewModel;

@property (nonatomic, readonly) float speed;
@property (nonatomic, readonly) BOOL loop;
@property (nonatomic, readonly) BOOL playerControlsDisabled; //< Determines whether the video player will show its toolbar with play controls.
@property (nonatomic, readonly) BOOL audioMuted; //< Determines whether the video will play with audio.

#pragma mark - Comments

@property (nonatomic, readonly) NSArray *comments;

/**
 *  Fetches comments and realtime comments for this viewModel's sequence.
 *  @param pageType An indicator to the internal VAbstractFilter instances that
 *  determines which page of comments to load, if that page exists.
 */
- (void)loadComments:(VPageType)pageType;

- (void)removeCommentAtIndex:(NSUInteger)index;

#pragma mark - Actions

- (void)repost;

- (CGSize)contentSizeWithinContainerSize:(CGSize)containerSize;

#pragma mark - Polls

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

- (void)answerPollWithAnswer:(VPollAnswer)selectedAnswer
                  completion:(void (^)(BOOL succeeded, NSError *error))completion;
/**
 Set a comment ID using this property after initializtion to scroll to and highlight
 that comment when the content view loads.
 */
@property (nonatomic, strong) NSNumber *deepLinkCommentId;

@end
