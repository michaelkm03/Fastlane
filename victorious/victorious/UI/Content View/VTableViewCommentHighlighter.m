//
//  VTableViewCommentHighlighter.m
//  victorious
//
//  Created by Sharif Ahmed on 7/18/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTableViewCommentHighlighter.h"
#import "VCommentCell.h"

@interface VTableViewCommentHighlighter ()

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation VTableViewCommentHighlighter

- (instancetype)init
{
    NSAssert(NO, @"Use the designated initializer");
    return nil;
}

- (instancetype)initWithTableView:(UITableView *)tableView
{
    self = [super init];
    if ( self != nil )
    {
        _tableView = tableView;
    }
    return self;
}

- (NSInteger)numberOfSections
{
    return self.tableView.numberOfSections;
}

- (void)scrollToIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (UIView *)viewToAnimateForIndexPath:(NSIndexPath *)indexPath
{
    VCommentCell *cell = (VCommentCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if ( cell == nil || ![cell isKindOfClass:[VCommentCell class]] )
    {
        return nil;
    }
    return cell;
}

@end
