//
//  VTextPostViewModel.h
//  victorious
//
//  Created by Patrick Lynch on 3/25/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VDependencyManager;

@interface VTextPostViewModel : NSObject

@property (nonatomic, assign, readonly) CGFloat lineHeightMultipler;  ///< Multiplied by font's `pointSize` to get optimal line height
@property (nonatomic, assign, readonly) CGFloat verticalSpacing; ///< A value that determines how the height of a background frame relates to the height of a line of text
@property (nonatomic, assign, readonly) CGFloat lineOffsetMultiplier; ///< A value that is used in conjuction with an attributed text's intrinsic height to properly align background frames
@property (nonatomic, assign, readonly) CGFloat horizontalSpacing; ///< The amount of space between normal and callout text
@property (nonatomic, assign, readonly) CGFloat calloutWordKerning; ///< The amount of padding on the left and right of a called out word, within its backgroudn frame
@property (nonatomic, readonly) UIColor *backgroundColor; ///< The color of the text post background frames

/**
 The attributes used for rendering normal text, i.e. text that is not a callout or placeholder.
 */
- (NSDictionary *)textAttributesWithDependencyManager:(VDependencyManager *)dependencyManager;

/**
 The attributes used for rendering a callout, which is separated and emphasized in the design.
 */
- (NSDictionary *)calloutAttributesWithDependencyManager:(VDependencyManager *)dependencyManager;

@end
