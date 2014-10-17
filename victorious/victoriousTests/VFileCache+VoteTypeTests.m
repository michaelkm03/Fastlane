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

static NSString * const kTestImageUrl = @"http://pngimg.com/upload/tamato_PNG45.png";

@interface VFileCache_VoteTypeTests : XCTestCase
{
    VFileCache *_fileCache;
    VAsyncTestHelper *_asyncHelper;
    VVoteType *_voteType;
}

@end

@implementation VFileCache_VoteTypeTests

- (void)setUp
{
    [super setUp];
    
    _asyncHelper = [[VAsyncTestHelper alloc] init];
    _fileCache = [[VFileCache alloc] init];
    
    _voteType = [VDummyModels objectWithEntityName:@"VoteType" subclass:[VVoteType class]];
    [self resetVoteType];
    
    NSString *directoryPath = [NSString stringWithFormat:VVoteTypeFilepathFormat, _voteType.name];
    [VFileSystemTestHelpers deleteCachesDirectory:directoryPath];
}

- (void)tearDown
{
    [super tearDown];
    
    _voteType = nil;
    
    _fileCache = nil;
}

- (void)resetVoteType
{
    _voteType.name = @"vote_type_test_name";
    _voteType.iconImage = kTestImageUrl;
    _voteType.flightImage = kTestImageUrl;
    _voteType.images = @[ kTestImageUrl, kTestImageUrl, kTestImageUrl, kTestImageUrl, kTestImageUrl ];
}

- (void)testKeyPathConstructionIcon
{
    NSString *keyPath;
    NSString *expectedKeyPath;
    
    keyPath = [_fileCache keyPathForImage:VVoteTypeIconName forVote:_voteType];
    expectedKeyPath = [[NSString stringWithFormat:VVoteTypeFilepathFormat, _voteType.name] stringByAppendingPathComponent:VVoteTypeIconName];
    XCTAssertEqualObjects( expectedKeyPath, keyPath );
    
    keyPath = [_fileCache keyPathForImage:VVoteTypeFlightImageName forVote:_voteType];
    expectedKeyPath = [[NSString stringWithFormat:VVoteTypeFilepathFormat, _voteType.name] stringByAppendingPathComponent:VVoteTypeFlightImageName];
    XCTAssertEqualObjects( expectedKeyPath, keyPath );
}

- (void)testSpriteKeyPathConstruction
{
    for ( NSUInteger i = 0; i < 20; i++ )
    {
        NSString *spriteKeyPath = [_fileCache keyPathForVoteTypeSprite:_voteType atFrameIndex:i];
        NSString *spriteName = [NSString stringWithFormat:VVoteTypeSpriteNameFormat, i];
        NSString *expectedKeyPath = [[NSString stringWithFormat:VVoteTypeFilepathFormat, _voteType.name] stringByAppendingPathComponent:spriteName];
        XCTAssertEqualObjects( expectedKeyPath, spriteKeyPath );
    }
}

- (void)testValidateVoteType
{
    XCTAssertFalse( [_fileCache validateVoteType:nil] );
    
    XCTAssertFalse( [_fileCache validateVoteType:(VVoteType *)[NSObject new]] );
    
    [self resetVoteType];
    _voteType.name = @"";
    XCTAssertFalse( [_fileCache validateVoteType:_voteType] );
    
    [self resetVoteType];
    _voteType.name = nil;
    XCTAssertFalse( [_fileCache validateVoteType:_voteType] );
    
    [self resetVoteType];
    _voteType.iconImage = @"";
    XCTAssertFalse( [_fileCache validateVoteType:_voteType] );
    
    [self resetVoteType];
    _voteType.iconImage = nil;
    XCTAssertFalse( [_fileCache validateVoteType:_voteType] );
    
    [self resetVoteType];
    _voteType.flightImage = nil;
    XCTAssertFalse( [_fileCache validateVoteType:_voteType] );
    
    [self resetVoteType];
    _voteType.images = @[ kTestImageUrl, kTestImageUrl, @"", kTestImageUrl, kTestImageUrl ];
    XCTAssertFalse( [_fileCache cacheImagesForVoteType:_voteType], @"Cannot have empty URLs in image array.");
}

- (void)testSpriteKeyPathConstructionArray
{
    NSArray *keyPaths = [_fileCache keyPathsForVoteTypeSprites:_voteType];
    
    [keyPaths enumerateObjectsUsingBlock:^(NSString *keyPath, NSUInteger i, BOOL *stop) {
        NSString *spriteName = [NSString stringWithFormat:VVoteTypeSpriteNameFormat, i];
        NSString *expectedKeyPath = [[NSString stringWithFormat:VVoteTypeFilepathFormat, _voteType.name] stringByAppendingPathComponent:spriteName];
        XCTAssertEqualObjects( expectedKeyPath, keyPath );
    }];
}

- (void)testCacheVoteTypeImages
{
    [_fileCache cacheImagesForVoteType:_voteType];
    
    [_asyncHelper waitForSignal:10.0f withSignalBlock:^BOOL{
        
        NSString *iconPath = [_fileCache keyPathForImage:VVoteTypeIconName forVote:_voteType];
        BOOL iconExists = [VFileSystemTestHelpers fileExistsInCachesDirectoryWithLocalPath:iconPath];
        
        NSString *flightImagePath = [_fileCache keyPathForImage:VVoteTypeFlightImageName forVote:_voteType];
        BOOL flightImageExists = [VFileSystemTestHelpers fileExistsInCachesDirectoryWithLocalPath:flightImagePath];
        
        // Make sure the sprite image swere saved
        __block BOOL spritesExist = YES;
        [((NSArray *)_voteType.images) enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *spritePath = [_fileCache keyPathForVoteTypeSprite:_voteType atFrameIndex:idx];
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
    XCTAssertFalse( [_fileCache cacheImagesForVoteType:nil] );
}

- (void)testLoadFiles
{
    // Run this test again to save theimages
    [self testCacheVoteTypeImages];
    
    UIImage *iconImage = [_fileCache getImageWithName:VVoteTypeIconName forVoteType:_voteType];
    XCTAssertNotNil( iconImage );
    
    UIImage *flightImage = [_fileCache getImageWithName:VVoteTypeIconName forVoteType:_voteType];
    XCTAssertNotNil( flightImage );
    
    NSArray *spriteImages = [_fileCache getSpriteImagesForVoteType:_voteType];
    XCTAssertEqual( spriteImages.count, ((NSArray *)_voteType.images).count );
    [spriteImages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XCTAssert( [obj isKindOfClass:[UIImage class]] );
    }];
}

@end
