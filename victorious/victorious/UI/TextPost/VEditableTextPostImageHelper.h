//
//  VEditableTextPostImageHelper.h
//  victorious
//
//  Created by Patrick Lynch on 4/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VEditableTextPostImageHelper : NSObject

/**
 Sets the background iamge URL.
 */
@property (nonatomic, strong) NSURL *imageURL;

/**
 Returns an image that combines the input image with the input color that is blended
 accoding to a style that is hardcoded and encapsulated inside this class.
 */
- (void)renderImage:(UIImage *)image color:(UIColor *)color completion:(void(^)(UIImage *))completion;

/**
 Resets the internal image cache by clearing out all items.  This should be called when
 a new image has been selected and is being supplied as the input image.
 */
- (void)clearCache;

@end
