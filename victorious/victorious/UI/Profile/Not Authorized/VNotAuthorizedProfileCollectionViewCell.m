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
#import "VDependencyManager.h"

static const CGFloat kCornderRadius = 3.0f;

@interface VNotAuthorizedProfileCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIView *noContentViewContainer;
@property (weak, nonatomic) VNoContentView *noContentView;
@property (weak, nonatomic) IBOutlet VButton *loginButton;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VNotAuthorizedProfileCollectionViewCell

#pragma mark - VSharedCollectionReusableViewMethods

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds andDependencyManager:(VDependencyManager *)dependencyManager
{
    NSString *titleString = [VNotAuthorizedProfileCollectionViewCell titleString];
    NSString *messageString = [VNotAuthorizedProfileCollectionViewCell messageString];
    
    CGSize size = [VNoContentView desiredSizeWithCollectionViewBounds:bounds titleString:titleString messageString:messageString andDependencyManager:dependencyManager];
    
    return size;
}

+ (NSString *)messageString
{
    NSString *messageString = NSLocalizedString(@"ProfileNotLoggedInMessage", @"User is not logged in message.");
    return messageString;
}

+ (NSString *)titleString
{
    NSString *titleString = NSLocalizedString(@"You're not logged in!", @"");
    return titleString;
}

#pragma mark - NSObject

- (void)awakeFromNib
{
    NSString *messageString = [VNotAuthorizedProfileCollectionViewCell messageString];
    NSString *titleString = [VNotAuthorizedProfileCollectionViewCell titleString];

    VNoContentView *noContentView = [VNoContentView viewFromNibWithFrame:self.noContentViewContainer.bounds];
    noContentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.noContentViewContainer addSubview:noContentView];
    [self.noContentViewContainer v_addFitToParentConstraintsToSubview:noContentView];
    noContentView.icon = [[UIImage imageNamed:@"profileGenericUser"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    noContentView.message = messageString;
    noContentView.title = titleString;

    self.noContentView = noContentView;
 
    [self.loginButton setStyle:VButtonStylePrimary];
    [self.loginButton setTitle:NSLocalizedString(@"Login", @"") forState:UIControlStateNormal];
    
    self.noContentViewContainer.layer.cornerRadius = kCornderRadius;
    self.noContentViewContainer.layer.masksToBounds = YES;
}

#pragma mark - VHasManagedDependencies

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    if ( dependencyManager != nil )
    {
        if ( [self.noContentView respondsToSelector:@selector(setDependencyManager:)] )
        {
            self.noContentView.dependencyManager = self.dependencyManager;
        }
        self.loginButton.primaryColor = [dependencyManager colorForKey:VDependencyManagerLinkColorKey];
        self.loginButton.titleLabel.font = [dependencyManager fontForKey:VDependencyManagerHeading2FontKey];
        self.loginButton.accessibilityIdentifier = VAutomationIdentifierProfileLogInButton;
    }
}

#pragma mark - Target/Action

- (IBAction)loginPressed:(id)sender
{
    [self requestLogin];
}

#pragma mark - Private Methods

- (void)requestLogin
{
    [self.delegate notAuthorizedProfileCellWantsLogin:self];
}

@end
