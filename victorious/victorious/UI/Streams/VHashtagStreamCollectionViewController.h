//
//  VHashtagStreamCollectionViewController.h
//  victorious
//
//  Created by Patrick Lynch on 2/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDependencyManager.h"
#import "VStreamCollectionViewController.h"

@interface VHashtagStreamCollectionViewController : VStreamCollectionViewController

@end

#pragma mark -

@interface VDependencyManager (VHashtagStreamCollectionViewController)

- (VHashtagStreamCollectionViewController *)hashtagStreamWithHashtag:(NSString *)hashtag;

@end
