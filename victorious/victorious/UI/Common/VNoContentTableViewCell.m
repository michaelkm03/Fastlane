//
//  VNoContentTableViewCell.m
//  victorious
//
//  Created by Patrick Lynch on 10/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VNoContentTableViewCell.h"
#import "VThemeManager.h"

static NSString *const kVNoContentTableViewCellIdentifier   = @"VNoContentTableViewCell";
static NSString *const kVNoContentMessageFontName           = @"Helvetica Neue Light Italic";
static const UIEdgeInsets kTextViewMargins = { 10.0f, 10.0f, 62.0f, 10.0f };

@interface VNoContentTableViewCell()

@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionButtonHeightConstraint;
@property (nonatomic, assign) CGFloat actionButtonVisibleHeight;
@property (nonatomic, weak) void (^actionButtonBlock)(void);

@end

@implementation VNoContentTableViewCell

#pragma mark - Initialization

+ (VNoContentTableViewCell *)createCellFromTableView:(UITableView *)tableView
{
    return [tableView dequeueReusableCellWithIdentifier:kVNoContentTableViewCellIdentifier];
}

+ (void)registerNibWithTableView:(UITableView *)tableView
{
    [tableView registerNib:[UINib nibWithNibName:kVNoContentTableViewCellIdentifier bundle:nil] forCellReuseIdentifier:kVNoContentTableViewCellIdentifier];
}

/**
 Creates and returns a sample cell that can be used to calculate sizing
 */
+ (VNoContentTableViewCell *)sampleCellForSizing
{
    static VNoContentTableViewCell *cell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void)
    {
        UINib *nib = [UINib nibWithNibName:kVNoContentTableViewCellIdentifier bundle:[NSBundle bundleForClass:self]];
        NSArray *objects = [nib instantiateWithOwner:nil options:nil];
        for (id object in objects)
        {
            if ([object isKindOfClass:self])
            {
                cell = object;
                return;
            }
        }
    });
    return cell;
}

#pragma mark - UITableViewCell life cycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.messageTextView.hidden = YES;
    self.activityIndicator.hidden = YES;
    self.actionButtonVisibleHeight = self.actionButtonHeightConstraint.constant;
    [self.actionButton setTitle:@"" forState:UIControlStateNormal];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.userInteractionEnabled = YES;
    self.messageTextView.textContainerInset = UIEdgeInsetsZero;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.messageTextView.hidden = YES;
    self.activityIndicator.hidden = YES;
}

#pragma mark - Public properties for configuration

- (void)setCentered:(BOOL)isCentered
{
    self.messageTextView.textAlignment = isCentered ? NSTextAlignmentCenter : NSTextAlignmentLeft;
}

- (BOOL)isCentered
{
    return self.messageTextView.textAlignment == NSTextAlignmentCenter;
}

- (void)setMessage:(NSString *)message
{
    self.messageTextView.text = message;
    self.messageTextView.hidden = NO;
    self.activityIndicator.hidden = YES;
    [self hideActionButton];
    
    CGFloat currentSize = self.messageTextView.font.pointSize;
    UIFont *font = [UIFont fontWithName:kVNoContentMessageFontName size:currentSize];
    self.messageTextView.font = font;
}

- (void)setIsLoading:(BOOL)isLoading
{
    if ( isLoading )
    {
        [self.activityIndicator startAnimating];
        self.messageTextView.hidden = YES;
        self.activityIndicator.hidden = NO;
        [self hideActionButton];
    }
    else
    {
        self.activityIndicator.hidden = YES;
    }
}

- (BOOL)isLoading
{
    return self.activityIndicator.hidden = NO;
}

#pragma mark - Action button

- (void)hideActionButton
{
    self.actionButtonHeightConstraint.constant = 0.0;
    [self setNeedsLayout];
}

- (void)showActionButton
{
    self.actionButtonHeightConstraint.constant = self.actionButtonVisibleHeight;
    [self setNeedsLayout];
}

- (void)showActionButtonWithLabel:(NSString *)label callback:(void(^)(void))callback
{
    [self.actionButton setTitle:label forState:UIControlStateNormal];
    self.actionButtonBlock = callback;
    
    self.actionButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    UIFont *buttonFont = [[VThemeManager sharedThemeManager] themedFontForKey:kVButton2Font];
    [self.actionButton.titleLabel setFont:buttonFont];
    
    [self showActionButton];
}

- (IBAction)onAction:(id)sender
{
    if ( self.actionButtonBlock != nil )
    {
        self.actionButtonBlock();
    }
}

#pragma mark - Sizing

+ (CGFloat)heightWithMessage:(NSString *)message andWidth:(CGFloat)width
{
    VNoContentTableViewCell *sizingCell = [self sampleCellForSizing];
    CGFloat fontSize = sizingCell.messageTextView.font.pointSize;
    UIFont *font = [UIFont fontWithName:kVNoContentMessageFontName size:fontSize];
    
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    context.minimumScaleFactor = sizingCell.messageTextView.minimumZoomScale;
    
    CGFloat textViewWidth = width - kTextViewMargins.left - kTextViewMargins.right;
    CGRect textRect = [message boundingRectWithSize:CGSizeMake(textViewWidth, CGFLOAT_MAX)
                                             options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                          attributes:@{ NSFontAttributeName: font }
                                             context:context];
    return VCEIL(CGRectGetHeight(textRect) + kTextViewMargins.top + kTextViewMargins.bottom);
}

@end
