//
//  VSegmentedNavSelector.h
//  victorious
//
//  Created by Will Long on 10/14/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VNavigationSelectorProtocol.h"

@interface VSegmentedNavSelector : UIView <VNavigationSelectorProtocol>

@property (nonatomic, strong) UISegmentedControl *segmentedControl;

@end
