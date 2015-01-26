//
//  VTextToolViewController.h
//  victorious
//
//  Created by Michael Sena on 12/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VTextTypeTool.h"

@interface VTextToolViewController : UIViewController

+ (instancetype)textToolViewController;

/**
 *  Setting this properly will reconfigure the textToolViewController with the attributes of the text type.
 */
@property (nonatomic, strong) VTextTypeTool *textType;


/**
 *  VTextToolViewController will render the text entered to an image, if the image has not yet been renedered this call will block the calling thread until rendering is complete. ¡This is a blocking operation!
 */
@property (nonatomic, readonly) UIImage *renderedImage;

/**
 *  YES, if the user has entered text.
 */
@property (nonatomic, readonly) BOOL userEnteredText;

/**
 *  The embedded text if any.
 */
@property (nonatomic, readonly) NSString *embeddedText;

@end
