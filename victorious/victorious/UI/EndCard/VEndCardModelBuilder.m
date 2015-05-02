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

#define FORCE_SHOW_DEBUG_END_CARD 0

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
    if (self)
    {
        _dependencyManager = dependencyManager;
    }
    return self;
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
    endCardModel.actions = [self createActionsWithSequence:sequence];
    
    return endCardModel;
}

#pragma mark - Action creation

- (NSArray *)createActionsWithSequence:(VSequence *)sequence
{
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    if ( sequence.endCard.permissions.canRemix )
    {
        [actions addObject:[self actionForGIF]];
    }
    if ( sequence.endCard.permissions.canRepost )
    {
        [actions addObject:[self actionForRespost]];
    }
    if ( sequence.endCard.permissions.canShare )
    {
        [actions addObject:[self actionForShare]];
    }
    if ( sequence.endCard.permissions.canMeme )
    {
        [actions addObject:[self actionForMeme]];
    }
    return [NSArray arrayWithArray:actions];
}

- (VEndCardActionModel *)actionForGIF
{
    VEndCardActionModel *action = [[VEndCardActionModel alloc] init];
    action.identifier = VEndCardActionIdentifierGIF;
    action.textLabelDefault = NSLocalizedString( @"GIF", @"Created a GIF from this video" );
    action.iconImageNameDefault = @"action_gif";
    return action;
}

- (VEndCardActionModel *)actionForRespost
{
    VEndCardActionModel *action = [[VEndCardActionModel alloc] init];
    action.identifier = VEndCardActionIdentifierRepost;
    action.textLabelDefault = NSLocalizedString( @"Repost", @"Post a copy of this video" );
    action.textLabelSuccess = NSLocalizedString( @"Reposted", @"Indicating the video has already been reposted." );
    action.iconImageNameDefault = @"action_repost";
    action.iconImageNameSuccess = @"action_success";
    return action;
}

- (VEndCardActionModel *)actionForShare
{
    VEndCardActionModel *action = [[VEndCardActionModel alloc] init];
    action.identifier = VEndCardActionIdentifierShare;
    action.textLabelDefault = NSLocalizedString( @"Share", @"Share this video" );
    action.iconImageNameDefault = @"action_share";
    return action;
}

- (VEndCardActionModel *)actionForMeme
{
    VEndCardActionModel *action = [[VEndCardActionModel alloc] init];
    action.identifier = VEndCardActionIdentifierMeme;
    action.textLabelDefault = NSLocalizedString( @"Meme", @"Meme this video" );
    action.iconImageNameDefault = @"action_meme";
    return action;
}

#pragma mark - Debugging/testing

#if FORCE_SHOW_DEBUG_END_CARD
- (VEndCardModel *)DEBUG_createWithSequence:(VSequence *)sequence
{
    VEndCardModel *endCardModel = [[VEndCardModel alloc] init];
    endCardModel.videoTitle = sequence.sequenceDescription;
    endCardModel.nextSequenceId = nil;
    endCardModel.nextVideoTitle = nil;
    endCardModel.nextVideoThumbailImageURL = nil;
    endCardModel.streamName = sequence.endCard.streamName ?: @"";
    endCardModel.videoAuthorName = nil;
    endCardModel.videoAuthorProfileImageURL = nil;
    endCardModel.countdownDuration = 10;
    endCardModel.dependencyManager = self.dependencyManager;
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    endCardModel.actions = [self createActionsWithSequence:sequence];
    
    return endCardModel;
}

#endif

@end
