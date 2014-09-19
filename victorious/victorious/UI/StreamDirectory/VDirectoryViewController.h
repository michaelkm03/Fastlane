//
//  VStreamDirectoryCollectionView.h
//  victorious
//
//  Created by Will Long on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VStream, VDirectoryDataSource;

@interface VDirectoryViewController : UIViewController

@property (nonatomic, readonly) VStream *stream;
@property (strong, nonatomic, readonly) VDirectoryDataSource* directoryDataSource;
@property (weak, nonatomic, readonly) UICollectionView *collectionView;

+ (instancetype)streamDirectoryForStream:(VStream *)stream;

@end
