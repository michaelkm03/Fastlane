//
//  VEmptyProgressView.m
//  victorious
//
//  Created by Michael Sena on 9/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VEmptyProgressView.h"
#import "VProgressBarView.h"

//Theme
#import "VThemeManager.h"

@interface VEmptyProgressView ()

@property (weak, nonatomic) IBOutlet VProgressBarView *progressBar;

@end

@implementation VEmptyProgressView

#pragma mark - NSobject

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.progressBar.progressColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor  ];
}

#pragma mark - Property Accessors

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;

    [self.progressBar setProgress:progress
                         animated:YES];
}

#pragma mark - VSharedCollectionReusableViewMethods

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    return CGSizeMake(CGRectGetWidth(bounds), 5.0f);
}

@end
