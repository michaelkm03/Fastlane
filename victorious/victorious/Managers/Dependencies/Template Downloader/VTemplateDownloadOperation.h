//
//  VTemplateDownloadOperation.h
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

#pragma mark -

@class VTemplateDownloadOperation;

@protocol VTemplateDownloadOperationDelegate <NSObject>

/**
 Notifies the delegate that a template has been successfully loaded
 */
- (void)templateDownloadOperation:(VTemplateDownloadOperation *)downloadOperation didFinishLoadingTemplateConfiguration:(NSDictionary *)configuration;

/**
 Notifies the delegate that a new operation needs to be added to an operation queue. (Any operation queue will do!)
 These operations may continue running after the template download operation finishes.
 */
- (void)templateDownloadOperation:(VTemplateDownloadOperation *)downloadOperation needsAnOperationAddedToTheQueue:(NSOperation *)operation;

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
@property (nonatomic, copy) id<VDataCacheID> templateConfigurationCacheID;

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
@property (nonatomic) NSTimeInterval timeout;

/**
 If YES, this operation will not stop until a template has 
 been either downloaded or loaded from cache. If NO, any
 failure will cause the completion block to be called with
 a nil dictionary. The default is YES.
 */
@property (nonatomic) BOOL shouldRetry;

/**
 Initializes a new template download manager with a downloader and a delegate
 */
- (instancetype)initWithDownloader:(id<VTemplateDownloader>)downloader andDelegate:(id<VTemplateDownloadOperationDelegate>)delegate NS_DESIGNATED_INITIALIZER;

@end
