//
//  VPublishSaveCollectionViewCell.m
//  victorious
//
//  Created by Sharif Ahmed on 6/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VPublishSaveCollectionViewCell.h"
#import "VDependencyManager.h"

static NSString * const kSaveTextKey = @"saveText";
static NSString * const kOptionsContainerBackgroundKey = @"color.optionsContainer";

static CGFloat const kDesiredHeight = 43.0f;

@interface VPublishSaveCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *saveContentLabel;

@end

@implementation VPublishSaveCollectionViewCell

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    if ( dependencyManager != nil )
    {
        self.saveContentLabel.font = [_dependencyManager fontForKey:VDependencyManagerHeading2FontKey];
        self.saveContentLabel.textColor = [_dependencyManager colorForKey:VDependencyManagerContentTextColorKey];
        self.saveContentLabel.text = [_dependencyManager stringForKey:kSaveTextKey];
        self.contentView.backgroundColor = [_dependencyManager colorForKey:kOptionsContainerBackgroundKey];
        self.cameraRollSwitch.onTintColor = [_dependencyManager colorForKey:VDependencyManagerAccentColorKey];
    }
}

+ (CGFloat)desiredHeight
{
    return kDesiredHeight;
}

@end
