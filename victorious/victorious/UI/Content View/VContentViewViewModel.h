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
#import "VHistogramDataSource.h"
#import "VAbstractFilter+RestKit.h"

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
 * Called whenever new histogram data is made available.
 */
- (void)didUpdateHistogramData;

/**
 * Called whenever new poll data is made available.
 */
- (void)didUpdatePollsData;

@end

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

typedef NS_ENUM(NSInteger, VPollAnswer)
{
    VPollAnswerInvalid,
    VPollAnswerA,
    VPollAnswerB,
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
- (instancetype)initWithSequence:(VSequence *)sequence depenencyManager:(VDependencyManager *)dependencyManager;

- (void)reloadData;

- (void)fetchSequenceData;

- (void)addCommentWithText:(NSString *)text
                  mediaURL:(NSURL *)mediaURL
                  realTime:(CMTime)realTime
                completion:(void (^)(BOOL succeeded))completion;

@property (nonatomic, readonly) NSURL *sourceURLForCurrentAssetData;

@property (nonatomic, readonly) NSInteger nodeID;

@property (nonatomic, readonly) VUser *user;

@property (nonatomic, weak) id<VContentViewViewModelDelegate> delegate;

/**
 *  The corresponding sequence for this view model.
 */
@property (nonatomic, strong, readonly) VSequence *sequence;

/**
 *  The type of asset we are currently viewing.
 */
@property (nonatomic, assign, readonly) VContentViewType type;

/**
 *  The type of asset we are currently viewing.
 */
@property (nonatomic, assign, readonly) VMonetizationPartner monetizationPartner;

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

@property (nonatomic, readonly) NSString *remixCountText;

@property (nonatomic, readonly) NSString *repostCountText;

@property (nonatomic, readonly) NSString *shareCountText;

@property (nonatomic, readonly) NSString *authorName;

@property (nonatomic, readonly) NSString *authorCaption;

@property (nonatomic, readonly) NSURL *avatarForAuthor;

@property (nonatomic, readonly) NSString *shareText;

@property (nonatomic, readonly) NSString *analyticsContentTypeText;

@property (nonatomic, readonly) NSURL *shareURL;

#pragma mark - Videos

@property (nonatomic, readonly) VVideoCellViewModel *videoViewModel;

@property (nonatomic, readonly) float speed;

@property (nonatomic, readonly) BOOL loop;

/**
 Determines whether the video player will show its toolbar with play controls.
 */
@property (nonatomic, readonly) BOOL playerControlsDisabled;

/**
 Determines whether the video will play with audio.
 */
@property (nonatomic, readonly) BOOL audioMuted;

#pragma mark - Comments

/**
 *  If a video content has any real time comments this will be YES.
 */
@property (nonatomic, readonly) BOOL shouldShowRealTimeComents;

/**
 *  Fetches comments and realtime comments for this viewModel's sequence.
 *  @param pageType An indicator to the internal VAbstractFilter instances that
 *  determines which page of comments to load, if that page exists.
 */
- (void)loadComments:(VPageType)pageType;

@property (nonatomic, readonly) NSArray *comments;

- (void)removeCommentAtIndex:(NSUInteger)index;

#pragma mark - Actions

- (void)repost;

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

- (VPollAnswer)favoredAnswer; // By the current user.

- (void)answerPollWithAnswer:(VPollAnswer)selectedAnswer
                  completion:(void (^)(BOOL succeeded, NSError *error))completion;

#pragma mark - Histogram

/** This will be nil if no histogram data is available.
 */
@property (nonatomic, strong, readonly) VHistogramDataSource *histogramDataSource;

/**
 Set a comment ID using this property after initializtion to scroll to and highlight
 that comment when the content view loads.
 */
@property (nonatomic, strong) NSNumber *deepLinkCommentId;

@end
