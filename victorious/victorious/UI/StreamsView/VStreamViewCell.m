//
//  VStreamViewCell.m
//  victoriOS
//
//  Created by David Keegan on 12/16/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VStreamViewCell.h"
#import "VSequence.h"
#import "VObjectManager+Sequence.h"
#import "TTTTimeIntervalFormatter.h"
#import "VThemeManager.h"

NSString* kStreamsWillSegueNotification = @"kStreamsWillSegueNotification";

@interface VStreamViewCell()

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;

@end

@implementation VStreamViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.usernameLabel.font = [[VThemeManager sharedThemeManager] themedFontForKeyPath:@"theme.font.stream.text.username"];
}

- (void)setSequence:(VSequence *)sequence
{
    if(_sequence == sequence)
    {
        return;
    }

    _sequence = sequence;

    static dispatch_once_t onceToken;
    static TTTTimeIntervalFormatter *timeIntervalFormatter;
    dispatch_once(&onceToken, ^{
        timeIntervalFormatter = [TTTTimeIntervalFormatter new];
        timeIntervalFormatter.usesAbbreviatedCalendarUnits = YES;
        timeIntervalFormatter.pastDeicticExpression = @"";
        timeIntervalFormatter.deicticExpressionFormat = NSLocalizedString(@"%@%@", @"Time format {time}{<null>}");
    });

    self.descriptionLabel.text = self.sequence.name;
    self.dateLabel.text = [timeIntervalFormatter stringForTimeInterval:[self.sequence.releasedAt timeIntervalSinceNow]];
    [self.previewImageView setImageWithURL:[NSURL URLWithString:_sequence.previewImage]
                             placeholderImage:[UIImage new]];
}

- (IBAction)likeButtonAction:(id)sender
{
    [[VObjectManager sharedManager]
     likeSequence:self.sequence
     successBlock:^(NSArray *resultObjects)
     {
         self.likeButton.userInteractionEnabled = NO;
         self.dislikeButton.userInteractionEnabled = YES;
     }
     failBlock:^(NSError *error)
     {
         VLog(@"Like failed with error: %@", error);
     }];
}

- (IBAction)commentButtonAction:(id)sender
{

}

- (IBAction)shareButtonAction:(id)sender
{
    
}


@end
