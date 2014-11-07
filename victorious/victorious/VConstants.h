//
//  VConstants.h
//  victorious
//
//  Created by David Keegan on 1/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import CoreGraphics;

typedef NS_ENUM(NSUInteger, VLoopType)
{
    VLoopOnce       =   0,
    VLoopRepeat     =   1,
    VLoopReverse    =   2
};

typedef NS_ENUM(NSUInteger, VPlaybackSpeed)
{
    VPlaybackNormalSpeed   =   0,
    VPlaybackHalfSpeed     =   1,
    VPlaybackDoubleSpeed   =   2
};

typedef NS_ENUM(NSUInteger, VCaptionType)
{
    VCaptionTypeNormal = 0,
    VCaptionTypeMeme,
    VCaptionTypeQuote
};

#pragma mark - UI constants

#define UI_IS_IOS8_AND_HIGHER   ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)

static NSUInteger const VConstantsMessageLength         = 140;
static NSUInteger const VConstantsUsernameMaxLength     = 50;
static NSUInteger const VConstantsPollAnswerLength      = 25;
static CGFloat    const VConstantsInputAccessoryHeight  = 44.0f;

static CGFloat const kStreamDoublePollCellHeight = 214.0f;
static CGFloat const kStreamViewCellHeight       = 320.0f;

#pragma mark - Error Codes

static NSString * const kVictoriousErrorDomain          = @"com.getvictorious.victoriOS";

static NSUInteger const kVStillTranscodingError         = 5500;
static NSUInteger const kVConversationDoesNotExistError = 5000;

static NSUInteger const kVPasswordResetCodeExpired = 6700;

static NSUInteger const kVFollowsRelationshipDoesNotExistError = 5001;
static NSUInteger const kVFollowsRelationshipAlreadyExistsError = 6001;

static NSUInteger const kVAccountAlreadyExistsError     = 1003;
static NSUInteger const kVUserBannedError               = 1007;

static NSUInteger const kVMediaAlreadyCreatedError      = 1005;

static NSUInteger const kVUpgradeRequiredError          = 426;
static NSUInteger const kVUnauthoizedError              = 401;

#pragma mark - App ID keys

static NSUInteger  const   kDevAppID                = 1;

static NSString * const   kVictoriousAppIDKey      = @"VictoriousAppID";
static NSString * const   kStagingAppIDKey         = @"StagingAppID";
static NSString * const   kQAAppIDKey              = @"QAAppID";

static NSString * const   kTestflightQAToken       = @"TestflightQAAppToken";
static NSString * const   kTestflightStagingToken  = @"TestflightStagingAppToken";
static NSString * const   kTestflightReleaseToken  = @"TestflightReleaseAppToken";

static NSString * const   kGAID                    = @"GAID";

#pragma mark - API Payload keys

static NSString * const   kVUserAgentHeader    = @"User-Agent";
static NSString * const   kVPayloadKey         = @"payload";
static NSString * const   kVErrorKey           = @"error";
static NSString * const   kRemoteIdKey         = @"remoteId";

#pragma mark - Media Constants

static NSString * const VConstantsMediaTypeYoutube   = @"youtube_video_id";
static NSString * const VConstantsMediaTypeVideo     = @"video";
static NSString * const VConstantsMediaTypeImage     = @"image";

static NSString * const VConstantMediaExtensionM3U8      = @"m3u8";
static NSString * const VConstantMediaExtensionPNG       = @"png";
static NSString * const VConstantMediaExtensionJPG       = @"jpg";
static NSString * const VConstantMediaExtensionJPEG      = @"jpeg";
static NSString * const VConstantMediaExtensionMOV       = @"mov";
static NSString * const VConstantMediaExtensionMP4       = @"mp4";

static NSTimeInterval const VConstantsMaximumVideoDuration = 15.0;

static const CGFloat VConstantJPEGCompressionQuality    = 0.8f;

#pragma mark - Sequence Categories

//NOTE: If you add categories, add them all to the necessary C functions in this section
static NSString * const   kVOwnerPollCategory          = @"owner_poll";
static NSString * const   kVOwnerImageCategory         = @"owner_image";
static NSString * const   kVOwnerImageRepostCategory   = @"owner_image_repost";
static NSString * const   kVOwnerImageQuoteCategory    = @"owner_image_secret";
static NSString * const   kVOwnerImageMemeCategory     = @"owner_image_meme";
static NSString * const   kVOwnerVideoCategory         = @"owner_video";
static NSString * const   kVOwnerVideoRemixCategory    = @"owner_video_remix";
static NSString * const   kVOwnerVideoRepostCategory   = @"owner_video_repost";
static NSString * const   kVOwnerMemeRepostCategory    = @"owner_meme_repost";
static NSString * const   kVOwnerQuoteRepostCategory   = @"owner_secret_repost";
static NSString * const   kVOwnerAnnouncementCategory  = @"owner_announcement";

static NSString * const   kVUGCPollCategory            = @"ugc_poll";
static NSString * const   kVUGCImageCategory           = @"ugc_image";
static NSString * const   kVUGCImageRepostCategory     = @"ugc_image_repost";
static NSString * const   kVUGCImageQuoteCategory      = @"ugc_image_secret";
static NSString * const   kVUGCImageMemeCategory       = @"ugc_image_meme";
static NSString * const   kVUGCVideoCategory           = @"ugc_video";
static NSString * const   kVUGCVideoRemixCategory      = @"ugc_video_remix";
static NSString * const   kVUGCVideoRepostCategory     = @"ugc_video_repost";
static NSString * const   kVUGCMemeRepostCategory      = @"ugc_meme_repost";
static NSString * const   kVUGCQuoteRepostCategory     = @"ugc_secret_repost";

NSArray *VOwnerCategories();
NSArray *VUGCCategories();
NSArray *VImageCategories();
NSArray *VVideoCategories();
NSArray *VPollCategories();
NSArray *VRepostCategories();
NSArray *VRemixCategories();

#pragma mark - Sequence data types

static NSString * const   kVSequencePreviewTypeMedia = @"media";
static NSString * const   kVSequencePreviewTypeHTML  = @"html";

static NSString * const   kTemporaryContentStatus = @"temp";

#pragma mark - Status Levels

static NSString * const   kUserStatusComplete = @"complete";
static NSString * const   kUserStatusIncomplete = @"incomplete";
static NSString * const   kNoUserName = @"(none)"; ///< If a user has no username defined, the username field will contain this value

#pragma mark - Access Levels

static NSString * const   kOwnerAccessLevel = @"api_owner";
static NSString * const   kUserAccessLevel = @"api_user";

#pragma mark - Storyboard IDs

static NSString * const   kStreamContainerID                   = @"streamcontainer";
static NSString * const   kModalStreamContainerID              = @"modalstreamcontainer";
static NSString * const   kHashTagStreamStoryboardID           = @"hashtagstream";
static NSString * const   kStreamStoryboardID                  = @"streamtable";


static NSString * const   kInboxContainerID                    = @"inboxcontainer";
static NSString * const   kMessageContainerID                  = @"messagecontainer";
static NSString * const   kEnterResetTokenID                   = @"enterresettoken";

static NSString * const   kContentViewStoryboardID             = @"content";
static NSString * const   kContentInfoStoryboardID             = @"contentInfo";
static NSString * const   kEmotiveBallisticsBarStoryboardID    = @"emotiveballistics";
static NSString * const   kPollAnswerBarStoryboardID           = @"pollanswerbar";

static NSString * const   kHashTagsContainerStoryboardID       = @"hashtagscontainer";
static NSString * const   kCommentsContainerStoryboardID       = @"commentscontainer";
static NSString * const   kKeyboardBarStoryboardID             = @"keyboardbar";

static NSString * const   kProfileCreateStoryboardID           = @"profileCreate";
