//
//  VTextPostImageHelper.h
//  victorious
//
//  Created by Patrick Lynch on 4/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VTextPostImageHelper : NSObject

/**
 Sets the background iamge URL.
 */
@property (nonatomic, strong) NSURL *imageURL;


/**
 Loads an image using the provided asset URL, renders a new image that combines the input image with
 the input color that is blended accoding to a style that is hardcoded and encapsulated inside this class,
 then saves the rendered image to a new asset URL and provides it as single parameter in the completion block.
 This method is used for rendered final output.
 */
- (void)exportWithAssetAtURL:(NSURL *)assetURL color:(UIColor *)color completion:(void(^)(NSURL *, NSError *))completion;

/**
 Returns an image that combines the input image with the input color that is blended
 accoding to a style that is hardcoded and encapsulated inside this class.
 */
- (void)renderImage:(UIImage *)image color:(UIColor *)color completion:(void(^)(UIImage *, UIColor *))completion;

/**
 Resets the internal image cache by clearing out all items.  This should be called when
 a new image has been selected and is being supplied as the input image.
 */
- (void)clearCache;

@end
