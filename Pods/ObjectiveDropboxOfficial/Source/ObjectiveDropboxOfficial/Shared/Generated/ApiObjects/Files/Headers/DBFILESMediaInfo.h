///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

#import <Foundation/Foundation.h>

#import "DBSerializableProtocol.h"

@class DBFILESMediaInfo;
@class DBFILESMediaMetadata;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - API Object

///
/// The `MediaInfo` union.
///
/// This class implements the `DBSerializable` protocol (serialize and
/// deserialize instance methods), which is required for all Obj-C SDK API route
/// objects.
///
@interface DBFILESMediaInfo : NSObject <DBSerializable, NSCopying>

#pragma mark - Instance fields

/// The `DBFILESMediaInfoTag` enum type represents the possible tag states with
/// which the `DBFILESMediaInfo` union can exist.
typedef NS_ENUM(NSInteger, DBFILESMediaInfoTag) {
  /// Indicate the photo/video is still under processing and metadata is not
  /// available yet.
  DBFILESMediaInfoPending,

  /// The metadata for the photo/video.
  DBFILESMediaInfoMetadata,

};

/// Represents the union's current tag state.
@property (nonatomic, readonly) DBFILESMediaInfoTag tag;

/// The metadata for the photo/video. @note Ensure the `isMetadata` method
/// returns true before accessing, otherwise a runtime exception will be raised.
@property (nonatomic, readonly) DBFILESMediaMetadata *metadata;

#pragma mark - Constructors

///
/// Initializes union class with tag state of "pending".
///
/// Description of the "pending" tag state: Indicate the photo/video is still
/// under processing and metadata is not available yet.
///
/// @return An initialized instance.
///
- (instancetype)initWithPending;

///
/// Initializes union class with tag state of "metadata".
///
/// Description of the "metadata" tag state: The metadata for the photo/video.
///
/// @param metadata The metadata for the photo/video.
///
/// @return An initialized instance.
///
- (instancetype)initWithMetadata:(DBFILESMediaMetadata *)metadata;

- (instancetype)init NS_UNAVAILABLE;

#pragma mark - Tag state methods

///
/// Retrieves whether the union's current tag state has value "pending".
///
/// @return Whether the union's current tag state has value "pending".
///
- (BOOL)isPending;

///
/// Retrieves whether the union's current tag state has value "metadata".
///
/// @note Call this method and ensure it returns true before accessing the
/// `metadata` property, otherwise a runtime exception will be thrown.
///
/// @return Whether the union's current tag state has value "metadata".
///
- (BOOL)isMetadata;

///
/// Retrieves string value of union's current tag state.
///
/// @return A human-readable string representing the union's current tag state.
///
- (NSString *)tagName;

@end

#pragma mark - Serializer Object

///
/// The serialization class for the `DBFILESMediaInfo` union.
///
@interface DBFILESMediaInfoSerializer : NSObject

///
/// Serializes `DBFILESMediaInfo` instances.
///
/// @param instance An instance of the `DBFILESMediaInfo` API object.
///
/// @return A json-compatible dictionary representation of the
/// `DBFILESMediaInfo` API object.
///
+ (NSDictionary *)serialize:(DBFILESMediaInfo *)instance;

///
/// Deserializes `DBFILESMediaInfo` instances.
///
/// @param dict A json-compatible dictionary representation of the
/// `DBFILESMediaInfo` API object.
///
/// @return An instantiation of the `DBFILESMediaInfo` object.
///
+ (DBFILESMediaInfo *)deserialize:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
