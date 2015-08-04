//
//  VDirectoryCollectionViewController+VDirectoryGroupedItemDelegate.m
//  victorious
//
//  Created by Sharif Ahmed on 4/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDirectoryCollectionViewController+VShowcaseDirectorySelection.h"
#import "VStream.h"
#import "VStreamItem+Fetcher.h"
#import "victorious-Swift.h"

@implementation VDirectoryCollectionViewController (VShowcaseDirectorySelection)

- (void)showcaseDirectoryCell:(VShowcaseDirectoryCell *)showcaseDirectoryCell didSelectStreamItem:(VStreamItem *)streamItem
{
    StreamCellTrackingEvent *event = [StreamCellTrackingEvent new];
    event.stream = self.currentStream;
    event.streamItem = streamItem;
    event.fromShelf = NO;
    
    [self navigateToDisplayStreamItemWithEvent:event];
}

@end
