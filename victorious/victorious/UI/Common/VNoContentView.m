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

@property (nonatomic, weak) IBOutlet UIImageView *iconImageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *messageLabel;

@end

@implementation VNoContentView

+ (instancetype)noContentViewWithFrame:(CGRect)frame
{
    VNoContentView *noContentView = [[[NSBundle mainBundle] loadNibNamed:@"VNoContentView" owner:nil options:nil] objectAtIndex:0];
    
    noContentView.frame = frame;

    return noContentView;
}

#pragma mark - VHasManagedDependencies

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    if ( dependencyManager != nil )
    {
        self.titleLabel.font = [dependencyManager fontForKey:VDependencyManagerHeading1FontKey];
        self.messageLabel.font = [dependencyManager fontForKey:VDependencyManagerHeading4FontKey];
        self.titleLabel.textColor = [dependencyManager colorForKey:VDependencyManagerContentTextColorKey];
        self.messageLabel.textColor = [dependencyManager colorForKey:VDependencyManagerContentTextColorKey];
        self.iconImageView.tintColor = [dependencyManager colorForKey:VDependencyManagerContentTextColorKey];
    }
}

#pragma mark - Property Accessors

- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
}

- (NSString *)title
{
    return self.titleLabel.text;
}

- (void)setMessage:(NSString *)message
{
    self.messageLabel.text = message;
}

- (NSString *)message
{
    return self.messageLabel.text;
}

- (void)setIcon:(UIImage *)icon
{
    self.iconImageView.image = [icon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (UIImage *)icon
{
    return self.iconImageView.image;
}

@end
