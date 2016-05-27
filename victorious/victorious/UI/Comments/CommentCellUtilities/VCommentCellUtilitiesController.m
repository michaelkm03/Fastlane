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
#import "VConstants.h"
#import "VSequence.h"
#import "VSequencePermissions.h"
#import "victorious-Swift.h"

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
    BOOL isCurrentUserOwnerOfComment = [[VCurrentUser user] isEqual:self.comment.user];
    
    if ( !isCurrentUserOwnerOfComment )
    {
        [mutableButtonConfigs addObject:sharedConfig.replyButtonConfig];
    }
    if ( isCurrentUserOwnerOfComment || self.permissions.canEditComments )
    {
        [mutableButtonConfigs addObject:sharedConfig.editButtonConfig];
    }
    
    if ( isCurrentUserOwnerOfComment || self.permissions.canDeleteComments )
    {
        [mutableButtonConfigs addObject:sharedConfig.deleteButtonConfig];
    }
    
    if ( !isCurrentUserOwnerOfComment && [self commentIsFlaggable:self.comment]  )
    {
        [mutableButtonConfigs addObject:sharedConfig.flagButtonConfig];
    }
    
    if ([AgeGate isAnonymousUser])
    {
        mutableButtonConfigs = [NSMutableArray arrayWithArray:[AgeGate filterCommentCellUtilities:mutableButtonConfigs]];
    }
    
    self.buttonConfigs = [NSArray arrayWithArray:mutableButtonConfigs];
}

- (BOOL)commentIsFlaggable:(VComment *)comment
{
    return ![comment.userId isEqualToNumber:[VCurrentUser user].remoteId];;
}

#pragma mark - VSwipeViewCellDelegate

- (void)utilityButton:(VUtilityButtonCell *)button selectedAtIndex:(NSUInteger)index
{
    VUtilityButtonConfig *config = self.buttonConfigs[ index ];
    
    switch ( config.type )
    {
        case VCommentCellUtilityTypeFlag: {
            [self.delegate flagComment:self.comment];
            break;
        }
        case VCommentCellUtilityTypeEdit:
            [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectEditComment];
            [self.delegate editComment:self.comment];
            break;
            
        case VCommentCellUtilityTypeDelete: {
            [self.delegate deleteComment:self.comment];
        }
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
