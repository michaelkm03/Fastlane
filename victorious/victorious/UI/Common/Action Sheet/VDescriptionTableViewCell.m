//
//  VDescriptionTableViewCell.m
//  victorious
//
//  Created by Michael Sena on 9/26/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDescriptionTableViewCell.h"

// Hashtags
#import "VHashTags.h"

// Theme
#import "VThemeManager.h"

@interface VDescriptionTableViewCell () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;

@end

static const UIEdgeInsets kTextInsets        = { 12.0f, 30.0f, 13.0f, 30.0f};

@implementation VDescriptionTableViewCell

#pragma mark - Sizing

+ (CGFloat)desiredHeightWithTableViewWidth:(CGFloat)width
                                      text:(NSString *)text
{
    CGRect boundingRect = [text boundingRectWithSize:CGSizeMake(width - kTextInsets.left - kTextInsets.right, 999.0f)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:[self attributesForText]
                                             context:[[NSStringDrawingContext alloc] init]];
    
    return ceilf(CGRectGetHeight(boundingRect) + kTextInsets.top + kTextInsets.bottom);
}

#pragma mark - NSObject

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.descriptionTextView.textContainerInset = UIEdgeInsetsZero;
    self.descriptionTextView.delegate = self;
    self.descriptionTextView.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
}

#pragma mark - Property Accessors

- (void)setDescriptionText:(NSString *)descriptionText
{
    _descriptionText = [descriptionText copy];
    self.descriptionLabel.text = _descriptionText;
    
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:_descriptionText
                                                                                                attributes:[[self class] attributesForText]];
    NSArray *hashTagLocations = [VHashTags detectHashTags:mutableAttributedString.string];
    [VHashTags formatHashTagsInString:mutableAttributedString
                        withTagRanges:hashTagLocations
                           attributes:@{
                                        NSLinkAttributeName:[NSURL URLWithString:@"www.google.com"]
                                        }];
    
    self.descriptionTextView.attributedText = mutableAttributedString;
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    if (self.hashTagSelectionBlock)
    {
        NSString *selectedHashTag = [textView.text substringWithRange:characterRange];
        selectedHashTag = [selectedHashTag stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"#"]];
        self.hashTagSelectionBlock(selectedHashTag);
    }
    return NO;
}

#pragma mark - Internal Methods

+ (NSDictionary *)attributesForText
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    return @{NSFontAttributeName:[[VThemeManager sharedThemeManager] themedFontForKey:kVParagraphFont],
             NSParagraphStyleAttributeName:paragraphStyle};
}

@end
