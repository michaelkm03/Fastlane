//
//  VConstants.h
//  victorious
//
//  Created by David Keegan on 1/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)

typedef NS_OPTIONS(NSUInteger, VShareOptions)
{
    kVShareNone          = 0,
    kVShareToTwitter     = 1 << 0,
    kVShareToFacebook    = 1 << 1
};

typedef NS_ENUM(NSUInteger, VLoopType)
{
    kVLoopOnce       =   0,
    kVLoopRepeat     =   1,
    kVLoopReverse    =   2
};

typedef NS_ENUM(NSUInteger, VPlaybackSpeed)
{
    kVPlaybackNormalSpeed   =   0,
    kVPlaybackHalfSpeed     =   1,
    kVPlaybackDoubleSpeed   =   2
};


static NSUInteger const VConstantsMessageLength     = 140;
static NSUInteger const VConstantsForumTitleLength  = 65;

static NSUInteger const kFeaturedTableCellHeight = 180;
static NSUInteger const kStreamDoublePollCellHeight = 214;
static NSUInteger const kStreamPollCellHeight = 320;
static NSUInteger const kStreamYoutubeCellHeight = 180;
static NSUInteger const kStreamViewCellHeight = 320;
//TODO: update these 2 with real numbers
static NSUInteger const kStreamCommentHeaderHeight = 80;
static NSUInteger const kStreamCommentCellHeight = 110;


static NSString*   const   kVictoriousAppIDKey      = @"VictoriousAppID";

static NSString*   const   kTestflightDevToken      = @"TestflightDevAppToken";
static NSString*   const   kTestflightQAToken       = @"TestflightQAAppToken";
static NSString*   const   kTestflightReleaseToken  = @"TestflightReleaseAppToken";

static NSString*   const   kRemoteIdKey = @"remoteId";

static NSString* const VConstantsMediaTypeYoutube   = @"youtube_video_id";
static NSString* const VConstantsMediaTypeVideo     = @"video";
static NSString* const VConstantsMediaTypeImage     = @"image";

static NSString* const VConstantMediaExtensionM3U8      = @"m3u8";
static NSString* const VConstantMediaExtensionPNG       = @"png";
static NSString* const VConstantMediaExtensionJPG       = @"jpg";
static NSString* const VConstantMediaExtensionJPEG      = @"jepg";
static NSString* const VConstantMediaExtensionMOV       = @"mov";

static NSString*   const   kVOwnerPollCategory = @"owner_poll";
static NSString*   const   kVOwnerImageCategory = @"owner_image";
static NSString*   const   kVOwnerVideoCategory = @"owner_video";
static NSString*   const   kVOwnerForumCategory = @"owner_forum";

static NSString*   const   kVUGCPollCategory = @"ugc_poll";
static NSString*   const   kVUGCImageCategory = @"ugc_image";
static NSString*   const   kVUGCVideoCategory = @"ugc_video";
static NSString*   const   kVUGCForumCategory = @"ugc_forum";

static NSString*   const   kFeaturedCategory = @"featured";

static NSString*   const   kSearchCache = @"SearchCache";
static NSString*   const   kVPagedFetchCache = @"PagedFetchCache";

static NSString*   const   kHomeStreamStoryboardID              = @"homestream";
static NSString*   const   kOwnerStreamStoryboardID             = @"ownerstream";
static NSString*   const   kCommunityStreamStoryboardID         = @"communitystream";
static NSString*   const   kForumStreamStoryboardID             = @"forumstream";
static NSString*   const   kContentViewStoryboardID             = @"content";
static NSString*   const   kEmotiveBallisticsBarStoryboardID    = @"emotiveballistics";
static NSString*   const   kPollAnswerBarStoryboardID           = @"pollanswerbar";
static NSString*   const   kCommentsContainerStoryboardID       = @"commentscontainer";
static NSString*   const   kKeyboardBarStoryboardID             = @"keyboardbar";


static NSString*   const   kStreamContentSegueStoryboardID      = @"streamcontent";
static NSString*   const   kContentCommentSegueStoryboardID     = @"contentcomment";

static NSString*   const   kStreamCommentSegueID                = @"streamcomment";

static NSString*   const   kUnwindToContentSegueID              = @"unwindToContentView";

