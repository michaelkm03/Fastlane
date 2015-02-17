//
//  VFollowingStreamCollectionViewController.h
//  victorious
//
//  Created by Patrick Lynch on 2/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VStreamCollectionViewController.h"

@class VStream;

@interface VFollowingStreamCollectionViewController : VStreamCollectionViewController

+ (instancetype)streamViewControllerForStream:(VStream *)stream;

@end
