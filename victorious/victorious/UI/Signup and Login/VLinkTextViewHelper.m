//
//  VLinkTextViewHelper.m
//  victorious
//
//  Created by Patrick Lynch on 2/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VLinkTextViewHelper.h"
#import "VThemeManager.h"

@implementation VLinkTextViewHelper

#pragma mark - CCHLinkTextView

- (void)setupLinkTextView:(CCHLinkTextView *)linkTextView withText:(NSString *)text range:(NSRange)range
{
    linkTextView.textContainerInset = UIEdgeInsetsMake( 12, 0, 0, 0 );
    linkTextView.textContainer.maximumNumberOfLines = 1;
    linkTextView.textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    UIColor *normalColor = linkTextView.textColor ?: [UIColor whiteColor];
    UIColor *linkColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    UIFont *font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading4Font];
    
    NSDictionary *attributes = @{ NSFontAttributeName : font ?: [NSNull null],
                                  NSForegroundColorAttributeName : normalColor,
                                  NSParagraphStyleAttributeName : paragraphStyle };
    
    NSDictionary *linkAttributes = @{ NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid),
                                      NSForegroundColorAttributeName : linkColor,
                                      NSUnderlineColorAttributeName : linkColor,
                                      CCHLinkAttributeName : [text substringWithRange:range] };
    
    UIColor *touchTextColor = [linkColor colorWithAlphaComponent:0.5f];
    linkTextView.linkTextTouchAttributes = @{ NSForegroundColorAttributeName : touchTextColor,
                                              NSUnderlineColorAttributeName : touchTextColor };
    
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];
    [mutableAttributedString addAttributes:linkAttributes range:range];
    linkTextView.tintColor = linkColor;
    linkTextView.attributedText = mutableAttributedString;
}

@end
