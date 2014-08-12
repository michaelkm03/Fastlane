//
//  VShareView.m
//  victorious
//
//  Created by Will Long on 8/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VShareView.h"

#import "VThemeManager.h"
#import "UIImage+ImageCreation.h"

@interface VShareView()

@property (nonatomic, strong) IBOutlet UIButton* shareButton;
@property (nonatomic, strong) IBOutlet UILabel* titleLabel;
@property (nonatomic, strong) IBOutlet UIImageView* iconImageView;

@end

@implementation VShareView

- (id)initWithTitle:(NSString*)title image:(UIImage*)image
{
    self = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] firstObject];
    if (self)
    {
        self.defaultColor = [UIColor colorWithRed:.6f green:.6f blue:.6f alpha:1.0f];
        self.selectedColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
        self.iconImageView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.titleLabel.text = title;
    }
    return self;
}

- (BOOL)selected
{
    return self.shareButton.selected;
}

- (void)setSelectedColor:(UIColor *)selectedColor
{
    _selectedColor = selectedColor;
    
    UIImage* image = [self.shareButton backgroundImageForState:UIControlStateSelected];
    [self.shareButton setBackgroundImage:[image vImageWithColor:selectedColor] forState:UIControlStateSelected];
    
    [self updateColors];
}

- (void)setDefaultColor:(UIColor *)defaultColor
{
    _defaultColor = defaultColor;
    
    UIImage* image = [self.shareButton backgroundImageForState:UIControlStateNormal];
    [self.shareButton setBackgroundImage:[image vImageWithColor:defaultColor] forState:UIControlStateNormal];
    
    [self updateColors];
}

- (void)updateColors
{
    UIColor* currentColor = self.shareButton.selected ? self.selectedColor : self.defaultColor;
    self.titleLabel.textColor = currentColor;
    self.iconImageView.tintColor = currentColor;
}

- (IBAction)pressedShareButton:(id)sender
{
    if (!self.selectionBlock)
        self.shareButton.selected = !self.shareButton.selected;
    else
        self.shareButton.selected = self.selectionBlock();
    
    [self updateColors];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel3Font];
}

@end
