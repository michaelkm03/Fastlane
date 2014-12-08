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

@end

@implementation VPurchaseRecord

- (instancetype)initWithRelativeFilePath:(NSString *)filepath
{
    self = [super init];
    if (self)
    {
        NSParameterAssert( filepath != nil );
        _filepath = filepath;
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
    
    self.purchasedProductIdentifiers = [(self.purchasedProductIdentifiers ?: @[]) arrayByAddingObject:productIdentifier];
    
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

#pragma mark - Helpers

- (BOOL)writeArray:(NSArray *)array toFileWithFilepath:(NSString *)filepath
{
    NSData *data = nil;
    
    if ( array != nil )
    {
        NSError *error = nil;
        data = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:&error];
        if ( error != nil )
        {
            return NO;
        }
    }
    else
    {
        return NO;
    }
    
    unichar *key = [self generateKey];
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
        return [[NSArray alloc] init];
    }
    
    unichar *key = [self generateKey];
    NSData *decryptedData = [encryptedData decryptedDataWithAESKey:[NSData dataWithBytes:key length:16]];
    free( key );
    
    if ( decryptedData == nil )
    {
        // Error decrypting: assume file has been tampered with or replaced
        exit( 1 );
    }
    NSError *error = nil;
    NSString *jsonString = [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
    NSData *data = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&error];
    if ( error != nil )
    {
        // Error decrypting: assume file has been tampered with or replaced
        exit( 1 );
    }
    
    return (NSArray *)data;
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

- (unichar *)generateKey
{
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
        output[i] = (unichar)[[UIDevice currentDevice].identifierForVendor.UUIDString characterAtIndex:indices[i]];
    }
    return output;
}

@end
