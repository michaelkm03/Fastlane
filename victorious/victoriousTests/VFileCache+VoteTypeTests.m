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
#import "VVoteType+ImageSerialization.h"

@interface VFileCache ( UnitTest)

- (NSString *)keyPathForVoteTypeSprite:(VVoteType *)voteType atFrameIndex:(NSUInteger)index;
- (NSString *)keyPathForImage:(NSString *)imageName forVote:(VVoteType *)voteType;
- (NSArray *)keyPathsForVoteTypeSprites:(VVoteType *)voteType;
- (BOOL)validateVoteType:(VVoteType *)voteType;

@end

static NSString * const kTestImageUrl = @"https://www.google.com/images/srpr/logo11w.png";

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
    self.voteType.name = @"vote_type_test_name";
    self.voteType.iconImage = kTestImageUrl;
    self.voteType.imageFormat = @"http://media-dev-public.s3-website-us-west-1.amazonaws.com/_static/votetypes/6/heart_XXXXX.png";
    self.voteType.imageCount = @( 10 );
}

- (void)testKeyPathConstructionIcon
{
    NSString *keyPath;
    NSString *expectedKeyPath;
    
    keyPath = [self.fileCache keyPathForImage:VVoteTypeIconName forVote:self.voteType];
    expectedKeyPath = [[NSString stringWithFormat:VVoteTypeFilepathFormat, self.voteType.name] stringByAppendingPathComponent:VVoteTypeIconName];
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
        
        // Make sure the sprite image swere saved
        __block BOOL spritesExist = YES;
        NSArray *images = self.voteType.images;
        [images enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *spritePath = [self.fileCache keyPathForVoteTypeSprite:self.voteType atFrameIndex:idx];
            if ( ![VFileSystemTestHelpers fileExistsInCachesDirectoryWithLocalPath:spritePath] )
            {
                spritesExist = NO;
                *stop = YES;
            }
        }];
        
        return iconExists && spritesExist;
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
    XCTAssertEqual( spriteImages.count, self.voteType.images.count );
    [spriteImages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XCTAssert( [obj isKindOfClass:[UIImage class]] );
    }];
}

@end
