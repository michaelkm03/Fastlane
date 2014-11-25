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

@interface VNoContentTableViewCell()

@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

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

#pragma mark - UITableViewCell life cycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self applyTheme];
    self.messageTextView.hidden = YES;
    self.activityIndicator.hidden = YES;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.messageTextView.hidden = YES;
    self.activityIndicator.hidden = YES;
}

#pragma mark - Public properties for configuration

- (void)setIsCentered:(BOOL)isCentered
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
}

- (NSString *)message
{
    return nil;
}

- (void)setIsLoading:(BOOL)isLoading
{
    if ( isLoading )
    {
        [self.activityIndicator startAnimating];
        self.messageTextView.hidden = YES;
        self.activityIndicator.hidden = NO;
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

#pragma mark - Theme

- (void)applyTheme
{
    CGFloat currentSize = self.messageTextView.font.pointSize;
    UIFont *font = [UIFont fontWithName:kVNoContentMessageFontName size:currentSize];
    self.messageTextView.font = font;
}

@end
