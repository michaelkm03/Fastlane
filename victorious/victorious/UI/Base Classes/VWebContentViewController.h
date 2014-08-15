//
//  VWebContentViewController.h
//  victorious
//
//  Recreated by Lawrence H. Leach on 08/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@interface VWebContentViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, strong) NSURL *urlKeyPath;
@property (nonatomic, strong) NSString *htmlString;

+ (instancetype)webContentViewController;

@end
