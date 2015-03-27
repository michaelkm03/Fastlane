//
//  VCommentCellUtilitesController.m
//  victorious
//
//  Created by Patrick Lynch on 12/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCommentCellUtilitesController.h"
#import "VContentCommentsCell.h"
#import "VComment+Fetcher.h"
#import "VCommentsUtilityButtonConfiguration.h"
#import "VObjectManager.h"
#import "VObjectManager+Comment.h"
#import "VObjectManager+Login.h"
#import "VUser+Fetcher.h"
#import "VConstants.h"

static const CGFloat kVCommentCellUtilityButtonWidth = 55.0f;

@interface VCommentCellUtilitesController()

@property (nonatomic, strong) NSArray *buttonConfigs;
@property (nonatomic, strong) VComment *comment;
@property (nonatomic, strong) UIView *cellView;
@property (nonatomic, strong) id<VCommentCellUtilitiesDelegate> delegate;

@end

@implementation VCommentCellUtilitesController

- (instancetype)initWithComment:(VComment *)comment
                       cellView:(UIView *)cellView
                       delegate:(id<VCommentCellUtilitiesDelegate>)delegate
{
    self = [super init];
    if (self)
    {
        _cellView = cellView;
        _comment = comment;
        _delegate = delegate;
        
        [self setupButtonConfigurations];
    }
    return self;
}

- (void)setupButtonConfigurations
{
    VCommentsUtilityButtonConfiguration *sharedConfig = [VCommentsUtilityButtonConfiguration sharedInstance];
    
    if ( [self commentIsEditable:self.comment] && [self commentIsDeletable:self.comment] )
    {
        self.buttonConfigs = @[ sharedConfig.editButtonConfig, sharedConfig.deleteButtonConfig ];
    }
    else if ( [self commentIsEditable:self.comment] )
    {
        self.buttonConfigs = @[ sharedConfig.editButtonConfig ];
    }
    else if ( [self commentIsDeletable:self.comment]  )
    {
        self.buttonConfigs = @[ sharedConfig.deleteButtonConfig ];
    }
    else if ( [self commentIsFlaggable:self.comment]  )
    {
        self.buttonConfigs = @[ sharedConfig.flagButtonConfig ];
    }
}

#pragma mark - Server actions

- (void)flagComment
{   
    [[VObjectManager sharedManager] flagComment:self.comment
                                   successBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
     {
         [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ReportedTitle", @"")
                                     message:NSLocalizedString(@"ReportCommentMessage", @"")
                                    delegate:nil
                           cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                           otherButtonTitles:nil] show];
         
         [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidFlagComment];
         
     }
                                      failBlock:^(NSOperation *operation, NSError *error)
     {
         NSDictionary *params = @{ VTrackingKeyErrorMessage : error.localizedDescription ?: @"" };
         [[VTrackingManager sharedInstance] trackEvent:VTrackingEventFlagCommentDidFail parameters:params];
         
         NSString *errorTitle = nil;
         NSString *errorMessage = nil;
         if ( error.code == kVCommentAlreadyFlaggedError )
         {
             errorTitle = NSLocalizedString(@"CommentAlreadyReported", @"");
             errorMessage = NSLocalizedString(@"ReportCommentMessage", @"");
         }
         else
         {
             errorTitle = NSLocalizedString(@"WereSorry", @"");
             errorMessage = NSLocalizedString(@"ErrorOccured", @"");
         }
         
         [[[UIAlertView alloc] initWithTitle:errorTitle
                                    message:errorMessage
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                          otherButtonTitles:nil] show];
     }];
}

- (void)deleteComment
{
    [[VObjectManager sharedManager] removeComment:self.comment
                                       withReason:nil
                                     successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
     {
         [self.delegate commentRemoved:self.comment];
         
         [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidDeleteComment];
     }
                                        failBlock:^(NSOperation *operation, NSError *error)
     {
         NSDictionary *params = @{ VTrackingKeyErrorMessage : error.localizedDescription ?: @"" };
         [[VTrackingManager sharedInstance] trackEvent:VTrackingEventDeleteCommentDidFail parameters:params];
         
         [[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"WereSorry", @"")
                                     message:NSLocalizedString(@"ErrorOccured", @"")
                                    delegate:nil
                           cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                           otherButtonTitles:nil] show];
     }];
}

- (BOOL)commentIsFlaggable:(VComment *)comment
{
    // User doesn't need to be logged in (will show login prompt when tapped)
    // But a logged in user can't flag their own content
    
    VObjectManager *objectManager = [VObjectManager sharedManager];
    VUser *mainUser = objectManager.mainUser;
    if ( objectManager.mainUserLoggedIn )
    {
        return ![comment.userId isEqualToNumber:mainUser.remoteId];
    }
    return YES;
}

- (BOOL)commentIsEditable:(VComment *)comment
{
    // User must be logged in and this must be his or her comment
    VObjectManager *objectManager = [VObjectManager sharedManager];
    VUser *mainUser = objectManager.mainUser;
    if ( objectManager.mainUserLoggedIn && [comment.userId isEqualToNumber:mainUser.remoteId] )
    {
        return YES;
    }
    return NO;
}

- (BOOL)commentIsDeletable:(VComment *)comment
{
    // User must be logged in and this must be his or her comment
    // Or user is owner
    VObjectManager *objectManager = [VObjectManager sharedManager];
    VUser *mainUser = objectManager.mainUser;
    if ( objectManager.mainUserLoggedIn )
    {
        if ( [comment.userId isEqualToNumber:mainUser.remoteId] || mainUser.isOwner )
        {
            return YES;
        }
    }
    return NO;
}

#pragma mark - VSwipeViewCellDelegate

- (void)utilityButton:(VUtilityButtonCell *)button selectedAtIndex:(NSUInteger)index
{
    VUtilityButtonConfig *config = self.buttonConfigs[ index ];
    
    switch ( config.type )
    {
        case VCommentCellUtilityTypeFlag:
            [self flagComment];
            break;
        case VCommentCellUtilityTypeEdit:
            [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectEditComment];
            [self.delegate editComment:self.comment];
            break;
        case VCommentCellUtilityTypeDelete:
            [self deleteComment];
            break;
    }
}

- (NSUInteger)numberOfUtilityButtons
{
    return self.buttonConfigs.count;
}

- (CGFloat)utilityButtonWidth
{
    return kVCommentCellUtilityButtonWidth;
}

- (UIImage *)iconImageForButtonAtIndex:(NSUInteger)index
{
    VUtilityButtonConfig *config = self.buttonConfigs[ index ];
    return config.iconImage;
}

- (UIColor *)backgroundColorForButtonAtIndex:(NSUInteger)index
{
    VUtilityButtonConfig *config = self.buttonConfigs[ index ];
    return config.backgroundColor;
}

- (UIView *)parentCellView
{
    return self.cellView;
}

@end
