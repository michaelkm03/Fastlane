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

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *imageViews;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labels;

@end

@implementation VStreamViewCell

- (void)awakeFromNib{
    [super awakeFromNib];

    [[UIImageView appearanceWhenContainedIn:[self class], nil]
     setTintColor:[[VThemeManager sharedThemeManager] themedColorForKey:kVStreamCellIconColor]];
    [self.imageViews enumerateObjectsUsingBlock:^(UIImageView *imageView, NSUInteger idx, BOOL *stop){
        imageView.image = [imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }];
    [self.labels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop){
        label.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVStreamCellTextFont];
        label.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVStreamCellTextColor];
    }];
}

- (void)setSequence:(VSequence *)sequence
{
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

//- (IBAction)pressedLike:(id)sender
//{
//    [[VObjectManager sharedManager] likeSequence:_sequence
//                                    successBlock:^(NSArray *resultObjects) {
//                                        self.likeButton.userInteractionEnabled = NO;
//                                        self.dislikeButton.userInteractionEnabled = YES;
//                                    }
//                                       failBlock:^(NSError *error) {
//                                           VLog(@"Like failed with error: %@", error);
//                                       }];
//}

//- (IBAction)pressedDislike:(id)sender
//{
//    [[VObjectManager sharedManager] dislikeSequence:_sequence
//                                    successBlock:^(NSArray *resultObjects) {
//                                        self.dislikeButton.userInteractionEnabled = NO;
//                                        self.likeButton.userInteractionEnabled = YES;
//                                    }
//                                       failBlock:^(NSError *error) {
//                                           VLog(@"Like failed with error: %@", error);
//                                       }];
//}

//- (IBAction)pressedShareToFacebook:(id)sender
//{
//    
//}

//- (void)setSelected:(BOOL)selected animated:(BOOL)animated
//{
//    UIStoryboard *storyboard = [self.superview.navigationController storyboard];
//    
//    UIViewController *storyboardViewController = [storyboard instantiateViewControllerWithIdentifier:@"viewControllerId"];
//    
//    [self.navigationController pushViewController:storyboardViewController animated:YES];
//}

@end
