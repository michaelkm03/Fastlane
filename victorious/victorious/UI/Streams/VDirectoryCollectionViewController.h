//
//  VDirectoryCollectionViewController.h
//  victorious
//
//  Created by Sharif Ahmed on 3/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAbstractStreamCollectionViewController.h"

/**
    A collectionViewController
 */
@interface VDirectoryCollectionViewController : VAbstractStreamCollectionViewController

/**
    Navigates to a view controller that can appropriately display the provided stream item.
 
    @param streamItem The stream item to display in a new view controller
 */
- (void)navigateToDisplayStreamItem:(VStreamItem *)streamItem;

@end
