//
//  VContentThumbnailCell.h
//  victorious
//
//  Created by Patrick Lynch on 6/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VContentThumbnailCell : UICollectionViewCell

+ (NSString *)preferredReuseIdentifier;

- (void)setImageURL:(NSURL *)imageURL;

@end
