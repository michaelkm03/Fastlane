//
//  VRepostButtonController.h
//  victorious
//
//  Created by Michael Sena on 4/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VSequence;

/**
 *  VRepostButtonController manages a repost button associated with a given sequence.
 *  The sequence will be observed (using KVO) for changes to its hasReposted property.
 *  When these changes occur it will manage enabling/disabling the button along with 
 *  the ensuring that the image on the button is correct.
 *
 *  The button will become disabled when the hasReposted property of sequence is true.
 */
@interface VRepostButtonController : NSObject

/**
 *  The designated initializer for this class. You must use this to use this class. 
 *  Other than the repostButton all other parameters are retained.
 *
 *  @param sequenceToObserve A valid sequence object to observe hasReposted on.
 *  @param repostButton A UIButton representing this sequence's repost state. Note, 
 *  repostButton is not retained it must be in the view hierarchy or retained elsewhere 
 *  for this class to work.
 *  @param repostedImage An image for the reposted state.
 *  @param unRepostedImage An image for the unreposted state.
 */
- (instancetype)initWithSequence:(VSequence *)sequenceToObserve
                    repostButton:(UIButton *)repostButton
                   repostedImage:(UIImage *)repostedImage
                 unRepostedImage:(UIImage *)unRepostedImage;

/**
 *  Set this to YES to force the button to a disabled state. Note, the image will still 
 *  stay unReposted as long as hasReposted is false.
 */
@property (nonatomic, assign) BOOL reposting;

/**
 *  @abstract Use this to cleanup any KVO.
 *
 *  @description Unusable after this point.
 *
 */
- (void)invalidate;

@end
