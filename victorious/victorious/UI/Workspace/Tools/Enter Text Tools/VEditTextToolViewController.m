//
//  VEditTextToolViewController.m
//  victorious
//
//  Created by Patrick Lynch on 3/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VEditTextToolViewController.h"
#import "VDependencyManager.h"
#import "VTextLayoutHelper.h"

@interface VEditTextToolViewController ()

@property (nonatomic, weak) IBOutlet UIView *textContainerView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *textContainerViewHeightConstraint;

@property (nonatomic, weak) IBOutlet UIButton *buttonImageSearch;
@property (nonatomic, weak) IBOutlet UIButton *buttonCamera;

@property (nonatomic, weak) IBOutlet VTextLayoutHelper *textLayoutHelper;

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
    
    NSDictionary *textAttributes = [self.textLayoutHelper textAttributesWithDependencyManager:self.dependencyManager];
    
    NSString *quotedText = [NSString stringWithFormat:@"\"%@\"", self.text];
    [self.textLayoutHelper textLinesFromText:quotedText withAttributes:textAttributes
                                    maxWidth:CGRectGetWidth(self.textContainerView.frame)];
    
    NSArray *textLines = [self.textLayoutHelper textLinesFromText:self.text
                                                   withAttributes:textAttributes
                                                         maxWidth:CGRectGetWidth(self.textContainerView.frame)];
    
    NSArray *textViews = [self.textLayoutHelper createTextFieldsFromTextLines:textLines
                                                                   attributes:textAttributes
                                                                    superview:self.textContainerView];
    
    if ( self.hashtagText != nil )
    {
        NSString *taggedText = [NSString stringWithFormat:@"#%@", self.hashtagText];
        NSDictionary *hashtagTextAttributes = [self.textLayoutHelper hashtagTextAttributesWithDependencyManager:self.dependencyManager];
        [self.textLayoutHelper updateHashtagLayoutWithText:taggedText
                                superview:self.textContainerView
                        bottmLineTextView:textViews.lastObject
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

@end
