//
//  VTableViewCommentHighlighter.h
//  victorious
//
//  Created by Sharif Ahmed on 7/18/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAbstractCommentHighlighter.h"

@interface VTableViewCommentHighlighter : VAbstractCommentHighlighter

/**
 The desginated initializer requiring a collectionView to work with so it can control
 animation of the contentOffset and cells within.
 */
- (instancetype)initWithTableView:(UITableView *)tableView NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end
