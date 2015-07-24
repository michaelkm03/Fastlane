//
//  VTableViewStreamFocusHelper.h
//  victorious
//
//  Created by Cody Kolodziejzyk on 7/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VStreamFocusHelper.h"

/**
 A subclass of VStreamFocusHelper to enable focus
 funcionality in table views.
 */
@interface VTableViewStreamFocusHelper : VStreamFocusHelper

- (instancetype)initWithTableView:(UITableView *)tableView;

@end
