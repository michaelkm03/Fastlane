//
//  VMultipartFormDataWriter.h
//  victorious
//
//  Created by Josh Hinman on 9/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Writes a series of fields to a file on disk in multipart/form-data format.
 This class does not attempt to encode any non-ASCII characters in field
 names, so you must limit your field names to 7-bit ASCII characters.
 */
@interface VMultipartFormDataWriter : NSObject

/**
 A string used to seperate the fields in the output
 file. It should be unique: not present in any of
 the input parts. If you don't set it, a hard-coded 
 default will be used. If you do set it, set it
 prior to the start of any writing.
 
 Per RFC 1341, the boundary should consist of 1 to 70
 characters from a set of characters known to be very
 robust through email gateways, and NOT ending with
 white space.
 */
@property (atomic, copy) NSString *boundary;

/**
 Creates a new instance of VMultipartFormDataWriter
 
 @param stream The stream to write to. Should already be open.
 */
- (instancetype)initWithOutputStream:(NSOutputStream *)stream NS_DESIGNATED_INITIALIZER;

/**
 Creates a new instance of VMultipartFormDataWriter
 
 @param outputFileURL the file to open for writing.
 */
- (instancetype)initWithOutputFileURL:(NSURL *)outputFileURL;

- (instancetype)init NS_UNAVAILABLE;

/**
 Returns a content-type header (not including the header itself, i.e. "Content-Type: ")
 that describes the content that will be written to the output file.
 */
- (NSString *)contentTypeHeader;

/**
 Writes a new field of type text/plain to the output file
 
 @param s The contents of the new field to write
 @param fieldName the name of the field to put in the content-disposition header
 @param error If something goes wrong, this object will have more information
 */
- (BOOL)appendPlaintext:(NSString *)s withFieldName:(NSString *)fieldName error:(NSError *__autoreleasing *)error;

- (BOOL)appendData:(NSData *)data withFieldName:(NSString *)fieldName error:(NSError *__autoreleasing *)error;
/**
 Writes the contents of the given input stream as a new field.
 The input stream should be open and ready for reading.
 
 @param filename The filename to use in the Content-Disposition header
 @param contentType The MIME type to put in the Content-Type header
 @param stream an input stream from which to read the field's contents
 @param fieldName the name of the field to put in the content-disposition header
 @param error If something goes wrong, this object will have more information
 */
- (BOOL)appendFileWithName:(NSString *)filename
               contentType:(NSString *)contentType
                    stream:(NSInputStream *)inputStream
                 fieldName:(NSString *)fieldName
                     error:(NSError *__autoreleasing *)error;

/**
 Writes the contents of the given file URL as a new field.

 @param filename The filename to use in the Content-Disposition header
 @param contentType The MIME type to put in the Content-Type header
 @param fileURL The fileURL from which to read the field's contents
 @param fieldName the name of the field to put in the content-disposition header
 @param error If something goes wrong, this object will have more information
 */
- (BOOL)appendFileWithName:(NSString *)filename
               contentType:(NSString *)contentType
                   fileURL:(NSURL *)fileURL
                 fieldName:(NSString *)fieldName
                     error:(NSError *__autoreleasing *)error;

/**
 Finishes writing to the output file and closes it. If more "append" methods
 are called after calling this method, the file will be opened anew, cleared,
 previously appended data will be overwritten.
 */
- (BOOL)finishWritingWithError:(NSError *__autoreleasing *)error;

/**
 If any of the append methods returns an unrecoverable error,
 calling -finishWritingWithError: is likely to produce more
 errors. Instead, call this method to close the file 
 immediately without attempting to write the final boundary.
 */
- (void)closeOutputFileWithoutFinishing;

@end

NS_ASSUME_NONNULL_END
