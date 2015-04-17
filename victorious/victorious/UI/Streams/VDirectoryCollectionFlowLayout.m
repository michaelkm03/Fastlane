//
//  VDirectoryCollectionFlowLayout.m
//  victorious
//
//  Created by Sharif Ahmed on 4/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDirectoryCollectionFlowLayout.h"

@implementation VDirectoryCollectionFlowLayout

- (instancetype)initWithMarqueeDelegate:(id<VDirectoryCollectionFlowLayoutDelegate>)delegate
{
    self = [super init];
    if ( self != nil )
    {
        _delegate = delegate;
    }
    return self;
}

- (BOOL)isMarqueeCellAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.delegate hasMarqueeCell] && ( indexPath.row == 0 && indexPath.section == 0 );
}

@end
