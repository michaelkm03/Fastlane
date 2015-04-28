//
//  VDiscoverHeaderView.m
//  victorious
//
//  Created by Sharif Ahmed on 4/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDiscoverHeaderView.h"
#import "VDependencyManager.h"

@interface VDiscoverHeaderView ()

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@end

@implementation VDiscoverHeaderView

- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
}

- (NSString *)title
{
    return self.titleLabel.text;
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    if ( dependencyManager != nil )
    {
        self.titleLabel.font = [dependencyManager fontForKey:VDependencyManagerHeading3FontKey];
    }
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(320.0f, [[self class] desiredHeight]);
}

+ (CGFloat)desiredHeight
{
    return 37.0f;
}

+ (UINib *)nibForHeader
{
    return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil];
}

@end
