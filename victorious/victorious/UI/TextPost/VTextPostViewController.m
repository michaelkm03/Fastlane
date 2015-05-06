//
//  VTextPostViewController.m
//  victorious
//
//  Created by Patrick Lynch on 3/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTextPostViewController.h"
#import "VDependencyManager.h"
#import "VTextPostTextView.h"
#import "VTextPostViewModel.h"
#import "VHashTags.h"
#import "victorious-Swift.h" // For VTextPostBackgroundLayout
#import <SDWebImageManager.h>
#import "CCHLinkTextViewDelegate.h"
#import "VLinkSelectionResponder.h"
#import "UIColor+VBrightness.h"

@interface VTextPostViewController () <CCHLinkTextViewDelegate>

@property (nonatomic, assign) BOOL hasBeenDisplayed;

@property (nonatomic, weak) IBOutlet VTextPostTextView *textPostTextView;
@property (nonatomic, strong, readwrite) IBOutlet VTextPostViewModel *viewModel;
@property (nonatomic, strong) VTextBackgroundFrameMaker *textBackgroundFrameMaker;
@property (nonatomic, strong) VTextCalloutFormatter *textCalloutFormatter;
@property (nonatomic, weak, readwrite) IBOutlet UIImageView *backgroundImageView;

@property (nonatomic, strong) NSDictionary *calloutAttributes;
@property (nonatomic, strong) NSDictionary *attributes;

@end

@implementation VTextPostViewController

#pragma mark - Initializations

+ (NSCache *)backgroundFramesCache
{
    static NSCache *backgroundFramesCache;
    if ( backgroundFramesCache == nil )
    {
        backgroundFramesCache = [[NSCache alloc] init];
    }
    return backgroundFramesCache;
}

+ (NSCache *)calloutRangesCache
{
    static NSCache *calloutRangesCache;
    if ( calloutRangesCache == nil )
    {
        calloutRangesCache = [[NSCache alloc] init];
    }
    return calloutRangesCache;
}

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSString *nibName = NSStringFromClass([self class]);
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    VTextPostViewController *viewController = [[VTextPostViewController alloc] initWithNibName:nibName bundle:bundle];
    viewController.dependencyManager = dependencyManager;
    return viewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateCachedTextAttributes];
    
    self.textBackgroundFrameMaker = [[VTextBackgroundFrameMaker alloc] init];
    self.textCalloutFormatter = [[VTextCalloutFormatter alloc] init];
    
    self.textView.linkDelegate = self;
    self.textView.text = @"";
    self.textView.selectable = NO;
    
    [self updateTextIsSelectable];
    [self updateTextView];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if ( !self.hasBeenDisplayed )
    {
        self.hasBeenDisplayed = YES;
        [self updateTextView];
    }
}

- (void)updateCachedTextAttributes
{
    self.attributes = [self.viewModel textAttributesWithDependencyManager:_dependencyManager];
    self.calloutAttributes = [self.viewModel calloutAttributesWithDependencyManager:_dependencyManager];
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    
    [self updateCachedTextAttributes];
}

- (void)overlayButtonTapped:(UIButton *)sender
{
    self.textView.selectedRange = NSMakeRange(0, 0);
}

- (void)setText:(NSString *)text
{
    if ( [_text isEqualToString:text] )
    {
        return;
    }
    
    _text = text;
    [self updateTextView];
}

- (void)updateTextView
{
    if ( self.text == nil )
    {
        return;
    }
    
    NSCache *cache = [[self class] calloutRangesCache];
    NSArray *calloutRanges = [cache objectForKey:self.text];
    if ( calloutRanges == nil )
    {
        calloutRanges = [VHashTags detectHashTags:self.text includeHashSymbol:YES];
        [cache setObject:calloutRanges forKey:self.text];
    }
    
    [self updateTextView:self.textPostTextView
                withText:self.text
           calloutRanges:calloutRanges
          textAttributes:self.attributes
       calloutAttributes:self.calloutAttributes];
}

#pragma mark - public

- (void)setColor:(UIColor *)color
{
    _color = color;
    
    self.view.backgroundColor = _color ?: [self.dependencyManager colorForKey:VDependencyManagerAccentColorKey];
}

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    _backgroundImage = backgroundImage;
    
    self.backgroundImageView.image = backgroundImage;
}

- (void)setImageURL:(NSURL *)imageURL
{
    if ( _imageURL == imageURL && imageURL != nil )
    {
        return;
    }
    
    _imageURL = imageURL;
    
    [[SDWebImageManager sharedManager] downloadImageWithURL:imageURL
                          options:0
                         progress:nil
                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL)
     {
         if ( image != nil )
         {
             self.backgroundImage = image;
         }
     }];
}

- (VTextPostTextView *)textView
{
    return self.textPostTextView;
}

- (void)setIsTextSelectable:(BOOL)isTextSelectable
{
    _isTextSelectable = isTextSelectable;
    
    [self updateTextIsSelectable];
}

- (void)updateTextIsSelectable
{
    self.textView.selectable = self.isTextSelectable;
}

- (void)updateTextView:(VTextPostTextView *)textPostTextView
              withText:(NSString *)text
         calloutRanges:(NSArray *)calloutRanges
        textAttributes:(NSDictionary *)textAttributes
     calloutAttributes:(NSDictionary *)calloutAttributes
{
    if ( text == nil )
    {
        return;
    }
    
    const BOOL wasSelected = textPostTextView.selectable;
    textPostTextView.selectable = YES;
    
    textPostTextView.attributedText = [[NSAttributedString alloc] initWithString:@" " attributes:textAttributes];
    textPostTextView.textContainer.size = CGSizeMake( textPostTextView.bounds.size.width, CGFLOAT_MAX );
    NSRange range = { 0, 1 };
    CGRect characterBounds = [textPostTextView.layoutManager boundingRectForGlyphRange:range inTextContainer:textPostTextView.textContainer];
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text attributes:textAttributes];
    textPostTextView.attributedText = attributedText;
    
    self.textView.tintColor = calloutAttributes[ NSForegroundColorAttributeName ];
    self.textView.linkTextTouchAttributes = @{ NSBackgroundColorAttributeName : [UIColor clearColor],
                                               NSForegroundColorAttributeName : [self.textView.tintColor v_colorDarkenedBy:0.25] };
    
    [self.textCalloutFormatter applyAttributes:calloutAttributes toText:attributedText inCalloutRanges:calloutRanges];
    [self.textCalloutFormatter setKerning:self.viewModel.calloutWordKerning toText:attributedText withCalloutRanges:calloutRanges];
    textPostTextView.attributedText = [[NSAttributedString alloc] initWithAttributedString:attributedText];
    
    NSCache *cache = [[self class] backgroundFramesCache];
    NSString *cacheKey = [NSString stringWithFormat:@"%@ %@", text, NSStringFromCGRect( textPostTextView.frame )];
    NSArray *backgroundFrames = [cache objectForKey:cacheKey];
    if ( backgroundFrames == nil || text.length == 0 )
    {
        backgroundFrames = [self.textBackgroundFrameMaker createBackgroundFramesForTextView:textPostTextView
                                                                             characterWidth:characterBounds.size.width
                                                                        calloutRangeObjects:calloutRanges];
        [cache setObject:backgroundFrames forKey:cacheKey];
    }
    self.textView.backgroundFrames = backgroundFrames;
    self.textView.backgroundFrameColor = self.viewModel.backgroundColor;
    
    textPostTextView.selectable = wasSelected;
}

#pragma mark - CCHLinkTextViewDelegate

- (void)linkTextView:(CCHLinkTextView *)linkTextView didTapLinkWithValue:(id)value
{
    NSString *calloutText = (NSString *)value;
    calloutText = [VHashTags stringByRemovingPrependingHashmarkFromString:calloutText];
    if ( calloutText == nil || calloutText.length == 0 )
    {
        return;
    }
    
    id target = [self targetForAction:@selector(linkWithTextSelected:) withSender:self];
    if ( [target conformsToProtocol:@protocol(VLinkSelectionResponder)] )
    {
        id<VLinkSelectionResponder> responder = (id<VLinkSelectionResponder>)target;
        [responder linkWithTextSelected:calloutText];
    }
}

@end
