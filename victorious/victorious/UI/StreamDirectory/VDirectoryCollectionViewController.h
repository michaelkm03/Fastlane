//
//  VStreamDirectoryCollectionView.h
//  victorious
//
//  Created by Will Long on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VDirectory, VDirectoryDataSource;

@interface VDirectoryCollectionViewController : UICollectionViewController

@property (nonatomic, readonly) VDirectory* directory;
@property (strong, nonatomic, readonly) VDirectoryDataSource* directoryDataSource;

+ (instancetype)streamDirectoryForDirectory:(VDirectory*)directory;

@end
