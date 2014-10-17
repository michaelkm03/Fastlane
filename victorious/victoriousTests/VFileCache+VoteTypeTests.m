//
//  VFileCache+VVoteTypeTests.m
//  victorious
//
//  Created by Patrick Lynch on 10/14/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VFileCache.h"
#import "VFileCache+VVoteType.h"
#import "VAsyncTestHelper.h"
#import "VFileSystemTestHelpers.h"
#import "VDummyModels.h"

@interface VFileCache ( UnitTest)

- (NSString *)keyPathForVoteTypeSprite:(VVoteType *)voteType atFrameIndex:(NSUInteger)index;
- (NSString *)keyPathForImage:(NSString *)imageName forVote:(VVoteType *)voteType;
- (NSArray *)keyPathsForVoteTypeSprites:(VVoteType *)voteType;
- (BOOL)validateVoteType:(VVoteType *)voteType;

@end

static NSString * const kTestImageUrl = @"http://pngimg.com/upload/tamatoself.PNG45.png";

@interface VoteTypeTests : XCTestCase

@property (nonatomic, strong) VFileCache *fileCache;
@property (nonatomic, strong) VAsyncTestHelper *asyncHelper;
@property (nonatomic, strong) VVoteType *voteType;

@end

@implementation VoteTypeTests

- (void)setUp
{
    [super setUp];
    
    self.asyncHelper = [[VAsyncTestHelper alloc] init];
    self.fileCache = [[VFileCache alloc] init];
    
    self.voteType = [VDummyModels objectWithEntityName:@"VoteType" subclass:[VVoteType class]];
    [self resetVoteType];
    
    NSString *directoryPath = [NSString stringWithFormat:VVoteTypeFilepathFormat, self.voteType.name];
    [VFileSystemTestHelpers deleteCachesDirectory:directoryPath];
}

- (void)tearDown
{
    [super tearDown];
    
    self.voteType = nil;
    
    self.fileCache = nil;
}

- (void)resetVoteType
{
    self.voteType.name = @"voteself.typeself.testself.name";
    self.voteType.iconImage = kTestImageUrl;
    self.voteType.flightImage = kTestImageUrl;
    self.voteType.images = @[ kTestImageUrl, kTestImageUrl, kTestImageUrl, kTestImageUrl, kTestImageUrl ];
}

- (void)testKeyPathConstructionIcon
{
    NSString *keyPath;
    NSString *expectedKeyPath;
    
    keyPath = [self.fileCache keyPathForImage:VVoteTypeIconName forVote:self.voteType];
    expectedKeyPath = [[NSString stringWithFormat:VVoteTypeFilepathFormat, self.voteType.name] stringByAppendingPathComponent:VVoteTypeIconName];
    XCTAssertEqualObjects( expectedKeyPath, keyPath );
    
    keyPath = [self.fileCache keyPathForImage:VVoteTypeFlightImageName forVote:self.voteType];
    expectedKeyPath = [[NSString stringWithFormat:VVoteTypeFilepathFormat, self.voteType.name] stringByAppendingPathComponent:VVoteTypeFlightImageName];
    XCTAssertEqualObjects( expectedKeyPath, keyPath );
}

- (void)testSpriteKeyPathConstruction
{
    for ( NSUInteger i = 0; i < 20; i++ )
    {
        NSString *spriteKeyPath = [self.fileCache keyPathForVoteTypeSprite:self.voteType atFrameIndex:i];
        NSString *spriteName = [NSString stringWithFormat:VVoteTypeSpriteNameFormat, i];
        NSString *expectedKeyPath = [[NSString stringWithFormat:VVoteTypeFilepathFormat, self.voteType.name] stringByAppendingPathComponent:spriteName];
        XCTAssertEqualObjects( expectedKeyPath, spriteKeyPath );
    }
}

- (void)testValidateVoteType
{
    XCTAssertFalse( [self.fileCache validateVoteType:nil] );
    
    XCTAssertFalse( [self.fileCache validateVoteType:(VVoteType *)[NSObject new]] );
    
    [self resetVoteType];
    self.voteType.name = @"";
    XCTAssertFalse( [self.fileCache validateVoteType:self.voteType] );
    
    [self resetVoteType];
    self.voteType.name = nil;
    XCTAssertFalse( [self.fileCache validateVoteType:self.voteType] );
    
    [self resetVoteType];
    self.voteType.images = @[ kTestImageUrl, kTestImageUrl, @"", kTestImageUrl, kTestImageUrl ];
    XCTAssertFalse( [self.fileCache cacheImagesForVoteType:self.voteType], @"Cannot have empty URLs in image array.");
}

- (void)testSpriteKeyPathConstructionArray
{
    NSArray *keyPaths = [self.fileCache keyPathsForVoteTypeSprites:self.voteType];
    
    [keyPaths enumerateObjectsUsingBlock:^(NSString *keyPath, NSUInteger i, BOOL *stop) {
        NSString *spriteName = [NSString stringWithFormat:VVoteTypeSpriteNameFormat, i];
        NSString *expectedKeyPath = [[NSString stringWithFormat:VVoteTypeFilepathFormat, self.voteType.name] stringByAppendingPathComponent:spriteName];
        XCTAssertEqualObjects( expectedKeyPath, keyPath );
    }];
}

- (void)testCacheVoteTypeImages
{
    [self.fileCache cacheImagesForVoteType:self.voteType];
    
    [self.asyncHelper waitForSignal:10.0f withSignalBlock:^BOOL{
        
        NSString *iconPath = [self.fileCache keyPathForImage:VVoteTypeIconName forVote:self.voteType];
        BOOL iconExists = [VFileSystemTestHelpers fileExistsInCachesDirectoryWithLocalPath:iconPath];
        
        NSString *flightImagePath = [self.fileCache keyPathForImage:VVoteTypeFlightImageName forVote:self.voteType];
        BOOL flightImageExists = [VFileSystemTestHelpers fileExistsInCachesDirectoryWithLocalPath:flightImagePath];
        
        // Make sure the sprite image swere saved
        __block BOOL spritesExist = YES;
        [((NSArray *)self.voteType.images) enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *spritePath = [self.fileCache keyPathForVoteTypeSprite:self.voteType atFrameIndex:idx];
            if ( ![VFileSystemTestHelpers fileExistsInCachesDirectoryWithLocalPath:spritePath] )
            {
                spritesExist = NO;
                *stop = YES;
            }
        }];
        
        return iconExists && flightImageExists && spritesExist;
    }];
}

- (void)testCacheImagesInvalid
{
    XCTAssertFalse( [self.fileCache cacheImagesForVoteType:nil] );
}

- (void)testLoadFiles
{
    // Run this test again to save theimages
    [self testCacheVoteTypeImages];
    
    UIImage *iconImage = [self.fileCache getImageWithName:VVoteTypeIconName forVoteType:self.voteType];
    XCTAssertNotNil( iconImage );
    
    UIImage *flightImage = [self.fileCache getImageWithName:VVoteTypeIconName forVoteType:self.voteType];
    XCTAssertNotNil( flightImage );
    
    NSArray *spriteImages = [self.fileCache getSpriteImagesForVoteType:self.voteType];
    XCTAssertEqual( spriteImages.count, ((NSArray *)self.voteType.images).count );
    [spriteImages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XCTAssert( [obj isKindOfClass:[UIImage class]] );
    }];
}

@end
