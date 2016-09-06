//
//  VTemplateDownloadOperation.h
//  victorious
//
//  Created by Josh Hinman on 4/25/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 A block that will be called when the
 template finishes downloading.
 
 @param templateData Raw data that can be deserialized into a template dictionary.
 @param error If the download fails, this parameter describes the error
 */
typedef void (^VTemplateDownloaderCompletion)(NSData *__nullable templateData, NSError *__nullable error);

/**
 Objects conforming to this protocol are capable 
 of loading template data from a server.
 */
@protocol VTemplateDownloader <NSObject>

/**
 Contacts the server and downloads the latest template. 
 The completion block may be called on any thread.
 */
- (void)downloadTemplateWithCompletion:(VTemplateDownloaderCompletion)completion;

@end

#pragma mark -

@class TemplateCache;
@class VDataCache;

/**
 Provides a fresh, piping-hot template straight off the wire
 when available, otherwise falls back on the most recently
 downloaded template. If no template has ever been downloaded,
 this class will provide one that was included in the app
 bundle.
 */
@interface VTemplateDownloadOperation : NSOperation

/**
 An instance of VDataCache used for caching images found in the template.
 If this is not set, there is a suitable default that will be used.
 */
@property (nonatomic, strong) VDataCache *dataCache;

/**
 An instance of TemplateCache that will be used
 to store the downloaded template data.
 */
@property (nonatomic, strong, nullable) TemplateCache *templateCache;

/**
 The downloader that was provided at initialization time
 */
@property (nonatomic, readonly) id<VTemplateDownloader> downloader;

/**
 The manager will give the downloader this much time 
 to do its thing before moving on to cached options.
 */
@property (nonatomic) NSTimeInterval templateDownloadTimeout;

/**
 The manager will allow for this much time to download
 referenced images within the template. Typically this
 is larger than the templateDownloadTimeout.
 */
@property (nonatomic) NSTimeInterval imageDownloadTimeout;

/**
 If YES, this operation will not stop until a template has 
 been either downloaded or loaded from cache. If NO, any
 failure will cause the operation to end with a nil value
 in the templateConfiguration property. The default is YES.
 */
@property (nonatomic) BOOL shouldRetry;

/**
 If YES, the template and all its images downloaded without failure.
 */
@property (nonatomic) BOOL completedSuccessfully;

/**
 When this operation is done, this property will be
 populated with the template that was downloaded.
 */
@property (nonatomic, readonly, nullable) NSDictionary *templateConfiguration;

/**
 Initializes a new template download manager with a downloader.
 */
- (instancetype)initWithDownloader:(id<VTemplateDownloader>)downloader NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
