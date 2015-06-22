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
 will provide the liking and display update funcitonality.  This allows
 that calling code to provide this functionality to various types of UI
 containers that have a like button so long as they adopt this protocol
 and expose that like button through the `likeButton` property.
 
 @see VLikeController, VNewContentViewController
 */
@protocol VContentLikeButtonProvider <NSObject>

@property (nonatomic, readonly) VContentLikeButton *likeButton;

@end