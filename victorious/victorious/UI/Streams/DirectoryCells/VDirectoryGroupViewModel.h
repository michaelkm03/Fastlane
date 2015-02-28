//
//  VDirectoryGroupViewModel.h
//  victorious
//
//  Created by Patrick Lynch on 2/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VDirectoryGroupViewModel : NSObject

@property (nonatomic, strong) UIColor *groupLabelColor;
@property (nonatomic, strong) UIFont *groupLabelFont;

@property (nonatomic, strong) UIColor *itemLabelColor;
@property (nonatomic, strong) UIFont *itemLabelFont;

@property (nonatomic, strong) UIColor *itemQuantityColor;
@property (nonatomic, strong) UIFont *itemQuantityFont;

@property (nonatomic, strong) UIColor *seeMoreLabelColor;
@property (nonatomic, strong) UIColor *seeMoreImageColor;
@property (nonatomic, strong) UIFont *seeMoreLabelFont;

@property (nonatomic, strong) UIColor *stackBackgroundColor;
@property (nonatomic, strong) UIColor *stackBorderColor;

@end
