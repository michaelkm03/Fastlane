//
//  VSetExpirationViewController.h
//  victorious
//
//  Created by Gary Philipp on 3/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@class VSetExpirationViewController;

@protocol VSetExpirationDelegate <NSObject>
@required

- (void)setExpirationViewController:(VSetExpirationViewController *)viewController didSelectDate:(NSDate *)expirationDate;

@end

@interface VSetExpirationViewController : UIViewController

@property (nonatomic, strong)   UIImage*    previewImage;
@property (nonatomic, weak)     id<VSetExpirationDelegate>  delegate;

@end
