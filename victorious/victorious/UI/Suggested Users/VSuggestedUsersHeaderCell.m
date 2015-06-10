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
#import "VSuggestedUsersResponder.h"

static NSString * const kTextBodyColorKey = @"color.text.label3";

@interface VSuggestedUsersHeaderCell ()

@property (nonatomic, strong) VCreatorMessageViewController *creatorMessageViewController;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, weak) IBOutlet UIButton *continueButton;
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
    self.continueButton.tintColor = [dependencyManager colorForKey:kTextBodyColorKey];
    self.continueButton.titleLabel.font = [dependencyManager fontForKey:VDependencyManagerLabel3FontKey];
}

- (void)setMessage:(NSString *)message
{
    [self.creatorMessageViewController setMessage:message];
}

- (IBAction)continueButtonTapped:(id)sender
{
    id<VSuggestedUsersResponder> responder = [self targetForAction:@selector(onSuggestedUsersContinue) withSender:self];
    NSParameterAssert( responder != nil );
    NSParameterAssert( [responder conformsToProtocol:@protocol(VSuggestedUsersResponder)] );
    [responder onSuggestedUsersContinue];
}

@end
