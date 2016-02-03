//
//  VDirectoryCollectionViewController+VDirectoryGroupedItemDelegate.m
//  victorious
//
//  Created by Sharif Ahmed on 4/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDirectoryCollectionViewController+VShowcaseDirectorySelection.h"
#import "VStream.h"
#import "victorious-Swift.h"

@implementation VDirectoryCollectionViewController (VShowcaseDirectorySelection)

- (void)showcaseDirectoryCell:(VShowcaseDirectoryCell *)showcaseDirectoryCell didSelectStreamItem:(VStreamItem *)streamItem
{
    StreamCellContext *event = [[StreamCellContext alloc] initWithStreamItem:streamItem
                                                                      stream:self.currentStream
                                                                   fromShelf:NO];
    
    [self navigateToDisplayStreamItemWithEvent:event];
}

@end
