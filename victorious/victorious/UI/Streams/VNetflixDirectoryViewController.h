//
//  VNetflixDirectoryViewController.h
//  victorious
//
//  Created by Sharif Ahmed on 2/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAbstractStreamCollectionViewController.h"
#import "VHasManagedDependencies.h"

@class VStream, VStreamCollectionViewDataSource;

@interface VNetflixDirectoryViewController : VAbstractStreamCollectionViewController <VHasManagedDependancies>

+ (instancetype)streamDirectoryForStream:(VStream *)stream dependencyManager:(VDependencyManager *)dependencyManager;

@end
