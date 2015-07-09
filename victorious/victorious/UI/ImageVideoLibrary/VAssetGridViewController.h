//
//  VAssetGridViewController.h
//  victorious
//
//  Created by Michael Sena on 6/29/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VMediaSource.h"

@class PHAssetCollection;

@interface VAssetGridViewController : UICollectionViewController <VMediaSource>

+ (instancetype)assetGridViewController;

@property (nonatomic, strong) PHAssetCollection *collectionToDisplay;

@property (nonatomic, assign) BOOL alternateFolderButtonEnabled;

@property (nonatomic, copy) void (^alternateFolderSelectionHandler)();

@end
