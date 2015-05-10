//
//  VLinkTextViewHelper.m
//  victorious
//
//  Created by Patrick Lynch on 2/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "CCHLinkTextView.h"
#import "VDependencyManager.h"
#import "VLinkTextViewHelper.h"

@interface VLinkTextViewHelper ()

@property (nonatomic, readonly) VDependencyManager *dependencyManager;

@end

@implementation VLinkTextViewHelper

#pragma mark - CCHLinkTextView

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if ( self != nil )
    {
        _dependencyManager = dependencyManager;
    }
    return self;
}

- (void)setupLinkTextView:(CCHLinkTextView *)linkTextView withText:(NSString *)text range:(NSRange)range
{
    linkTextView.textContainerInset = UIEdgeInsetsMake( 12, 0, 0, 0 );
    linkTextView.textContainer.maximumNumberOfLines = 1;
    linkTextView.textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    UIColor *normalColor = linkTextView.textColor ?: [UIColor whiteColor];
    normalColor = [normalColor colorWithAlphaComponent:0.7f];
    UIColor *linkColor = normalColor;
    UIFont *font = [self.dependencyManager fontForKey:VDependencyManagerHeading4FontKey];
    UIFont *linkFont = [self.dependencyManager fontForKey:VDependencyManagerButton2FontKey];
    
    NSDictionary *attributes = @{ NSFontAttributeName : font,
                                  NSForegroundColorAttributeName : normalColor,
                                  NSParagraphStyleAttributeName : paragraphStyle };
    
    NSDictionary *linkAttributes = @{ NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid),
                                      NSFontAttributeName : linkFont,
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
