//
//  VInStreamCommentsShowMoreCell.m
//  victorious
//
//  Created by Sharif Ahmed on 7/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VInStreamCommentsShowMoreCell.h"
#import <CCHLinkTextView/CCHLinkTextView.h>
#import "VInStreamCommentsShowMoreAttributes.h"

static UIEdgeInsets const kPromptInsets = { 0.0f, 0.0f, 0.0f, 0.0f };
static NSString * const kPromptTextLocalizedStringKey = @"View Previous Comments";

@interface VInStreamCommentsShowMoreCell ()

@property (nonatomic, weak) IBOutlet CCHLinkTextView *promptTextView;
@property (nonatomic, readwrite) VInStreamCommentsShowMoreAttributes *attributes;

@end

@implementation VInStreamCommentsShowMoreCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.promptTextView.contentInset = UIEdgeInsetsZero;
    self.promptTextView.textContainerInset = UIEdgeInsetsZero;
    self.promptTextView.textContainer.lineFragmentPadding = 0.0f;
    self.promptTextView.text = NSLocalizedString(kPromptTextLocalizedStringKey, nil);
}

- (void)setupWithAttributes:(VInStreamCommentsShowMoreAttributes *)attributes andLinkDelegate:(id <CCHLinkTextViewDelegate>)linkDelegate
{
    self.attributes = attributes;
    self.promptTextView.linkDelegate = linkDelegate;
}

- (void)setAttributes:(VInStreamCommentsShowMoreAttributes *)attributes
{
    BOOL attributesChanged = ![_attributes isEqual:attributes];
    _attributes = attributes;
    if ( attributesChanged )
    {
        NSMutableDictionary *linkAttributes = [attributes.unselectedTextAttributes mutableCopy];
        [linkAttributes addEntriesFromDictionary:@{ CCHLinkAttributeName : @"" }];
        self.promptTextView.linkTextAttributes = linkAttributes;
        self.promptTextView.linkTextTouchAttributes = attributes.selectedTextAttributes;
        self.promptTextView.attributedText = [[NSAttributedString alloc] initWithString:self.promptTextView.text attributes:linkAttributes];
    }
}

+ (CGFloat)desiredHeightForAttributes:(VInStreamCommentsShowMoreAttributes *)attributes withMaxWidth:(CGFloat)width
{
    CGFloat maxWidth = width - kPromptInsets.left - kPromptInsets.right;
    NSAttributedString *promptAttributedString = [[NSAttributedString alloc] initWithString:NSLocalizedString(kPromptTextLocalizedStringKey, nil) attributes:attributes.unselectedTextAttributes];
    CGFloat height = VCEIL([promptAttributedString boundingRectWithSize:CGSizeMake(width, maxWidth)
                                                                options:NSStringDrawingUsesLineFragmentOrigin
                                                                context:nil].size.height);
    height += kPromptInsets.bottom + kPromptInsets.top;
    return height;
}

@end
