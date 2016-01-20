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
#import "victorious-Swift.h"
#import "UIImageView+WebCache.h"
#import "CCHLinkTextViewDelegate.h"
#import "VHashtagSelectionResponder.h"
#import "VURLSelectionResponder.h"
#import "UIColor+VBrightness.h"
#import "VURLDetector.h"
#import "VTextPostCalloutHelper.h"

static const CGFloat kAnimationDuration = 0.35f;
static NSString * const kStandardBackgroundColorKey = @"color.standard.textPost";

@interface VTextPostViewController () <CCHLinkTextViewDelegate>

@property (nonatomic, weak) IBOutlet VTextPostTextView *textPostTextView;
@property (nonatomic, strong, readwrite) IBOutlet VTextPostViewModel *viewModel;
@property (nonatomic, strong) VTextBackgroundFrameMaker *textBackgroundFrameMaker;
@property (nonatomic, strong) VTextCalloutFormatter *textCalloutFormatter;
@property (nonatomic, weak, readwrite) IBOutlet UIImageView *backgroundImageView;

@property (nonatomic, strong) NSDictionary *calloutAttributes;
@property (nonatomic, strong) NSDictionary *attributes;

@property (nonatomic, strong) VTextPostCalloutHelper *calloutHelper;
@property (nonatomic, assign) CGRect lastFrame;

@end

@implementation VTextPostViewController

#pragma mark - Caches

+ (NSCache *)backgroundFramesCache
{
    static NSCache *backgroundFramesCache;
    if ( backgroundFramesCache == nil )
    {
        backgroundFramesCache = [[NSCache alloc] init];
    }
    return backgroundFramesCache;
}

- (void)updateCachedTextAttributes
{
    self.attributes = [self.viewModel textAttributesWithDependencyManager:_dependencyManager];
    self.calloutAttributes = [self.viewModel calloutAttributesWithDependencyManager:_dependencyManager];
}

#pragma mark - Dependencies and initializations

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSString *nibName = NSStringFromClass([self class]);
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    VTextPostViewController *viewController = [[VTextPostViewController alloc] initWithNibName:nibName bundle:bundle];
    viewController.dependencyManager = dependencyManager;
    return viewController;
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    
    [self updateCachedTextAttributes];
}

#pragma mark - View controller life cycle

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
    
    self.textPostTextView.accessibilityIdentifier = VAutomationIdentifierTextPostMainField;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if ( !CGRectEqualToRect( self.lastFrame, self.view.frame ) )
    {
        [self updateTextView];
    }
    self.lastFrame = self.view.frame;
}

#pragma mark - public

- (NSString *)text
{
    return self.textPostTextView.text;
}

- (void)setText:(NSString *)text
{
    if ( [self.textPostTextView.text isEqualToString:text] )
    {
        return;
    }
    
    self.textPostTextView.text = text;
    [self updateTextView];
}

- (void)setColor:(UIColor *)color
{
    _color = color;
    
    self.view.backgroundColor = _color ?: [self.dependencyManager colorForKey:kStandardBackgroundColorKey];
}

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    self.backgroundImageView.image = backgroundImage;
}

- (void)setImageURL:(NSURL *)imageURL
{
    [self setImageURL:imageURL animated:NO completion:nil];
}

- (void)setImageURL:(NSURL *)imageURL animated:(BOOL)animated completion:(void (^)(UIImage *))completion
{
    if ( _imageURL == imageURL )
    {
        if ( completion != nil )
        {
            completion(nil);
        }
        return;
    }
    
    _imageURL = imageURL;
    
    self.backgroundImageView.image = nil;
    self.backgroundImageView.alpha = 0.0f;
    
    void (^onImageLoaded)(UIImage *) = ^void(UIImage *image)
    {
        self.backgroundImageView.alpha = 1.0f;
        if ( completion != nil )
        {
            completion(image);
        }
    };
    
    [self.backgroundImageView sd_setImageWithURL:_imageURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
    {
        // Only fade in if there was a delay from downloading
        const BOOL wasDownloaded = cacheType == SDImageCacheTypeNone;
        if ( animated && wasDownloaded )
        {
            [UIView animateWithDuration:kAnimationDuration animations:^
            {
                onImageLoaded(image);
            }];
        }
        else
        {
            onImageLoaded(image);
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

#pragma mark -

- (VTextPostCalloutHelper *)calloutHelper
{
    if ( _calloutHelper == nil )
    {
        _calloutHelper = [[VTextPostCalloutHelper alloc] init];
    }
    return _calloutHelper;
}

- (void)updateTextView
{
    NSString *text = self.text;
    if ( text != nil )
    {
        [self updateTextView:self.textPostTextView
               calloutRanges:[self.calloutHelper calloutRangesForText:text]
              textAttributes:self.attributes
           calloutAttributes:self.calloutAttributes];
    }
}

- (void)overlayButtonTapped:(UIButton *)sender
{
    self.textView.selectedRange = NSMakeRange(0, 0);
}

- (void)updateTextIsSelectable
{
    self.textView.selectable = self.isTextSelectable;
}

- (void)updateTextView:(VTextPostTextView *)textPostTextView
         calloutRanges:(NSArray *)calloutRanges
        textAttributes:(NSDictionary *)textAttributes
     calloutAttributes:(NSDictionary *)calloutAttributes
{
    const BOOL wasSelected = textPostTextView.selectable;
    textPostTextView.selectable = YES;
    
    CGSize characterBounds = [@" " sizeWithAttributes:textAttributes];
    
    [self.textView.textStorage setAttributes:textAttributes range:NSMakeRange(0, textPostTextView.textStorage.length)];
    self.textView.tintColor = calloutAttributes[ NSForegroundColorAttributeName ];
    self.textView.linkTextTouchAttributes = @{ NSBackgroundColorAttributeName : [UIColor clearColor],
                                               NSForegroundColorAttributeName : [self.textView.tintColor v_colorDarkenedBy:0.25] };
    
    [self.textCalloutFormatter applyAttributes:calloutAttributes toText:textPostTextView.textStorage inCalloutRanges:calloutRanges];
    [self.textCalloutFormatter setKerning:self.viewModel.calloutWordKerning toText:textPostTextView.textStorage withCalloutRanges:calloutRanges];
    
    //This assures that the layout of the text will align with the text currently populate the text view
    [textPostTextView layoutIfNeeded];
    
    NSString *text = textPostTextView.textStorage.string;
    NSCache *cache = [[self class] backgroundFramesCache];
    NSString *cacheKey = [NSString stringWithFormat:@"%@ %@", text, NSStringFromCGRect( textPostTextView.frame )];
    NSArray *backgroundFrames = [cache objectForKey:cacheKey];
    if ( backgroundFrames == nil || text.length == 0 )
    {
        backgroundFrames = [self.textBackgroundFrameMaker createBackgroundFramesForTextView:textPostTextView
                                                                             characterWidth:characterBounds.width
                                                                        calloutRangeObjects:calloutRanges];
        [cache setObject:backgroundFrames forKey:cacheKey];
    }
    self.textView.backgroundFrames = backgroundFrames;
    self.textView.backgroundFrameColor = self.viewModel.backgroundColor;
    
    textPostTextView.selectable = wasSelected;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    [self updateTextView];
}

#pragma mark - CCHLinkTextViewDelegate

- (void)linkTextView:(CCHLinkTextView *)linkTextView didTapLinkWithValue:(id)value
{
    NSString *calloutText = (NSString *)value;
    if ( calloutText == nil || calloutText.length == 0 )
    {
        return;
    }
    
    NSDictionary *callouts = [self.calloutHelper calloutsForText:self.text];
    VTextPostCallout *callout = callouts[ calloutText ];
    if ( callout.type == VTextCalloutTypeHashtag )
    {
        [self hashtagSelected:calloutText];
    }
    else if ( callout.type == VTextCalloutTypeURL )
    {
        [self urlSelected:calloutText];
    }
}

#pragma mark - Handling tapped callouts

- (void)hashtagSelected:(NSString *)hashtag
{
    id target = [[self nextResponder] targetForAction:@selector(hashtagSelected:) withSender:self];
    if ( [target conformsToProtocol:@protocol(VHashtagSelectionResponder)] )
    {
        id<VHashtagSelectionResponder> responder = (id<VHashtagSelectionResponder>)target;
        [responder hashtagSelected:[hashtag substringFromIndex:1]];
    }
}

- (void)urlSelected:(NSString *)urlString
{
    id target = [[self nextResponder] targetForAction:@selector(URLSelected:) withSender:self];
    if ( [target conformsToProtocol:@protocol(VURLSelectionResponder)] )
    {
        id<VURLSelectionResponder> responder = (id<VURLSelectionResponder>)target;
        [responder URLSelected:[NSURL v_URLWithString:urlString defaultScheme:@"http"]];
    }
}

@end
