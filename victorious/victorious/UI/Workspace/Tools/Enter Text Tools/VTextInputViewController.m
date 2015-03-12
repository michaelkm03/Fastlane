//
//  VTextInputViewController.m
//  victorious
//
//  Created by Patrick Lynch on 3/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTextInputViewController.h"
#import "VTextLayoutHelper.h"

@interface VTextInputViewController ()

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, weak) IBOutlet VTextLayoutHelper *textLayoutHelper;

@property (nonatomic, weak) IBOutlet UIView *textContainerView;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.text = @"Always plan a backup outfit for important events in your life.";
    
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
    [self.textLayoutHelper textLinesFromText:quotedText withAttributes:textAttributes inSuperview:self.textContainerView];
    
    NSArray *textLines = [self.textLayoutHelper textLinesFromText:self.text
                                                   withAttributes:textAttributes
                                                      inSuperview:self.textContainerView];
    
    [self.textLayoutHelper createTextFieldsFromTextLines:textLines
                                              attributes:textAttributes
                                               superview:self.textContainerView];
    
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
