//
//  VSuggestedUserRetryCell.m
//  victorious
//
//  Created by Sharif Ahmed on 6/26/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VSuggestedUserRetryCell.h"
#import "VDependencyManager+VBackgroundContainer.h"
#import "VButton.h"
#import "UIView+AutoLayout.h"

static NSString * const kTextTitleColorKey = @"color.text.label1";
static NSString * const kBackgroundKey = @"background.detail";

@interface VSuggestedUserRetryCell ()

@property (nonatomic, weak) IBOutlet UILabel *loadStateLabel;
@property (nonatomic, weak) IBOutlet VButton *tapToRetryButton;

@end

@implementation VSuggestedUserRetryCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.layer.borderWidth = 1.0f;
    self.tapToRetryButton.userInteractionEnabled = NO;
    [self.tapToRetryButton setTitle:NSLocalizedString(@"Retry", nil) forState:UIControlStateNormal];
    self.tapToRetryButton.titleLabel.numberOfLines = 0;
    self.loadStateLabel.numberOfLines = 0;
    self.tapToRetryButton.titleLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    if ( dependencyManager != nil )
    {
        self.layer.borderColor = [dependencyManager colorForKey:VDependencyManagerAccentColorKey].CGColor;
        [dependencyManager addBackgroundToBackgroundHost:self forKey:kBackgroundKey];
        
        UIFont *font = [self.dependencyManager fontForKey:VDependencyManagerHeading3FontKey];
        self.loadStateLabel.font = font;
        self.tapToRetryButton.titleLabel.font = font;
        
        UIColor *textColor = [self.dependencyManager colorForKey:kTextTitleColorKey];
        self.loadStateLabel.textColor = textColor;
        [self.tapToRetryButton setTitleColor:textColor forState:UIControlStateNormal];
    }
}

- (void)setState:(VSuggestedUserRetryCellState)state
{
    _state = state;
    if ( state == VSuggestedUserRetryCellStateDefault )
    {
        [self.tapToRetryButton hideActivityIndicator];
        self.loadStateLabel.text = NSLocalizedString(@"GenericFailMessage", nil);
    }
    else
    {
        [self.tapToRetryButton showActivityIndicator];
        self.loadStateLabel.text = NSLocalizedString(@"Loading...", nil);
    }
}

@end
