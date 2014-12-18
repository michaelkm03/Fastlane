//
//  VPublishViewController.h
//  victorious
//
//  Created by Michael Sena on 12/17/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VHasManagedDependencies.h"

@interface VPublishViewController : UIViewController <VHasManagedDependancies>

@property (nonatomic, strong) UIImage *previewImage;
@property (nonatomic, strong) NSURL *mediaToUploadURL;

@property (nonatomic, copy) void (^completion)(BOOL published);

@property (nonatomic, copy, readonly) void (^animateInBlock)(void);

@end
