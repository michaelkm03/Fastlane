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

@class VTemplateDownloadOperation;

@protocol VTemplateDownloadOperationDelegate <NSObject>

/**
 Notifies the delegate that a new operation needs to be added to an operation queue. (Any operation queue will do!)
 These operations may continue running after the template download operation finishes.
 */
- (void)templateDownloadOperation:(VTemplateDownloadOperation *)downloadOperation needsAnOperationAddedToTheQueue:(NSOperation *)operation;

@optional

/**
 Notifies the delegate that due to a timeout, a cached template was
 loaded and can be read from the templateConfiguration property.
 */
- (void)templateDownloadOperationDidFallbackOnCache:(VTemplateDownloadOperation *)downloadOperation;

@end

#pragma mark -

@class VDataCache;
@protocol VDataCacheID;

/**
 Provides a fresh, piping-hot template straight off the wire
 when available, otherwise falls back on the most recently
 downloaded template. If no template has ever been downloaded,
 this class will provide one that was included in the app
 bundle.
 */
@interface VTemplateDownloadOperation : NSOperation

/**
 An instance of VDataCache used for storing & retrieving template data.
 If this is not set, there is a suitable default that will be used.
 */
@property (nonatomic, strong) VDataCache *dataCache;

/**
 The VDataCacheID that will be used to store & retrieve the
 template configuration in the instance of VDataCache
 provided in the dataCache property.
 */
@property (nonatomic, copy, nullable) id<VDataCacheID> templateConfigurationCacheID;

/**
 The downloader that was provided at initialization time
 */
@property (nonatomic, readonly) id<VTemplateDownloader> downloader;

/**
 The delegate that was provided at initialization time
 */
@property (nonatomic, weak, readonly) id<VTemplateDownloadOperationDelegate> delegate;

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
 When this operation is done (or sometimes earlier--see the
 templateDownloadOperationDidFallbackOnCache: method on 
 VTemplateDownloadOperationDelegate), this property will 
 be populated with the template that was downloaded.
 */
@property (nonatomic, readonly, nullable) NSDictionary *templateConfiguration;

/**
 Initializes a new template download manager with a downloader and a delegate
 */
- (instancetype)initWithDownloader:(id<VTemplateDownloader>)downloader andDelegate:(id<VTemplateDownloadOperationDelegate>)delegate NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
