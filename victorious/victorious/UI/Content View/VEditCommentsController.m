//
//  VEditCommentsController.m
//  victorious
//
//  Created by Patrick Lynch on 12/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VEditCommentsController.h"
#import "VContentCommentsCell.h"
#import "VComment+Fetcher.h"
#import "VCommentsUtilityButtonConfiguration.h"

static const CGFloat kVCommentCellUtilityButtonWidth = 55.0f;

typedef NS_ENUM( NSUInteger, VCommentCellUtilityButton )
{
    VCommentCellUtilityButtonEdit,
    VCommentCellUtilityButtonDelete,
    VCommentCellUtilityButtonFlag
};

@interface VEditCommentsController()

@property (nonatomic, strong) NSArray *buttonConfigs;

@property (nonatomic, strong) VComment *comment;
@property (nonatomic, strong) UIView *cellView;

@end

@implementation VEditCommentsController

- (instancetype)initWithComment:(VComment *)comment cellView:(UIView *)cellView
{
    self = [super init];
    if (self)
    {
        _cellView = cellView;
        _comment = comment;
        
        [self setupButtonConfigurations];
    }
    return self;
}

- (void)setupButtonConfigurations
{
    VCommentsUtilityButtonConfiguration *sharedConfig = [VCommentsUtilityButtonConfiguration sharedInstance];
    
    if ( self.comment.isEditable && self.comment.isDeletable )
    {
        self.buttonConfigs = @[ sharedConfig.editButtonConfig, sharedConfig.deleteButtonConfig ];
    }
    else if ( self.comment.isEditable )
    {
        self.buttonConfigs = @[ sharedConfig.editButtonConfig ];
    }
    else if ( self.comment.isDeletable )
    {
        self.buttonConfigs = @[ sharedConfig.deleteButtonConfig ];
    }
    else if ( self.comment.isFlaggable )
    {
        self.buttonConfigs = @[ sharedConfig.flagButtonConfig ];
    }
}

#pragma mark - VSwipeViewCellDelegate

- (void)utilityButton:(VUtilityButtonCell *)button selectedAtIndex:(NSUInteger)index
{
    VUtilityButtonConfig *config = self.buttonConfigs[ index ];
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
