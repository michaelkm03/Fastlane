//
//  VTextLayoutHelper.h
//  victorious
//
//  Created by Patrick Lynch on 3/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VDependencyManager;

@interface VTextLayoutHelper : NSObject

- (NSArray *)textLinesFromText:(NSString *)text
                withAttributes:(NSDictionary *)attributes
                   inSuperview:(UIView *)superview;

- (NSArray *)createTextFieldsFromTextLines:(NSArray *)lines
                                attributes:(NSDictionary *)attributes
                                 superview:(UIView *)superview;

- (void)updateHashtagLayoutWithText:(NSString *)text
                          superview:(UIView *)superview
                  bottmLineTextView:(UIView *)bottmLineTextView
                         attributes:(NSDictionary *)attributes;

- (NSDictionary *)textAttributesWithDependencyManager:(VDependencyManager *)dependencyManager;

- (NSDictionary *)hashtagTextAttributesWithDependencyManager:(VDependencyManager *)dependencyManager;

@end
