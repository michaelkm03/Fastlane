//
//  VCommentCellUtilitiesController.m
//  victorious
//
//  Created by Patrick Lynch on 12/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCommentCellUtilitiesController.h"
#import "VContentCommentsCell.h"
#import "VComment+Fetcher.h"
#import "VCommentsUtilityButtonConfiguration.h"
#import "VObjectManager.h"
#import "VObjectManager+Comment.h"
#import "VObjectManager+Login.h"
#import "VUser.h"
#import "VConstants.h"
#import "VSequence.h"
#import "VSequencePermissions.h"

static const CGFloat kVCommentCellUtilityButtonWidth = 55.0f;

@interface VCommentCellUtilitiesController()

@property (nonatomic, strong) NSArray *buttonConfigs;
@property (nonatomic, strong) VComment *comment;
@property (nonatomic, weak) UIView *cellView;
@property (nonatomic, weak) id<VCommentCellUtilitiesDelegate> delegate;
@property (nonatomic, strong) VSequencePermissions *permissions;

@end

@implementation VCommentCellUtilitiesController

- (instancetype)initWithComment:(VComment *)comment
                       cellView:(UIView *)cellView
                       delegate:(id<VCommentCellUtilitiesDelegate>)delegate
                    permissions:(VSequencePermissions *)permissions
{
    self = [super init];
    if (self)
    {
        _cellView = cellView;
        _comment = comment;
        _delegate = delegate;
        _permissions = permissions;
                
        [self setupButtonConfigurations];
    }
    return self;
}

- (void)setupButtonConfigurations
{
    VCommentsUtilityButtonConfiguration *sharedConfig = [VCommentsUtilityButtonConfiguration sharedInstance];
    NSMutableArray *mutableButtonConfigs = [[NSMutableArray alloc] init];
    
    // Eventually the backend will include this logic in a permissions mask property for a VComment
    // Until then, we do the logic here
    BOOL isMainUserOwnerOfComment = [[VObjectManager sharedManager].mainUser isEqual:self.comment.user];
    
    if ( !isMainUserOwnerOfComment )
    {
        [mutableButtonConfigs addObject:sharedConfig.replyButtonConfig];
    }
    if ( isMainUserOwnerOfComment || self.permissions.canEditComments )
    {
        [mutableButtonConfigs addObject:sharedConfig.editButtonConfig];
    }
    
    if ( isMainUserOwnerOfComment || self.permissions.canDeleteComments )
    {
        [mutableButtonConfigs addObject:sharedConfig.deleteButtonConfig];
    }
    
    if ( !isMainUserOwnerOfComment && [self commentIsFlaggable:self.comment]  )
    {
        [mutableButtonConfigs addObject:sharedConfig.flagButtonConfig];
    }
    
    self.buttonConfigs = [NSArray arrayWithArray:mutableButtonConfigs];
}

#pragma mark - Server actions

- (void)flagComment
{
    [[VObjectManager sharedManager] flagComment:self.comment
                                   successBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
     {
         [self showAlertWithTitle:NSLocalizedString(@"ReportedTitle", @"")
                          message:NSLocalizedString(@"ReportCommentMessage", @"")
                          handler:^(UIAlertAction *_Nonnull action)
          {
              [self.delegate commentRemoved:self.comment];
              [[VObjectManager sharedManager] locallyRemoveComment:self.comment];
          }];
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
         
         [self showAlertWithTitle:errorTitle
                          message:errorMessage
                          handler:^(UIAlertAction *_Nonnull action)
          {
              [self.delegate commentRemoved:self.comment];
              [[VObjectManager sharedManager] locallyRemoveComment:self.comment];
          }];
     }];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message handler:(void (^)(UIAlertAction *))handler
{
    UIViewController *viewControllerForAlerts = [self.delegate viewControllerForAlerts];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"")
                                              style:UIAlertActionStyleDefault
                                            handler:handler]];
    [viewControllerForAlerts presentViewController:alert animated:YES completion:nil];
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
         
         [self showAlertWithTitle:NSLocalizedString(@"WereSorry", @"")
                          message:NSLocalizedString(@"ErrorOccured", @"")
                          handler:nil];
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
        case VCommentCellUtilityTypeReply:
            [self.delegate replyToComment:self.comment];
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
