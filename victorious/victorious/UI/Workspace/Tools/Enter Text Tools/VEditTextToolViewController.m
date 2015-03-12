//
//  VEditTextToolViewController.m
//  victorious
//
//  Created by Patrick Lynch on 3/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VEditTextToolViewController.h"
#import "VDependencyManager.h"

static const CGFloat kTextSpacingHorizontal = 4;
static const CGFloat kTextSpacingVertical = 2;

@interface VEditTextToolViewController ()

@property (nonatomic, weak) IBOutlet UIView *textContainerView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *textContainerViewHeightConstraint;

@property (nonatomic, weak) IBOutlet UIButton *buttonImageSearch;
@property (nonatomic, weak) IBOutlet UIButton *buttonCamera;

@property (nonatomic, strong) NSArray *textViews;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VEditTextToolViewController

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSString *nibName = NSStringFromClass([self class]);
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    VEditTextToolViewController *viewController = [[VEditTextToolViewController alloc] initWithNibName:nibName bundle:bundle];
    viewController.dependencyManager = dependencyManager;
    return viewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.buttonCamera.layer.cornerRadius = CGRectGetWidth(self.buttonCamera.frame) * 0.5;
    self.buttonCamera.backgroundColor = [self.dependencyManager colorForKey:@"color.link"];
    self.buttonImageSearch.layer.cornerRadius = CGRectGetWidth(self.buttonImageSearch.frame) * 0.5;
    self.buttonImageSearch.backgroundColor = [self.dependencyManager colorForKey:@"color.link"];
    
    [self updateLayout];
}

- (void)setText:(NSString *)text
{    _text = text;
    

    [self updateLayout];
}

- (void)setHashtagText:(NSString *)hashtagText
{
    _hashtagText = hashtagText;
    
    [self updateLayout];
}

- (void)updateLayout
{
    if ( self.textContainerView == nil )
    {
        return;
    }
    
    NSDictionary *textAttributes = [self textAttributesWithDependencyManager:self.dependencyManager];
    
    NSString *quotedText = [NSString stringWithFormat:@"\"%@\"", self.text];
    [self textLinesFromText:quotedText withAttributes:textAttributes inSuperview:self.textContainerView];
    
    NSArray *textLines = [self textLinesFromText:self.text
                                      withAttributes:textAttributes
                                     inSuperview:self.textContainerView];
    
    self.textViews = [self createTextFieldsFromTextLines:textLines
                                              attributes:textAttributes
                                               superview:self.textContainerView];
    
    if ( self.hashtagText != nil )
    {
        NSString *taggedText = [NSString stringWithFormat:@"#%@", self.hashtagText];
        NSDictionary *hashtagTextAttributes = [self hashtagTextAttributesWithDependencyManager:self.dependencyManager];
        [self updateHashtagLayoutWithText:taggedText
                                superview:self.textContainerView
                        bottmLineTextView:self.textViews.lastObject
                               attributes:hashtagTextAttributes];
    }
    
    if ( self.textContainerView.subviews.count > 0 )
    {
        NSArray *subviews = [self.textContainerView.subviews sortedArrayUsingComparator:^NSComparisonResult(UIView *viewA, UIView *viewB)
        {
            return [@(CGRectGetMaxY( viewA.frame )) compare:@(CGRectGetMaxY( viewB.frame ))];
        }];
        self.textContainerViewHeightConstraint.constant = CGRectGetMaxY(((UIView *)subviews.lastObject).frame);
    }
    [self.view layoutIfNeeded];
}

- (NSArray *)textLinesFromText:(NSString *)text
                withAttributes:(NSDictionary *)attributes
                   inSuperview:(UIView *)superview
{
    NSMutableArray *lines = [[NSMutableArray alloc] init];
    CGFloat maxWidth = (superview.frame.size.width - 10);
    NSMutableArray *allWords = [NSMutableArray arrayWithArray:[text componentsSeparatedByString:@" "]];
    
    while ( allWords.count > 0 )
    {
        NSMutableString *currentLine = [[NSMutableString alloc] init];
        while ( [[currentLine stringByAppendingFormat:@" %@", allWords.firstObject] sizeWithAttributes:attributes].width < maxWidth )
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
