//
//  VFileCache.m
//  victorious
//
//  Created by Patrick Lynch on 10/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFileCache.h"

static const char * const kDispatchQueueLabel = "com.getvictorious.vote_types_dispatch_queue";

const NSUInteger VFileCacheMaximumSaveFileRetries = 1;

@interface VFileCache()

@property (nonatomic, readonly) dispatch_queue_t dispatchQueue;

@end

// TODO: Implement dispatch groups to apply timeouts

@implementation VFileCache

- (dispatch_queue_t)dispatchQueue
{
    static dispatch_queue_t dispatch_queue;
    static dispatch_once_t once_token;
    dispatch_once( &once_token, ^void
                  {
                      dispatch_queue = dispatch_queue_create( kDispatchQueueLabel, DISPATCH_QUEUE_CONCURRENT );
                  });
    return dispatch_queue;
}

#pragma mark - Caching file(s) to disk

- (BOOL)cacheFileAtUrl:(NSString *)fileUrl withSavePath:(NSString *)savePath
{
    return [self cacheFileAtUrl:fileUrl withSavePath:savePath shouldOverwrite:NO];
}

- (BOOL)cacheFileAtUrl:(NSString *)fileUrl withSavePath:(NSString *)savePath shouldOverwrite:(BOOL)shouldOverwrite
{
    // Error checking
    if ( fileUrl == nil || fileUrl.length == 0 || savePath == nil || savePath.length == 0 )
    {
        return NO;
    }
    
    dispatch_barrier_async( self.dispatchQueue, ^void
                           {
                               
                               // Creates directory (if it doesn't exist already)
                               NSString *localDirectoryPath = [savePath stringByDeletingLastPathComponent];
                               [self createDirectoryAtPath:[self getCachesDirectoryPathForPath:localDirectoryPath]];
                               
                               NSString *fullPath = [self getCachesDirectoryPathForPath:savePath];
                               [self saveFile:fileUrl toPath:fullPath shouldOverwrite:shouldOverwrite withNumRetries:5];
                           });
    
    return YES;
}

- (BOOL)cacheFilesAtUrls:(NSArray *)fileUrls withSavePaths:(NSArray *)savePaths
{
    return [self cacheFilesAtUrls:fileUrls withSavePaths:savePaths shouldOverwrite:NO];
}

- (BOOL)cacheFilesAtUrls:(NSArray *)fileUrls withSavePaths:(NSArray *)savePaths shouldOverwrite:(BOOL)shouldOverwrite
{
    if ( fileUrls == nil || fileUrls.count == 0 || savePaths == nil || savePaths.count == 0 )
    {
        return NO;
    }
    if ( fileUrls.count != savePaths.count )
    {
        return NO;
    }
    
    // Creates directory (if it doesn't exist already)
    NSString *localDirectoryPath = [savePaths[0] stringByDeletingLastPathComponent];
    [self createDirectoryAtPath:[self getCachesDirectoryPathForPath:localDirectoryPath]];
    
    for ( NSUInteger i = 0; i < savePaths.count; i++ )
    {
        NSString *savePath = savePaths[i];
        NSString *fileUrl = fileUrls[i];
        
        dispatch_barrier_async( self.dispatchQueue, ^void
                               {
                                   NSString *fullPath = [self getCachesDirectoryPathForPath:savePath];
                                   [self saveFile:fileUrl toPath:fullPath shouldOverwrite:shouldOverwrite withNumRetries:5];
                               });
    }
    
    return YES;
}

#pragma mark - Synchronous reads

- (NSData *)getCachedFileForSavePath:(NSString *)savePath
{
    if ( savePath == nil || savePath.length == 0 )
    {
        return nil;
    }
    
    return [self readFileForSavePath:savePath];
}

- (NSArray *)getCachedFilesForSavePaths:(NSArray *)savePaths
{
    if ( savePaths == nil || savePaths.count == 0 )
    {
        return nil;
    }
    
    NSMutableArray *fileDataContainer = [[NSMutableArray alloc] init];
    [savePaths enumerateObjectsUsingBlock:^(NSString *savePath, NSUInteger idx, BOOL *stop)
     {
         // Load the data on this queue using synchronous method
         NSData *fileData = [self readFileForSavePath:savePath];
         if ( fileData != nil )
         {
             [fileDataContainer addObject:fileData];
         }
         else
         {
             // Never return an incomplete array if there's an error
             [fileDataContainer removeAllObjects];
             *stop = YES;
         }
     }];
    
    return [NSArray arrayWithArray:fileDataContainer];
}

#pragma mark - Asynchronous reads

- (BOOL)getCachedFileForSavePath:(NSString *)savePath completeCallback:(void(^)(NSData *))completeCallback
{
    if ( savePath == nil || savePath.length == 0 || completeCallback == nil )
    {
        return NO;
    }
    
    dispatch_async( self.dispatchQueue, ^void
                   {
                       // Load the data on this queue using synchronous method
                       NSData *fileData = [self readFileForSavePath:savePath];
                       
                       // Response on the main queue
                       dispatch_async( dispatch_get_main_queue(), ^void
                                      {
                                          completeCallback( fileData );
                                      });
                   });
    
    return YES;
}

- (BOOL)getCachedFilesForSavePaths:(NSArray *)savePaths completeCallback:(void(^)(NSArray *))completeCallback
{
    if ( completeCallback == nil )
    {
        return NO;
    }
    
    dispatch_async( self.dispatchQueue, ^void
                   {
                       // Load the data on this queue using synchronous method
                       NSArray *fileDataArray = [self getCachedFilesForSavePaths:savePaths];
                       
                       // Response on the main queue
                       dispatch_async( dispatch_get_main_queue(), ^void
                                      {
                                          completeCallback( fileDataArray );
                                      });
                   });
    
    return YES;
}

#pragma mark - Private methods

- (NSData *)readFileForSavePath:(NSString *)savePath
{
    NSString *filepath = [self getCachesDirectoryPathForPath:savePath];
    
    // Load the image from disk
    NSError *error;
    NSData *data = [NSData dataWithContentsOfFile:filepath options:0 error:&error];
    if ( data == nil )
    {
        VLog( @"Error reading image from path:\n%@\n%@", filepath, [error localizedDescription] );
        return nil;
    }
    
    // Allow a decoderBlock block to modify the data and return it
    if ( self.decoderBlock != nil )
    {
        data = self.decoderBlock( data );
    }
    
    return data;
}

- (BOOL)saveFile:(NSString *)fileUrl toPath:(NSString *)filepath shouldOverwrite:(BOOL)shouldOverwrite withNumRetries:(NSUInteger)numRetries
{
    BOOL didSucceed = NO;
    NSUInteger numAttempts = 0;
    numRetries = numRetries > VFileCacheMaximumSaveFileRetries ? VFileCacheMaximumSaveFileRetries : numRetries;
    NSUInteger maxAttempts = (numRetries <= 1) ? 1 : numRetries - 1;
    while ( numAttempts < maxAttempts && !didSucceed )
    {
        didSucceed = [self saveFile:fileUrl toPath:filepath shouldOverwrite:shouldOverwrite];
        numAttempts++;
    }
    return didSucceed;
}

- (BOOL)saveFile:(NSString *)fileUrl toPath:(NSString *)filepath shouldOverwrite:(BOOL)shouldOverwrite
{
    // Error checking
    if ( fileUrl == nil || fileUrl.length == 0 )
    {
        return NO;
    }
    if ( filepath == nil || filepath.length == 0 )
    {
        return NO;
    }
    
    // Check if file already exists
    if ( !shouldOverwrite && [self fileExistsAtPath:filepath] )
    {
        return YES;
    }
    else
    {
        return [self downloadAndWriteFile:fileUrl toPath:filepath];
    }
}

- (BOOL)fileExistsAtPath:(NSString *)filepath
{
    BOOL doesFileExist = [[NSFileManager defaultManager] fileExistsAtPath:filepath];
    BOOL isValidFile = [self fileSizeAtPath:filepath];
    return isValidFile && doesFileExist;
}

- (BOOL)downloadAndWriteFile:(NSString *)urlString toPath:(NSString *)filepath
{
    // Error checking
    if ( urlString == nil || urlString.length == 0 )
    {
        return NO;
    }
    if ( filepath == nil || filepath.length == 0 )
    {
        return NO;
    }

    // Download the image data
    NSData *data = [self synchronousDataFromUrl:urlString];
    if ( data == nil )
    {
        return NO;
    }
    
    // Allow an encoder block to modify the data and return it
    if ( self.encoderBlock != nil )
    {
        data = self.encoderBlock( data );
    }
    
    // Write to disk
    NSError *writeError;
    BOOL didSucceed = [data writeToFile:filepath options:NSDataWritingAtomic error:&writeError];
    if ( !didSucceed )
    {
        VLog( @"Error writing image to path:\n%@\n%@", filepath, [writeError localizedDescription] );
    }
    else
    {
        NSError *setValueError;
        NSURL *url = [[NSURL alloc] initWithScheme:NSURLFileScheme host:@"" path:filepath];
        if ( ![url setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:&setValueError] )
        {
            VLog( @"Error setting NSURLIsExcludedFromBackupKey to YES:\n%@\n%@", filepath, [setValueError localizedDescription] );
        }
    }
    VLog( @"Error writing image to path:\n%@\n%@", filepath, [writeError localizedDescription] );
    
    return didSucceed;
}

- (NSData *)synchronousDataFromUrl:(NSString *)urlString
{
    NSError *downloadError;
    NSURLResponse *response;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&downloadError];
    if ( data == nil )
    {
        VLog( @"Error downloading image from URL:\n%@\n%@", urlString, [downloadError localizedDescription] );
    }
    return data;
}

- (NSUInteger)fileSizeAtPath:(NSString *)path
{
    NSError *error;
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
   return (NSUInteger)[attributes fileSize];
}

- (NSString *)getCachesDirectoryPathForPath:(NSString *)path
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [paths firstObject];
    NSString *compoundPath = [cachePath stringByAppendingPathComponent:path];
    return compoundPath;
}

- (BOOL)createDirectoryAtPath:(NSString *)path
{
    // Check if it exists already
    BOOL isDirectory = NO;
    if ( [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory] && isDirectory )
    {
        return YES;
    }
    else
    {
        // Create it
        NSError *error;
        BOOL didCreateDirectory = [[NSFileManager defaultManager] createDirectoryAtPath:path
                                                            withIntermediateDirectories:YES
                                                                             attributes:nil
                                                                                  error:&error];
        return didCreateDirectory;
    }
}

@end
