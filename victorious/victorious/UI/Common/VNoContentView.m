//
//  VNoContentView.m
//  victorious
//
//  Created by Will Long on 6/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VNoContentView.h"
#import "VDependencyManager.h"

@interface VNoContentView ()

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VNoContentView

+ (instancetype)noContentViewWithFrame:(CGRect)frame
{
    VNoContentView *noContentView = [[[NSBundle mainBundle] loadNibNamed:@"VNoContentView" owner:nil options:nil] objectAtIndex:0];
    
    noContentView.frame = frame;

    return noContentView;
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    if ( dependencyManager != nil )
    {
        self.titleLabel.font = [dependencyManager fontForKey:VDependencyManagerHeading1FontKey];
        self.messageLabel.font = [dependencyManager fontForKey:VDependencyManagerHeading4FontKey];
        self.titleLabel.textColor = [dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
        self.messageLabel.textColor = [dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
        self.iconImageView.tintColor = [dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    }
}

@end
