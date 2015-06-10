//
//  VSuggestedUsersHeaderCell.m
//  victorious
//
//  Created by Patrick Lynch on 6/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VSuggestedUsersHeaderCell.h"
#import "VCreatorMessageViewController.h"
#import "UIView+AutoLayout.h"

@interface VSuggestedUsersHeaderCell ()

@property (nonatomic, strong) VCreatorMessageViewController *creatorMessageViewController;
@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, weak) IBOutlet UIView *container;

@end

@implementation VSuggestedUsersHeaderCell

+ (NSString *)suggestedReuseIdentifier
{
    return NSStringFromClass( [self class] );
}

- (void)awakeFromNib
{
    self.creatorMessageViewController = [[VCreatorMessageViewController alloc] init];
    [self.container addSubview:self.creatorMessageViewController.view];
    [self.container v_addFitToParentConstraintsToSubview:self.creatorMessageViewController.view];
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    
    [self.creatorMessageViewController setDependencyManager:dependencyManager];
}

- (void)setMessage:(NSString *)message
{
    [self.creatorMessageViewController setMessage:message];
}

@end
