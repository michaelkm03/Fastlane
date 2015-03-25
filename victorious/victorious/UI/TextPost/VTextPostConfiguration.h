//
//  VTextPostConfiguration.h
//  victorious
//
//  Created by Patrick Lynch on 3/25/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VTextPostConfiguration : NSObject

@property (nonatomic, assign, readonly) CGFloat lineHeightMultipler;  ///< Multiplied by font's `pointSize` to get optimal line height
@property (nonatomic, assign, readonly) CGFloat verticalSpacing;
@property (nonatomic, assign, readonly) CGFloat lineOffsetMultiplier;
@property (nonatomic, assign, readonly) CGFloat horizontalSpacing;
@property (nonatomic, assign, readonly) NSUInteger maxTextLength;
@property (nonatomic, readonly) UIColor *backgroundColor;

@end
