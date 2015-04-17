//
//  VDirectoryCollectionViewController+VDirectoryGroupedItemDelegate.m
//  victorious
//
//  Created by Sharif Ahmed on 4/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDirectoryCollectionViewController+VShowcaseDirectoryCellDelegate.h"
#import "VStream.h"
#import "VStreamItem+Fetcher.h"

@implementation VDirectoryCollectionViewController (VShowcaseDirectoryCellDelegate)

- (void)showcaseDirectoryCell:(VShowcaseDirectoryCell *)showcaseDirectoryCell didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    VStreamItem *streamItem;
    if ( showcaseDirectoryCell.stream.isContent )
    {
        streamItem = showcaseDirectoryCell.stream;
    }
    else if ( [showcaseDirectoryCell.stream isKindOfClass:[VStream class]] )
    {
        if ( (NSUInteger)indexPath.row >= showcaseDirectoryCell.stream.streamItems.count )
        {
            streamItem = showcaseDirectoryCell.stream;
        }
        else
        {
            streamItem = showcaseDirectoryCell.stream.streamItems[indexPath.row];
        }
    }
    [self navigateToDisplayStreamItem:streamItem];
}

@end
