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
#import "VStream+Fetcher.h"
#import "VSequence+Fetcher.h"
#import "VDependencyManager.h"
#import "VCardSeeMoreDirectoryCell.h"
#import "VTagStringFormatter.h"

@implementation VCardDirectoryCellDecorator

- (void)populateCell:(VCardDirectoryCell *)cell withStreamItem:(VStreamItem *)streamItem
{
    // Common data
    cell.nameLabel.text = streamItem.name;
    [cell setPreviewImagePath:[streamItem.previewImagePaths firstObject] placeholderImage:nil];
    cell.showVideo = NO;
    
    // Model-specific data
    if ( [streamItem isKindOfClass:[VStream class]] )
    {
        VStream *stream = (VStream *)streamItem;
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
}

- (void)applyStyleToSeeMoreCell:(VCardSeeMoreDirectoryCell *)cell withDependencyManager:(VDependencyManager *)dependencyManager
{
    cell.borderColor = [dependencyManager colorForKey:VDependencyManagerAccentColorKey];
    cell.backgroundColor = [dependencyManager colorForKey:VDependencyManagerBackgroundColorKey];
    
    cell.imageColor = [dependencyManager colorForKey:VDependencyManagerSecondaryAccentColorKey];
    cell.seeMoreLabel.font = [dependencyManager fontForKey:VDependencyManagerHeaderFontKey];
}

- (void)highlightTagsInCell:(VCardDirectoryCell *)cell withTagColor:(UIColor *)tagColor
{
    NSAssert(tagColor != nil, @"To highlight tags, tag color must not be nil");
    
    UIColor *defaultColor = cell.nameLabel.textColor;
    if ( tagColor == nil || defaultColor == nil )
    {
        return;
    }
    
    NSMutableAttributedString *formattedNameText = [[NSMutableAttributedString alloc] initWithAttributedString:cell.nameLabel.attributedText];
    [VTagStringFormatter tagDictionaryFromFormattingAttributedString:formattedNameText
                                             withTagStringAttributes:@{ NSForegroundColorAttributeName : tagColor }
                                          andDefaultStringAttributes:@{ NSForegroundColorAttributeName : defaultColor }];
    cell.nameLabel.attributedText = formattedNameText;
}

@end
