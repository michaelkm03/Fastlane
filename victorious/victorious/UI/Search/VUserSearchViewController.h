//
//  VUserSearchViewController.h
//  victorious
//
//  Created by Lawrence Leach on 8/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VUserSearchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

+ (instancetype)newFromStoryboard;

@end
