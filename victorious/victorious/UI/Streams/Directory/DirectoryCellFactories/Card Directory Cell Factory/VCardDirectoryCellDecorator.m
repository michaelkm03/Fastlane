//
//  VCardDirectoryCellDecorator.m
//  victorious
//
//  Created by Patrick Lynch on 3/4/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCardDirectoryCellDecorator.h"
#import "VCardDirectoryCell.h"
#import "VStreamItem+Fetcher.h"
#import "VSequence+Fetcher.h"
#import "VDependencyManager.h"
#import "VCardSeeMoreDirectoryCell.h"
#import "VStream.h"

@implementation VCardDirectoryCellDecorator

- (void)populateCell:(VCardDirectoryCell *)cell withStreamItem:(VStreamItem *)streamItem
{
    // Common data
    cell.nameLabel.text = streamItem.name;
    cell.streamItem = streamItem;
    cell.showVideo = NO;
    
    // Model-specific data
    if ( [streamItem isKindOfClass:[VStream class]] )
    {
        VStream *stream = (VStream *)streamItem;
        cell.countLabel.hidden = (stream.count.integerValue == 0);
        if ( [VCardDirectoryCell wantsToShowStackedBackgroundForStreamItem:streamItem] )
        {
            cell.countLabel.text = [NSString stringWithFormat:NSLocalizedString(@"NumStreams", @""), stream.count];
            cell.showStackedBackground = YES;
        }
        else
        {
            cell.countLabel.text = [NSString stringWithFormat:NSLocalizedString(@"NumItems", @""), stream.count];
            cell.showStackedBackground = NO;
        }
    }
    else if ( [streamItem isKindOfClass:[VSequence class]] )
    {
        VSequence *sequence = (VSequence *)streamItem;
        cell.showVideo = [sequence isVideo];
        cell.showStackedBackground = NO;
        cell.nameLabel.text = sequence.name;
        cell.countLabel.text = @"";
    }
    cell.nameLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)applyStyleToCell:(VCardDirectoryCell *)cell withDependencyManager:(VDependencyManager *)dependencyManager
{
    UIColor *backgroundColor = [dependencyManager colorForKey:VDependencyManagerBackgroundColorKey];
    UIColor *borderColor = [dependencyManager colorForKey:VDependencyManagerAccentColorKey];
    UIColor *textColor = [dependencyManager colorForKey:VDependencyManagerContentTextColorKey];
    UIColor *secondaryTextColor = [dependencyManager colorForKey:VDependencyManagerAccentColorKey];
    
    cell.stackBorderColor = borderColor;
    cell.stackBackgroundColor = backgroundColor;
    
    cell.nameLabel.font = [dependencyManager fontForKey:VDependencyManagerLabel1FontKey];
    cell.nameLabel.textColor = textColor;
    
    cell.countLabel.textColor = secondaryTextColor;
    cell.countLabel.font = [dependencyManager fontForKey:VDependencyManagerLabel4FontKey];
    
    cell.dependencyManager = dependencyManager;
}

- (void)applyStyleToSeeMoreCell:(VCardSeeMoreDirectoryCell *)cell withDependencyManager:(VDependencyManager *)dependencyManager
{
    cell.borderColor = [dependencyManager colorForKey:VDependencyManagerAccentColorKey];
    cell.backgroundColor = [dependencyManager colorForKey:VDependencyManagerBackgroundColorKey];
    
    cell.imageColor = cell.seeMoreLabel.textColor;
    cell.seeMoreLabel.font = [dependencyManager fontForKey:VDependencyManagerHeaderFontKey];
}

- (void)highlightTagsInCell:(VCardDirectoryCell *)cell withTagColor:(UIColor *)tagColor
{
}

@end
