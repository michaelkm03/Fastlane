//
//  VDirectoryCellDecorator.m
//  victorious
//
//  Created by Patrick Lynch on 3/4/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDirectoryCellDecorator.h"
#import "VDirectoryItemCell.h"
#import "VStreamItem+Fetcher.h"
#import "VStream+Fetcher.h"
#import "VSequence+Fetcher.h"
#import "VDependencyManager.h"
#import "VDirectorySeeMoreItemCell.h"

@implementation VDirectoryCellDecorator

- (void)populateCell:(VDirectoryItemCell *)cell withStreamItem:(VStreamItem *)streamItem
{
    // Common data
    cell.nameLabel.text = streamItem.name;
    [cell setPreviewImagePath:[streamItem.previewImagePaths firstObject] placeholderImage:nil];
    cell.showVideo = NO;
    
    // Model-specific data
    if ( [streamItem isKindOfClass:[VStream class]] )
    {
        VStream *stream = (VStream *)streamItem;
        if ( stream.isStreamOfStreams )
        {
            cell.countLabel.text = [NSString stringWithFormat:NSLocalizedString(@"NumStreams", @""), stream.count];
            cell.showStackedBackground = YES;
        }
        else
        {
            cell.countLabel.text = [NSString stringWithFormat:NSLocalizedString(@"NumItems", @""), stream.count];
            cell.showStackedBackground = NO;
        }
        cell.nameLabel.textAlignment = NSTextAlignmentCenter;
    }
    else if ( [streamItem isKindOfClass:[VSequence class]] )
    {
        VSequence *sequence = (VSequence *)streamItem;
        cell.showVideo = [sequence isVideo];
        cell.showStackedBackground = NO;
        cell.nameLabel.text = sequence.name;
        cell.nameLabel.textAlignment = NSTextAlignmentLeft;
        cell.countLabel.text = @"";
    }
}

- (void)applyStyleToCell:(VDirectoryItemCell *)cell withDependencyManager:(VDependencyManager *)dependencyManager
{
    UIColor *backgroundColor = [dependencyManager colorForKey:@"color.background"];
    UIColor *borderColor = [dependencyManager colorForKey:@"color.accent"];
    UIColor *textColor = [dependencyManager colorForKey:@"color.text"];
    UIColor *secondaryTextColor = [dependencyManager colorForKey:@"color.text.accent"];
    
    cell.stackBorderColor = borderColor;
    cell.stackBackgroundColor = backgroundColor;
    
    cell.nameLabel.font = [dependencyManager fontForKey:@"font.label1"];
    cell.nameLabel.textColor = textColor;
    
    cell.countLabel.textColor = secondaryTextColor;
    cell.countLabel.font = [dependencyManager fontForKey:@"font.label4"];
}

- (void)applyStyleToSeeMoreCell:(VDirectorySeeMoreItemCell *)cell withDependencyManager:(VDependencyManager *)dependencyManager
{
    cell.borderColor = [dependencyManager colorForKey:@"color.accent"];;
    cell.imageColor = [dependencyManager colorForKey:@"color.accent.secondary"];
    cell.backgroundColor = [dependencyManager colorForKey:@"color.background"];;
    cell.seeMoreLabel.textColor = [dependencyManager colorForKey:@"text.color.content"];
    cell.seeMoreLabel.font = [dependencyManager fontForKey:@"font.header"];
}

@end