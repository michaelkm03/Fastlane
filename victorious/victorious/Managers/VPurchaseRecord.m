//
//  VPurchaseRecord.m
//  victorious
//
//  Created by Patrick Lynch on 12/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VPurchaseRecord.h"
#import "NSData+AES.h"

@interface VPurchaseRecord ()

@property (nonatomic, readwrite) NSArray *purchasedProductIdentifiers;
@property (nonatomic, strong) NSString *filepath;
@property (nonatomic, readonly) NSString *absoluteFilepath;
@property (nonatomic, readonly) NSString *deviceIdentifier;

@end

@implementation VPurchaseRecord

- (instancetype)initWithRelativeFilePath:(NSString *)filepath
{
    self = [super init];
    if (self)
    {
        NSParameterAssert( filepath != nil );
        _filepath = filepath;
        _purchasedProductIdentifiers = @[];
    }
    return self;
}

#pragma mark - Public methods

- (void)addProductIdentifier:(NSString *)productIdentifier
{
    if ( [self.purchasedProductIdentifiers containsObject:productIdentifier] )
    {
        return;
    }
    
    self.purchasedProductIdentifiers = [self.purchasedProductIdentifiers arrayByAddingObject:productIdentifier];
    
    if ( ![self writeArray:self.purchasedProductIdentifiers toFileWithFilepath:self.absoluteFilepath] )
    {
        VLog( @"Error writing to file at path: %@", self.absoluteFilepath );
    }
}

- (NSArray *)loadPurchasedProductIdentifiers
{
    self.purchasedProductIdentifiers = [self readFromFile:self.absoluteFilepath];
    return self.purchasedProductIdentifiers;
}

- (void)clear
{
    _purchasedProductIdentifiers = @[];
    
    NSError *error = nil;
    BOOL isDirectory;
    if ( [[NSFileManager defaultManager] fileExistsAtPath:self.absoluteFilepath isDirectory:&isDirectory] && !isDirectory )
    {
        if ( ![[NSFileManager defaultManager] removeItemAtPath:self.absoluteFilepath error:&error] )
        {
            VLog( @"Error deleting purchases record: %@", error.localizedDescription );
        }
    }
}

#pragma mark - Helpers

- (BOOL)writeArray:(NSArray *)array toFileWithFilepath:(NSString *)filepath
{
    NSData *data = nil;
    
    if ( array != nil )
    {
        NSError *error = nil;
        data = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:&error];
        if ( data == nil || ![data isKindOfClass:[NSData class]] )
        {
            return NO;
        }
    }
    else
    {
        return NO;
    }
    
    unichar *key = [self generateKeyWithDeviceIdentifier:self.deviceIdentifier];
    NSData *encrypedData = [data encryptedDataWithAESKey:[NSData dataWithBytes:key length:16]];
    free( key );
    
    NSError *error = nil;
    return [encrypedData writeToFile:filepath options:NSDataWritingAtomic error:&error];
}

- (NSArray *)readFromFile:(NSString *)filepath
{
    NSData *encryptedData = [NSData dataWithContentsOfFile:filepath];
    if ( encryptedData == nil )
    {
        return @[];
    }
    
    unichar *key = [self generateKeyWithDeviceIdentifier:self.deviceIdentifier];
    NSData *decryptedData = [encryptedData decryptedDataWithAESKey:[NSData dataWithBytes:key length:16]];
    free( key );
    
    if ( decryptedData == nil )
    {
        [self decryptionDidFail];
        return @[];
    }
    NSError *error = nil;
    NSString *jsonString = [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
    NSData *data = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]
                                                   options:NSJSONReadingAllowFragments error:&error];
    if ( data == nil || ![data isKindOfClass:[NSArray class]] )
    {
        [self decryptionDidFail];
        return @[];
    }
    
    return (NSArray *)data;
}

- (void)decryptionDidFail
{
    // If decryption fails (due to tampering or legitimate error)
    // start over with a clear purchase record on disk
    [self clear];
}

- (NSString *)absoluteFilepath
{
    return [self getDocumentDirectoryPathWithRelativePath:self.filepath];
}

- (NSString *)getDocumentDirectoryPathWithRelativePath:(NSString *)path
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES );
    NSString *documentPath = [paths firstObject];
    NSString *compoundPath = [documentPath stringByAppendingPathComponent:path];
    return compoundPath;
}

- (NSString *)deviceIdentifier
{
    return [UIDevice currentDevice].identifierForVendor.UUIDString;
}

- (unichar *)generateKeyWithDeviceIdentifier:(NSString *)deviceIdentifier
{
    NSParameterAssert( deviceIdentifier != nil );
    NSParameterAssert( deviceIdentifier.length >= 20 );
    
    int indices[16] = {
        5,  4, 19, 13,
        5,  8,  7,  6,
        14, 8,  1,  2,
        4, 15,  9,  6
    };
    size_t size = sizeof(unichar) * 16;
    unichar *output = (unichar *)malloc( size );
    for ( NSUInteger i = 0; i < sizeof(indices) / sizeof(int); i++ )
    {
        output[i] = (unichar)[deviceIdentifier characterAtIndex:indices[i]];
    }
    return output;
}

@end
