//
//  VStreamDirectoryCollectionView.h
//  victorious
//
//  Created by Will Long on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VStream, VDirectoryDataSource;

/**
 *  A view controller that uses a UICollectionView to display the streamItems in a VStream.
 */
@interface VDirectoryViewController : UIViewController

@property (nonatomic, readonly) VStream *stream;///<The stream to display
@property (strong, nonatomic, readonly) VDirectoryDataSource *directoryDataSource;///<The VDirectoryDataSource for the object.
@property (weak, nonatomic, readonly) UICollectionView *collectionView;///<The colletion view used to display the streamItems

/**
 *  Instantiates a VDirectoryViewController from the main storyboard.
 *
 *  @param stream The stream to display
 *
 *  @return A VDirectoryViewController
 */
+ (instancetype)streamDirectoryForStream:(VStream *)stream;

@end
