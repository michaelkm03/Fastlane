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
static NSString * const kEnableMediaSaveKey = @"autoEnableMediaSave";
static NSString * const kOptionsContainerBackgroundKey = @"color.background.optionsContainer";
static NSString * const kSaveSwitchTintColor = @"color.switch";

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
        NSString *saveText = [_dependencyManager stringForKey:kSaveTextKey];
        self.saveContentLabel.text = NSLocalizedString(saveText, @"");
        self.contentView.backgroundColor = [_dependencyManager colorForKey:kOptionsContainerBackgroundKey];
        self.cameraRollSwitch.onTintColor = [_dependencyManager colorForKey:kSaveSwitchTintColor];
        NSNumber *autoEnableSave = [_dependencyManager numberForKey:kEnableMediaSaveKey];
        if ( autoEnableSave != nil )
        {
            self.cameraRollSwitch.on = [autoEnableSave boolValue];
        }
        else
        {
            self.cameraRollSwitch.on = YES;
        }
    }
}

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds andSectionInsets:(UIEdgeInsets)insets
{
    CGSize size = bounds.size;
    size.height = kDesiredHeight;
    size.width -= insets.left + insets.right;
    return size;
}

@end
