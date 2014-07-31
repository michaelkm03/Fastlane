//
//  VWebContentViewController.h
//  victorious
//
//  Created by Gary Philipp on 1/29/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@interface VWebContentViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, strong) NSURL*     urlKeyPath;
@property (nonatomic, strong) NSString*     htmlString;

@end
