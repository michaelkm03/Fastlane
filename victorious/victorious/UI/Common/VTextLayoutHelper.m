//
//  VTextLayoutHelper.m
//  victorious
//
//  Created by Patrick Lynch on 3/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTextLayoutHelper.h"
#import "VDependencyManager.h"

static const CGFloat kTextSpacingHorizontal = 4;
static const CGFloat kTextSpacingVertical = 2;

@implementation VTextLayoutHelper

- (NSArray *)textLinesFromText:(NSString *)text
                withAttributes:(NSDictionary *)attributes
                      maxWidth:(CGFloat)maxWidth
{
    NSMutableArray *lines = [[NSMutableArray alloc] init];
    
    if ( [text rangeOfString:@" "].location == NSNotFound )
    {
        return [NSArray arrayWithArray:lines];
    }
    
    NSMutableArray *allWords = [NSMutableArray arrayWithArray:[text componentsSeparatedByString:@" "]];
    // NSInteger maxIterations = allWords.count;
    
    // for ( NSInteger i = 0; i < maxIterations && allWords.count > 0; i++ )
    while ( allWords.count > 0 )
    {
        NSMutableString *currentLine = [[NSMutableString alloc] init];
        NSString *currentLineWithNextWord = [currentLine stringByAppendingFormat:@" %@", allWords.firstObject];
        while ( [currentLineWithNextWord sizeWithAttributes:attributes].width < maxWidth )
        {
            [currentLine appendFormat:@" %@", allWords.firstObject];
            [allWords removeObjectAtIndex:0];
            if ( allWords.count == 0 )
            {
                break;
            }
        }
        [lines addObject:currentLine];
    }
    
    NSLog( @"num lines = %@", @(lines.count) );
    return [NSArray arrayWithArray:lines];
}

- (NSArray *)createTextFieldsFromTextLines:(NSArray *)lines
                                attributes:(NSDictionary *)attributes
                                 superview:(UIView *)superview
{
    [superview.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop)
     {
         [subview removeFromSuperview];
     }];
    
    NSUInteger y = 0;
    NSMutableArray *textViews = [[NSMutableArray alloc] init];
    for ( NSString *line in lines )
    {
        UITextView *textView = [[UITextView alloc] init];
        textView.backgroundColor = [UIColor whiteColor];
        textView.editable = NO;
        textView.selectable = NO;
        textView.attributedText = [[NSAttributedString alloc] initWithString:line
                                                                  attributes:attributes];
        [superview addSubview:textView];
        [textView sizeToFit];
        
        CGRect frame = textView.frame;
        frame.origin.y = (y++) * (CGRectGetHeight(frame) + kTextSpacingVertical);
        frame.size.width = [lines.lastObject isEqualToString:line] ? frame.size.width : superview.frame.size.width;
        textView.frame = frame;
        
        [textViews addObject:textView];
    }
    
    return [[NSArray alloc] initWithArray:textViews];
}


- (void)updateHashtagLayoutWithText:(NSString *)text
                          superview:(UIView *)superview
                  bottmLineTextView:(UIView *)bottmLineTextView
                         attributes:(NSDictionary *)attributes
{
    UITextView *textView = [[UITextView alloc] init];
    textView.backgroundColor = [UIColor whiteColor];
    textView.editable = NO;
    textView.selectable = NO;
    textView.attributedText = [[NSAttributedString alloc] initWithString:text
                                                              attributes:attributes];
    [superview addSubview:textView];
    
    [textView sizeToFit];
    
    CGRect frame = textView.frame;
    if ( bottmLineTextView.frame.size.width + kTextSpacingHorizontal + textView.frame.size.width <= superview.frame.size.width )
    {
        frame.origin.y = bottmLineTextView.frame.origin.y;
        frame.origin.x = CGRectGetMaxX( bottmLineTextView.frame ) + kTextSpacingHorizontal;
    }
    else
    {
        frame.origin.y = CGRectGetMaxY( bottmLineTextView.frame ) + kTextSpacingVertical;
        frame.origin.x = bottmLineTextView.frame.origin.x;
    }
    textView.frame = frame;
}

#pragma mark - Text Attributes

- (NSDictionary *)textAttributesWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    
    return @{ NSFontAttributeName: [dependencyManager fontForKey:@"font.heading2"],
              NSForegroundColorAttributeName: [dependencyManager colorForKey:@"color.text.content"] };
}

- (NSDictionary *)hashtagTextAttributesWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    
    return @{ NSFontAttributeName: [dependencyManager fontForKey:@"font.heading2"],
              NSForegroundColorAttributeName: [dependencyManager colorForKey:@"color.link"] };
}

@end
