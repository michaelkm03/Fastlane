//
//  VImageSearchResultCell.h
//  victorious
//
//  Created by Josh Hinman on 4/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VImageSearchResultCell : UICollectionViewCell

@property (nonatomic, readonly) UIImageView             *imageView;
@property (nonatomic, readonly) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, readonly) UIView                  *mask;

@end
