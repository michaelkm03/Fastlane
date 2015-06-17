//
//  VContentLikeButtonProvider.h
//  victorious
//
//  Created by Patrick Lynch on 6/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import UIKit;

#import "VContentLikeButton.h"

/**
 Adopting this protocol allows calling code to determine if the adopter
 has a like button that should be used to initialize a controller that
 will provide the liking and display update funcitonality.
 
 @see VLikeController
 */
@protocol VContentLikeButtonProvider <NSObject>

@property (nonatomic, readonly) VContentLikeButton *likeButton;

@end