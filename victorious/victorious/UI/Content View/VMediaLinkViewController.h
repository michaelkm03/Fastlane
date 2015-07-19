//
//  VMediaLinkViewController.h
//  victorious
//
//  Created by Sharif Ahmed on 7/19/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VInStreamMediaLinkType.h"

typedef void (^MediaLoadingCompletionBlock) (CGFloat contentAspectRatio);

@interface VMediaLinkViewController : UIViewController

+ (instancetype)newWithMediaUrlString:(NSString *)urlString andMediaLinkType:(VInStreamMediaLinkType)linkType;

- (instancetype)initWithUrlString:(NSString *)urlString;

@property (nonatomic, readonly) NSString *mediaUrlString;

@property (nonatomic, weak, readonly) IBOutlet UIView *contentContainerView;

@property (nonatomic, assign) CGFloat contentAspectRatio;

@end

@interface VMediaLinkViewController (SubclassOverrides)

- (void)loadMediaWithCompletionBlock:(MediaLoadingCompletionBlock)completionBlock;

@end