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

@implementation VStreamViewCell

- (void)setSequence:(VSequence *)sequence
{
    _sequence = sequence;
    
    self.titleLabel.text = _sequence.name;
    self.dateLabel.text = [_sequence.releasedAt description];
    [self.previewImageView setImageWithURL:[NSURL URLWithString:_sequence.previewImage]
                             placeholderImage:[UIImage new]];
}

- (IBAction)pressedLike:(id)sender
{
    [[VObjectManager sharedManager] likeSequence:_sequence
                                    successBlock:^(NSArray *resultObjects) {
                                        self.likeButton.userInteractionEnabled = NO;
                                        self.dislikeButton.userInteractionEnabled = YES;
                                    }
                                       failBlock:^(NSError *error) {
                                           VLog(@"Like failed with error: %@", error);
                                       }];
}

- (IBAction)pressedDislike:(id)sender
{
    [[VObjectManager sharedManager] dislikeSequence:_sequence
                                    successBlock:^(NSArray *resultObjects) {
                                        self.dislikeButton.userInteractionEnabled = NO;
                                        self.likeButton.userInteractionEnabled = YES;
                                    }
                                       failBlock:^(NSError *error) {
                                           VLog(@"Like failed with error: %@", error);
                                       }];
}

- (IBAction)pressedShareToFacebook:(id)sender
{
    
}

//- (void)setSelected:(BOOL)selected animated:(BOOL)animated
//{
//    UIStoryboard *storyboard = [self.superview.navigationController storyboard];
//    
//    UIViewController *storyboardViewController = [storyboard instantiateViewControllerWithIdentifier:@"viewControllerId"];
//    
//    [self.navigationController pushViewController:storyboardViewController animated:YES];
//}
@end
