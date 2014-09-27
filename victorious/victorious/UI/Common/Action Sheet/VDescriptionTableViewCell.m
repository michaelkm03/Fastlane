//
//  VDescriptionTableViewCell.m
//  victorious
//
//  Created by Michael Sena on 9/26/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDescriptionTableViewCell.h"

// Theme
#import "VThemeManager.h"

@interface VDescriptionTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

static const UIEdgeInsets kTextInsets        = { 11.0f, 30.0f, 12.0f, 30.0f};

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
    
    self.descriptionLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVParagraphFont];
}

#pragma mark - Property Accessors

- (void)setDescriptionText:(NSString *)descriptionText
{
    _descriptionText = [descriptionText copy];
    self.descriptionLabel.text = _descriptionText;
}

#pragma mark - Internal Methods

+ (NSDictionary *)attributesForText
{
    return @{NSFontAttributeName:[[VThemeManager sharedThemeManager] themedFontForKey:kVParagraphFont]};
}

@end
