//
//  VContentViewViewModel.h
//  victorious
//
//  Created by Michael Sena on 9/15/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSequence.h"

#import "VNode.h"

/**
 *  An enumeration of the various content types supported by VContentViewModel.
 */
typedef NS_ENUM(NSInteger, VContentViewType)
{
    /**
     *  Invalid content type,
     */
    VContentViewTypeInvalid,
    /**
     *  Image content type.
     */
    VContentViewTypeImage,
    /**
     *  Video content type.
     */
    VContentViewTypeVideo,
    /**
     *  Poll content type.
     */
    VContentViewTypePoll
};

@interface VContentViewViewModel : NSObject

/**
 *  The designated initializer for VContentViewViewModel. Will interrogate the sequence object for content type and prepare for a contentView to be displayed.
 *
 *  @param sequence The sequence that this viewModel corresponds to.
 *
 *  @return An initialized VContentViewModel.
 */
- (instancetype)initWithSequence:(VSequence *)sequence;

/**
 *  The corresponding sequence for this view model.
 */
@property (nonatomic, strong, readonly) VSequence *sequence;

/**
 *  The type of asset we are currently viewing.
 */
@property (nonatomic, assign, readonly) VContentViewType type;

/**
 *  For content type image this will be a convenient url request for setting the image.
 */
@property (nonatomic, readonly) NSURLRequest *imageURLRequest;

/**
 *  For content type video this will be a convenient url for the videoplayer.
 */
@property (nonatomic, readonly) NSURL *videoURL;

/**
 *  If a video content has any real time comments this will be YES.
 */
@property (nonatomic, readonly) BOOL shouldShowRealTimeComents;

@end
