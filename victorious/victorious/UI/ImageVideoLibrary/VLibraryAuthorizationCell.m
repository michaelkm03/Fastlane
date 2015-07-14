//
//  VLibraryAuthorizationCell.m
//  victorious
//
//  Created by Michael Sena on 7/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VLibraryAuthorizationCell.h"

@interface VLibraryAuthorizationCell ()

@property (strong, nonatomic) IBOutlet UILabel *promptLabel;
@property (strong, nonatomic) IBOutlet UILabel *callToActionLabel;

@end

@implementation VLibraryAuthorizationCell

#pragma mark - Property Accessors

// Text
- (void)setPromptText:(NSString *)promptText
{
    _promptText = [promptText copy];
    self.promptLabel.text = _promptText;
}

- (void)setCallToActionText:(NSString *)callToActionText
{
    _callToActionText = [callToActionText copy];
    if (_callToActionText == nil)
    {
        self.callToActionLabel.attributedText = nil;
    }
    else
    {
        [self updateAttributedCallToActionLabel];
    }
}

// Font
- (void)setPromptFont:(UIFont *)promptFont
{
    _promptFont = promptFont;
    self.promptLabel.font = promptFont;
}
- (void)setCallToActionFont:(UIFont *)callToActionFont
{
    _callToActionFont = callToActionFont;
    [self updateAttributedCallToActionLabel];
}

// Color
- (void)setPromptColor:(UIColor *)promptColor
{
    _promptColor = promptColor;
    self.promptLabel.textColor = _promptColor;
}

- (void)setCallToActionColor:(UIColor *)callToActionColor
{
    _callToActionColor = callToActionColor;
    [self updateAttributedCallToActionLabel];
}

// Attributed String
- (void)updateAttributedCallToActionLabel
{
    NSMutableDictionary *callToActionAttributes = [[NSMutableDictionary alloc] init];
    
    if (self.callToActionFont != nil)
    {
        [callToActionAttributes setObject:self.callToActionFont forKey:NSFontAttributeName];
    }
    if (self.callToActionColor != nil)
    {
        [callToActionAttributes setObject:self.callToActionColor forKey:NSForegroundColorAttributeName];
    }
    [callToActionAttributes setObject:@(NSUnderlineStyleSingle) forKey:NSUnderlineStyleAttributeName];

    NSAttributedString *attributedString;
    if (self.callToActionText != nil)
    {
        attributedString = [[NSAttributedString alloc] initWithString:self.callToActionText
                                                           attributes:callToActionAttributes];
    }
    
    self.callToActionLabel.attributedText = attributedString;
}

#pragma mark - UICollectionViewCell

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    self.alpha = highlighted ? 0.7f : 1.0f;
}

@end
