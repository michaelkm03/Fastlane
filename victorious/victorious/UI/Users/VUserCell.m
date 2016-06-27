//
//  VUserCell.m
//  victorious
//
//  Created by Patrick Lynch on 6/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VUserCell.h"
#import "VDependencyManager.h"
#import "VFollowControl.h"
#import "VDefaultProfileButton.h"
#import "victorious-Swift.h"
#import <KVOController/FBKVOController.h>
#import "victorious-Swift.h"

static const CGFloat kUserCellHeight = 51.0f;

@interface VUserCell ()

@property (weak, nonatomic) IBOutlet VDefaultProfileButton *userButton;
@property (nonatomic, weak) IBOutlet UILabel *userName;
@property (nonatomic, weak) IBOutlet VFollowControl *followControl;
@property (nonatomic, strong) VUser *user;

@end

@implementation VUserCell

#pragma mark - VSharedCollectionReusableViewMethods

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    return CGSizeMake( CGRectGetWidth(bounds), kUserCellHeight );
}

#pragma mark - NSObject

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.userButton addBorderWithWidth:1.0 andColor:[UIColor whiteColor]];
    self.userButton.dependencyManager = self.dependencyManager;
    self.contentView.backgroundColor = [UIColor clearColor];
    
    if ([AgeGate isAnonymousUser])
    {
        [self.followControl removeFromSuperview];
        self.followControl = nil;
    }
}

#pragma mark - Public

- (void)setUser:(VUser *)user
{
    if ( [_user isEqual:user] )
    {
        return;
    }
    
    [self.KVOController unobserve:_user
                          keyPath:NSStringFromSelector(@selector(isFollowedByMainUser))];
    
    _user = user;
    
    __weak typeof(self) welf = self;
    [self.KVOController observe:user
                        keyPath:NSStringFromSelector(@selector(isFollowedByMainUser))
                        options:NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change)
     {
         [welf updateFollowingAnimated:YES];
     }];
    
    self.userButton.user = user;
    self.userName.text = user.name;
    self.followControl.enabled = YES;
    
    [self updateFollowingAnimated:NO];
}

#pragma mark - VHasManagedDependencies

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    
    self.userName.font = [_dependencyManager fontForKey:VDependencyManagerLabel1FontKey];
    self.userButton.dependencyManager = dependencyManager;
    self.userButton.tintColor = [_dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    self.followControl.dependencyManager = dependencyManager;
}

#pragma mark - Target/Action

- (IBAction)tappedFollowControl:(VFollowControl *)sender
{
    // FollowUserOperation/FollowUserToggleOperation not supported in 5.0
}

- (void)updateFollowingAnimated:(BOOL)animated
{
}

@end
