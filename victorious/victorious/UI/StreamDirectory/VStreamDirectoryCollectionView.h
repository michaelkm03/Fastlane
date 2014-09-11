//
//  VStreamDirectoryCollectionView.h
//  victorious
//
//  Created by Will Long on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VDirectory;

@interface VStreamDirectoryCollectionView : UICollectionView

@property (nonatomic, readonly) VDirectory* directory;

- (instancetype)initWithDirectory:(VDirectory *)directory;

@end
