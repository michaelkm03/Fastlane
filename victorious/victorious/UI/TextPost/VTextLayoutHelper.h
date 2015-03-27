//
//  VTextLayoutHelper.h
//  victorious
//
//  Created by Patrick Lynch on 3/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VDependencyManager, VTextPostViewModel, VTextPostTextView;

@interface VTextLayoutHelper : NSObject

- (NSArray *)textLinesFromText:(NSString *)text
                withAttributes:(NSDictionary *)attributes
                      maxWidth:(CGFloat)maxWidth;

- (void)updateTextViewBackground:(VTextPostTextView *)textView
                   calloutRanges:(NSArray *)calloutRanges;

- (void)addWordPaddingWithVaule:(NSInteger)wordPadding
             toAttributedString:(NSMutableAttributedString *)attributedString
              withCalloutRanges:(NSArray *)calloutRanges;

@end
