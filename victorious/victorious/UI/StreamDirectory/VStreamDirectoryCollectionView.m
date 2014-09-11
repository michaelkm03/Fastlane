//
//  VStreamDirectoryCollectionView.m
//  victorious
//
//  Created by Will Long on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamDirectoryCollectionView.h"

NSString * const kStreamDirectoryStoryboardId = @"kStreamDirectory";

@interface VStreamDirectoryCollectionView ()

@property (nonatomic, strong) VDirectory* directory;

@end


@implementation VStreamDirectoryCollectionView

+ (instancetype)streamDirectoryForDirectory:(VDirectory*)directory
{
    UIViewController*   currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    VStreamDirectoryCollectionView* streamDirectory = (VStreamDirectoryCollectionView*)[currentViewController.storyboard instantiateViewControllerWithIdentifier: kStreamDirectoryStoryboardId];
    streamDirectory.directory = directory;
    
    return streamDirectory;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
