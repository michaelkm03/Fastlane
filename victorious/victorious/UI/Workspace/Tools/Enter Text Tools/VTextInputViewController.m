//
//  VTextInputViewController.m
//  victorious
//
//  Created by Patrick Lynch on 3/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTextInputViewController.h"
#import "VTextLayoutHelper.h"
#import "VTextBackgroundView.h"
#import "VDependencyManager.h"

@interface VTextInputViewController ()

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, weak) IBOutlet VTextLayoutHelper *textLayoutHelper;

@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, weak) IBOutlet VTextBackgroundView *backgroundView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *textContainerViewHeightConstraint;

@end

@implementation VTextInputViewController

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSString *nibName = NSStringFromClass([self class]);
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    VTextInputViewController *viewController = [[VTextInputViewController alloc] initWithNibName:nibName bundle:bundle];
    viewController.dependencyManager = dependencyManager;
    return viewController;
}

- (void)setText:(NSString *)text
{
    _text = text;
    
    NSDictionary *attributes = [self.textLayoutHelper textAttributesWithDependencyManager:self.dependencyManager];
    
    self.textView.attributedText = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    
    NSArray *textLines = [self.textLayoutHelper textLinesFromText:text
                                                   withAttributes:attributes
                                                         maxWidth:CGRectGetWidth(self.view.frame)-20];
    
    NSMutableArray *backgroundFrames = [[NSMutableArray alloc] init];
    NSUInteger y = 0;
    for ( NSString *line in textLines )
    {
        CGSize size = [line sizeWithAttributes:attributes];
        CGRect rect = CGRectMake( 0, 6 + (y++) * (size.height + 2), CGRectGetWidth(self.view.frame)-20, size.height );
        [backgroundFrames addObject:[NSValue valueWithCGRect:rect]];
    }
    
    self.backgroundView.backgroundFrames = backgroundFrames;
}

#pragma mark - Text Attributes

- (NSDictionary *)textAttributesWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.lineSpacing = 60.0f;
    
    return @{ NSFontAttributeName: [dependencyManager fontForKey:@"font.heading2"],
              NSForegroundColorAttributeName: [dependencyManager colorForKey:@"color.text.content"],
              NSParagraphStyleAttributeName : paragraphStyle };
}

- (NSDictionary *)hashtagTextAttributesWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.lineSpacing = 60.0f;
    
    return @{ NSFontAttributeName: [dependencyManager fontForKey:@"font.heading2"],
              NSForegroundColorAttributeName: [dependencyManager colorForKey:@"color.link"],
              NSParagraphStyleAttributeName : paragraphStyle };
}

@end
