//
//  VDefaultProfileImageView.h
//  victorious
//
//  Created by Will Long on 10/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  An image view that defaults to the themed default profile image.
 */
@interface VDefaultProfileImageView : UIImageView

- (void)setup;
- (void)setProfileImageURL:(NSURL *)url;

@end
