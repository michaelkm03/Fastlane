//
//  VDiscoverHeaderView.h
//  victorious
//
//  Created by Sharif Ahmed on 4/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VDependencyManager;

@interface VDiscoverHeaderView : UITableViewHeaderFooterView

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

+ (CGSize)preferredSize;
+ (UINib *)nibForHeader;

@end
