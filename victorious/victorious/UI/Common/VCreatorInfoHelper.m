//
//  VCreatorInfoHelper.m
//  victorious
//
//  Created by Patrick Lynch on 3/18/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//
#import "VCreatorInfoHelper.h"
#import "VDependencyManager.h"
#import <SDWebImage/UIImageView+WebCache.h>

// Owner info
NSString * const VDependencyManagerOwnerProfileImageKey = @"profile_image";

@interface VCreatorInfoHelper ()

@property (nonatomic, weak) IBOutlet UILabel *creatorNameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *creatorAvatarImageView;

@end

@implementation VCreatorInfoHelper

- (void)populateViewsWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSDictionary *creatorInfo = [dependencyManager templateValueOfType:[NSDictionary class] forKey:VDependencyManagerOwnerInfoKey];
    if ( creatorInfo == nil )
    {
        // If there's no valid data to show for this creator, hide these views
        self.creatorNameLabel.hidden = YES;
        self.creatorAvatarImageView.hidden = YES;
        
        return;
    }
    else
    {
        self.creatorNameLabel.hidden = NO;
        self.creatorAvatarImageView.hidden = NO;
    }
    
    NSString *creatorName = creatorInfo[ VDependencyManagerOwnerNameKey ];
    self.creatorNameLabel.text = creatorName;
    self.creatorNameLabel.font = [dependencyManager fontForKey:VDependencyManagerLabel1FontKey];
    
    NSString *creatorUrl = creatorInfo[ VDependencyManagerOwnerProfileImageKey ];
    self.creatorAvatarImageView.layer.cornerRadius = 17.0f; // Enough to make it a circle
    self.creatorAvatarImageView.layer.borderWidth = 1.0f;
    self.creatorAvatarImageView.layer.borderColor = [dependencyManager colorForKey:VDependencyManagerLinkColorKey].CGColor;
    self.creatorAvatarImageView.layer.masksToBounds = YES;
    
    [self.creatorAvatarImageView sd_setImageWithURL:[NSURL URLWithString:creatorUrl] placeholderImage:nil];
    
    [self.creatorAvatarImageView setNeedsDisplay];
}

@end
