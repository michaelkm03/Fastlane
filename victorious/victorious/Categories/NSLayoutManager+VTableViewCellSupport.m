//
//  NSLayoutManager+VTableViewCellSupport.m
//  victorious
//
//  Created by Patrick Lynch on 10/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "NSLayoutManager+VTableViewCellSupport.h"

/**
 This category is a hack to fix a crash when selector "layoutSubviewsOfCell:" is called on the layout manager.
 It provides a response to that selector with an empty stubbed method implementation
 */
@interface NSLayoutManager(VTableViewCellSupport)

@end