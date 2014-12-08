//
//  VPurchaseRecordTests.m
//  victorious
//
//  Created by Patrick Lynch on 12/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "VPurchaseRecord.h"

static NSString * const kTestFilePath = @"unit.test.filepath";

@interface VPurchaseRecord (UnitTests)

@property (nonatomic, readwrite) NSArray *purchasedProductIdentifiers;
@property (nonatomic, strong) NSString *filepath;
@property (nonatomic, readonly) NSString *absoluteFilepath;

- (NSString *)getDocumentDirectoryPathWithRelativePath:(NSString *)path;
- (unichar *)generateKeyWithDeviceIdentifier:(NSString *)deviceIdentifier;

@end

@interface VPurchaseRecordTests : XCTestCase

@property (nonatomic, strong) VPurchaseRecord *purchaseRecord;

@end

@implementation VPurchaseRecordTests

- (void)setUp
{
    [super setUp];
    
    self.purchaseRecord = [[VPurchaseRecord alloc] initWithRelativeFilePath:kTestFilePath];
}

- (void)tearDown
{
    [super tearDown];
    
    [self.purchaseRecord clear];
}

- (void)testAbsoluteFilepath
{
    NSString *expected = [ self.purchaseRecord getDocumentDirectoryPathWithRelativePath:self.purchaseRecord.filepath];
    XCTAssertEqualObjects( self.purchaseRecord.absoluteFilepath, expected );
}

- (void)testGenerateKeyError
{
    XCTAssertThrows( [self.purchaseRecord generateKeyWithDeviceIdentifier:@"abcdefg6789"],
                    @"Device ID must be at least 20 chars long." );
    XCTAssertThrows( [self.purchaseRecord generateKeyWithDeviceIdentifier:nil] );
}

- (void)testGenerateKey
{
    XCTAssertNoThrow( [self.purchaseRecord generateKeyWithDeviceIdentifier:@"abcdefghijklmnopqrstuvwxyz0123456789"] );
}

- (void)testReadAndWrite
{
    [self.purchaseRecord addProductIdentifier:@"product1"];
    XCTAssert( [self.purchaseRecord.purchasedProductIdentifiers containsObject:@"product1"] );
    XCTAssertEqual( self.purchaseRecord.purchasedProductIdentifiers.count, (NSUInteger)1 );
    
    self.purchaseRecord = nil;
    self.purchaseRecord = [[VPurchaseRecord alloc] initWithRelativeFilePath:kTestFilePath];
    [self.purchaseRecord loadPurchasedProductIdentifiers];
    XCTAssert( [self.purchaseRecord.purchasedProductIdentifiers containsObject:@"product1"] );
    XCTAssertEqual( self.purchaseRecord.purchasedProductIdentifiers.count, (NSUInteger)1 );
    
    [self.purchaseRecord clear];
    XCTAssertEqual( self.purchaseRecord.purchasedProductIdentifiers.count, (NSUInteger)0 );
    
    self.purchaseRecord = nil;
    self.purchaseRecord = [[VPurchaseRecord alloc] initWithRelativeFilePath:kTestFilePath];
    [self.purchaseRecord loadPurchasedProductIdentifiers];
    XCTAssertEqual( self.purchaseRecord.purchasedProductIdentifiers.count, (NSUInteger)0 );
    XCTAssertFalse( [self.purchaseRecord.purchasedProductIdentifiers containsObject:@"product1"] );
}

@end
