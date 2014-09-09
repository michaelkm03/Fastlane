//
//  VBaseCollectionViewCell.h
//  victorious
//
//  Created by Michael Sena on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VSharedCollectionViewMethods <NSObject>

+ (NSString *)reuseIdentifier;
+ (UINib *)nibForCell;

@end

@interface VBaseCollectionViewCell : UICollectionViewCell <VSharedCollectionViewMethods>

@end
