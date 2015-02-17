//
//  VMemeVideoTool.m
//  victorious
//
//  Created by Michael Sena on 2/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VVideoSnapshotTool.h"
#import "VDependencyManager.h"

@interface VVideoSnapshotTool ()

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *previewImage;
@property (nonatomic, strong) NSURL *renderedMediaURL;

@end

@implementation VVideoSnapshotTool

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self)
    {
        self.title = [dependencyManager stringForKey:@"title"];
    }
    return self;
}

- (void)setMediaURL:(NSURL *)mediaURL
{
    //TODO: configureVCVideoPlayer
}

- (void)exportToURL:(NSURL *)url withCompletion:(void (^)(BOOL, UIImage *, NSError *))completion
{
}

- (NSURL *)mediaURL
{
    return self.renderedMediaURL;
}

@end
