//
//  VEndCardModelBuilder.m
//  victorious
//
//  Created by Patrick Lynch on 4/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VEndCardModelBuilder.h"
#import "VSequence+Fetcher.h"
#import "VEndCard+Fetcher.h"
#import "VEndCardModel.h"
#import "VUser.h"
#import "VEndCardActionModel.h"
#import "VDependencyManager.h"

#define FORCE_SHOW_DEBUG_END_CARD 0

static NSString * const kGifActionIconKey = @"action_gif_icon";
static NSString * const kRepostActionIconKey = @"action_repost_icon";
static NSString * const kRepostSuccessActionIconKey = @"action_repost_success_icon";
static NSString * const kShareActionIconKey = @"action_share_icon";
static NSString * const kMemeActionIconKey = @"action_meme_icon";


@interface VEndCardModelBuilder()

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VEndCardModelBuilder

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    return [[VEndCardModelBuilder alloc] initWithDependencyManager:dependencyManager];
}

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if ( self != nil )
    {
        _dependencyManager = dependencyManager;
    }
    return self;
}

- (instancetype)init
{
    NSAssert(NO, @"Use the designated initializer");
    return nil;
}

- (VEndCardModel *)createWithSequence:(VSequence *)sequence
{
#if FORCE_SHOW_DEBUG_END_CARD
#warning Debug end card will show for all video sequences... make sure to turn this off before committing!
    return [self DEBUG_createWithSequence:sequence];
#endif
    
    if ( sequence.endCard == nil  )
    {
        return nil;
    }
    
    VSequence *nextSequence = sequence.endCard.nextSequence;
    if ( nextSequence == nil  )
    {
        return nil;
    }
    
    // The end card only supports video sequences, so if we have any other type of content here
    // we return nil and calling code will not show the end card
    const BOOL isValidVideoSequence = [nextSequence isVideo];
    if ( !isValidVideoSequence )
    {
        return nil;
    }
    
    VEndCardModel *endCardModel = [[VEndCardModel alloc] init];
    endCardModel.videoTitle = sequence.name;
    endCardModel.nextSequenceId = nextSequence.remoteId;
    endCardModel.nextVideoTitle = nextSequence.sequenceDescription;
    endCardModel.nextVideoThumbailImageURL = [NSURL URLWithString:(NSString *)nextSequence.previewImagesObject];
    endCardModel.streamName = sequence.endCard.streamName ?: @"";
    endCardModel.videoAuthorName = nextSequence.user.name;
    endCardModel.videoAuthorProfileImageURL = [NSURL URLWithString:nextSequence.user.pictureUrl];
    endCardModel.countdownDuration = sequence.endCard.countdownDuration.unsignedIntegerValue;
    endCardModel.dependencyManager = self.dependencyManager;
    endCardModel.actions = [self createActionsWithPermissions:sequence.endCard.permissions];
    
    return endCardModel;
}

#pragma mark - Action creation

- (NSArray *)createActionsWithPermissions:(VSequencePermissions *)permissions
{
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    if ( permissions.canGIF )
    {
        [actions addObject:[self actionForGIF]];
    }
    if ( permissions.canRepost )
    {
        [actions addObject:[self actionForRepost]];
    }
    if ( permissions.canMeme )
    {
        [actions addObject:[self actionForMeme]];
    }
    
    // There is not currently a permission for sharing, so it is always allowed
    [actions addObject:[self actionForShare]];
    
    return [NSArray arrayWithArray:actions];
}

- (VEndCardActionModel *)actionForGIF
{
    VEndCardActionModel *action = [[VEndCardActionModel alloc] init];
    action.identifier = VEndCardActionIdentifierGIF;
    action.textLabelDefault = NSLocalizedString( @"GIF", @"Create a GIF from this video" );
    action.iconImageDefault = [self.dependencyManager imageForKey:kGifActionIconKey];
    return action;
}

- (VEndCardActionModel *)actionForRepost
{
    VEndCardActionModel *action = [[VEndCardActionModel alloc] init];
    action.identifier = VEndCardActionIdentifierRepost;
    action.textLabelDefault = NSLocalizedString( @"Repost", @"Post a copy of this video" );
    action.textLabelSuccess = NSLocalizedString( @"Reposted", @"Indicating the video has already been reposted." );
    action.iconImageDefault = [self.dependencyManager imageForKey:kRepostActionIconKey];
    action.iconImageSuccess = [self.dependencyManager imageForKey:kRepostSuccessActionIconKey];
    return action;
}

- (VEndCardActionModel *)actionForShare
{
    VEndCardActionModel *action = [[VEndCardActionModel alloc] init];
    action.identifier = VEndCardActionIdentifierShare;
    action.textLabelDefault = NSLocalizedString( @"Share", @"Share this video" );
    action.iconImageDefault = [self.dependencyManager imageForKey:kShareActionIconKey];
    return action;
}

- (VEndCardActionModel *)actionForMeme
{
    VEndCardActionModel *action = [[VEndCardActionModel alloc] init];
    action.identifier = VEndCardActionIdentifierMeme;
    action.textLabelDefault = NSLocalizedString( @"Meme", @"Create a meme from this video" );
    action.iconImageDefault = [self.dependencyManager imageForKey:kMemeActionIconKey];
    return action;
}

#pragma mark - Debugging/testing

#if FORCE_SHOW_DEBUG_END_CARD
- (VEndCardModel *)DEBUG_createWithSequence:(VSequence *)sequence
{
    VEndCardModel *endCardModel = [[VEndCardModel alloc] init];
    endCardModel.videoTitle = @"videoTitle";
    endCardModel.nextSequenceId = @"15461";
    endCardModel.nextVideoTitle = @"nextVideoTitle";
    endCardModel.nextVideoThumbailImageURL = sequence.previewImageUrl;
    endCardModel.streamName = @"STREAM NAME";
    endCardModel.videoAuthorName = sequence.user.name;
    endCardModel.videoAuthorProfileImageURL = [NSURL URLWithString:sequence.user.pictureUrl];
    endCardModel.countdownDuration = 20000;
    endCardModel.dependencyManager = self.dependencyManager;
    endCardModel.actions = [self createActionsWithPermissions:sequence.endCard.permissions];
    return endCardModel;
}

#endif

@end
