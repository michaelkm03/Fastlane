//
//  VLibraryFolderControl.m
//  victorious
//
//  Created by Michael Sena on 7/18/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VLibraryFolderControl.h"

@interface VLibraryFolderControl ()

@property (strong, nonatomic) IBOutlet UIView *animationContainer;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (strong, nonatomic) IBOutlet UIImageView *dropdownImageView;
@property (strong, nonatomic) IBOutlet UIView *centeringView;
@property (strong, nonatomic) IBOutlet UIImageView *dropdownArrow;
@property (strong, nonatomic) IBOutlet UIView *backgroundView;

@end

@implementation VLibraryFolderControl

+ (instancetype)newFolderControl
{
    NSBundle *bundleForClass = [NSBundle bundleForClass:self];
    UINib *nibForClass = [UINib nibWithNibName:NSStringFromClass(self) bundle:bundleForClass];
    NSArray *itemsInNib = [nibForClass instantiateWithOwner:nil options:nil];
    return [itemsInNib firstObject];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.backgroundView.layer.cornerRadius = 5;
    self.backgroundView.layer.masksToBounds = YES;
}

#pragma mark - Property Accessors

- (void)setAttributedTitle:(NSAttributedString *)attributedTitle
{
    _attributedTitle = attributedTitle;
    
    self.titleLabel.attributedText = _attributedTitle;
}

- (void)setAttributedSubtitle:(NSAttributedString *)attributedSubtitle
{
    _attributedSubtitle = attributedSubtitle;
    
    self.subtitleLabel.attributedText = _attributedSubtitle;
}

#pragma mark - UIControl

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    [self withAnimationDo:^
    {
        self.animationContainer.alpha = highlighted ? 0.7f : 1.0f;
        self.backgroundView.backgroundColor = highlighted ? [[UIColor whiteColor] colorWithAlphaComponent:0.5f] : [UIColor clearColor];
    }];
}

#pragma mark - Private Methods

- (void)withAnimationDo:(void (^)(void))animationBlock
{
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^
     {
         animationBlock();
     }
                     completion:nil];
}

@end
