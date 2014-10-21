//
//  VNavigationSelectorProtocol.h
//  victorious
//
//  Created by Will Long on 10/14/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VNavigationHeaderDelegate;

@protocol VNavigationSelectorProtocol <NSObject>

@property (nonatomic, strong) NSArray *titles;///<An array of NSStrings used to populate the selector
@property (nonatomic) NSInteger currentIndex;///<The current index of the selector
@property (nonatomic) NSInteger lastIndex;///<The index selected before the current index.
@property (nonatomic, weak) id<VNavigationHeaderDelegate> delegate;///<The delegate of the selector.

@end
