//
//  VHashtagStreamCollectionViewController.h
//  victorious
//
//  Created by Patrick Lynch on 2/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VStreamCollectionViewController.h"

@interface VHashtagStreamCollectionViewController : VStreamCollectionViewController

+ (instancetype)instantiateWithHashtag:(NSString *)hashtag;

+ (instancetype)streamViewControllerForStream:(VStream *)stream;

@end
