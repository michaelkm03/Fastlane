//
//  VTemplateDownloadManager.h
//  victorious
//
//  Created by Josh Hinman on 4/25/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 A block that will be called when the
 template finishes downloading.
 
 @param templateData Raw data that can be deserialized into a template dictionary.
 @param error If the download fails, this parameter describes the error
 */
typedef void (^VTemplateDownloaderCompletion)(NSData *templateData, NSError *error);

@protocol VTemplateDownloader <NSObject>

/**
 Contacts the server and downloads the latest template. 
 The completion block may be called on any thread.
 */
- (void)downloadTemplateWithCompletion:(VTemplateDownloaderCompletion)completion;

@end

typedef void (^VTemplateLoadCompletion)(NSDictionary *templateConfiguration);

/**
 Provides a fresh, piping-hot template straight off the wire
 when available, otherwise falls back on the most recently
 downloaded template. If no template has ever been downloaded,
 this class will provide one that was included in the app
 bundle.
 */
@interface VTemplateDownloadManager : NSObject

/**
 The location on disk where the most recently
 downloaded template will be stored.
 */
@property (nonatomic, copy) NSURL *templateCacheFileLocation;

/**
 The location within the app bundle where a last-
 resort copy of the template can be found.
 */
@property (nonatomic, copy) NSURL *templateLocationInBundle;

/**
 The downloader that was provided at initialization time
 */
@property (nonatomic, readonly) id<VTemplateDownloader> downloader;

/**
 The manager will give the downloader this much time 
 to do its thing before moving on to cached options.
 */
@property (nonatomic) NSTimeInterval timeout;

/**
 Initializes a new template download manager with a downloader
 */
- (instancetype)initWithDownloader:(id<VTemplateDownloader>)downloader NS_DESIGNATED_INITIALIZER;

/**
 Loads this app's template. The completion block 
 will be called on an arbitrary thread.
 */
- (void)loadTemplateWithCompletion:(VTemplateLoadCompletion)completion;

@end
