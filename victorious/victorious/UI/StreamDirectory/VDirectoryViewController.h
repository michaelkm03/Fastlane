//
//  VStreamDirectoryCollectionView.h
//  victorious
//
//  Created by Will Long on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VAbstractStreamCollectionViewController.h"

@class VStream, VStreamCollectionViewDataSource;

/**
 *  A view controller that uses a UICollectionView to display the streamItems in a VStream.
 */

@interface VDirectoryViewController : VAbstractStreamCollectionViewController

/**
 *  Instantiates a VDirectoryViewController from the main storyboard.
 *
 *  @param stream The stream to display
 *
 *  @return A VDirectoryViewController
 */
+ (instancetype)streamDirectoryForStream:(VStream *)stream;

@end
