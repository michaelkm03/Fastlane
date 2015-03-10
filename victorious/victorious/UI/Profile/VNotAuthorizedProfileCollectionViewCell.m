//
//  VNotLoggedInProfileCollectionViewCell.m
//  victorious
//
//  Created by Michael Sena on 3/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VNotAuthorizedProfileCollectionViewCell.h"

#import "UIView+AutoLayout.h"
#import "VNoContentView.h"
#import "VButton.h"
#import "VThemeManager.h"

@interface VNotAuthorizedProfileCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIView *noContentViewContainer;
@property (weak, nonatomic) IBOutlet VButton *loginButton;

@end

@implementation VNotAuthorizedProfileCollectionViewCell

#pragma mark - VSharedCollectionReusableViewMethods

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    return CGSizeMake(CGRectGetWidth(bounds), 400.0f);
}

#pragma mark - NSObject

- (void)awakeFromNib
{
    VNoContentView *noContentView = [VNoContentView noContentViewWithFrame:self.noContentViewContainer.bounds];
    noContentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.noContentViewContainer addSubview:noContentView];
    [self.noContentViewContainer v_addFitToParentConstraintsToSubview:noContentView];
    noContentView.iconImageView.image = [[UIImage imageNamed:@"profileGenericUser"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    noContentView.iconImageView.tintColor = [UIColor lightGrayColor];
    noContentView.titleLabel.text = NSLocalizedString(@"You're not logged in!", @"");
    noContentView.messageLabel.text = NSLocalizedString(@"Join me and together we can rule the galaxy as father and son. All the cool kids are doing it.", @"");
    
    [self.loginButton setStyle:VButtonStylePrimary];
    [self.loginButton setTitle:NSLocalizedString(@"Login", @"") forState:UIControlStateNormal];
    self.loginButton.primaryColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    self.loginButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
}

#pragma mark - Target/Action

- (IBAction)loginPressed:(id)sender
{
    [self requestLogin];
}

#pragma mark - VLoginRequest

- (NSString *)localizedExplanation
{
    return NSLocalizedString(@"User requested login from profile", nil);
}

#pragma mark - Private Methods

- (void)requestLogin
{
    [self.delegate notAuthorizedProfileCellwantsLogin:self];
}

@end
