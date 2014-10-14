//
//  VNavigationSelectorProtocol.h
//  victorious
//
//  Created by Will Long on 10/14/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VNavigationSelectorDelegate;

@protocol VNavigationSelectorProtocol <NSObject>

@property (nonatomic, strong) NSArray *titles;
@property (nonatomic) NSInteger currentIndex;
@property (nonatomic, weak) IBOutlet id<VNavigationSelectorDelegate> delegate;

@end

@protocol VNavigationSelectorDelegate <NSObject>

- (void)navSelector:(UIView<VNavigationSelectorProtocol> *)selector selectedIndex:(NSInteger)index;

@end
