//
//  VDirectoryCollectionViewController.h
//  victorious
//
//  Created by Sharif Ahmed on 3/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAbstractStreamCollectionViewController.h"
#import "VHasManagedDependencies.h"

/**
    A collection view controller that displays content in a format determined its "directoryCell" component
 */
@interface VDirectoryCollectionViewController : VAbstractStreamCollectionViewController <VHasManagedDependencies>

/**
    Navigates to a view controller that can appropriately display the provided stream item.
 
    @param event The stream cell event that occured
 */
- (void)navigateToDisplayStreamItemWithEvent:(StreamCellContext *)event;

@end
