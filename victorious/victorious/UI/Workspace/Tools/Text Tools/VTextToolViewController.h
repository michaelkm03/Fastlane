//
//  VMemeWorkspaceToolViewController.h
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

@property (nonatomic, readonly) UIImage *renderedImage;

@end
