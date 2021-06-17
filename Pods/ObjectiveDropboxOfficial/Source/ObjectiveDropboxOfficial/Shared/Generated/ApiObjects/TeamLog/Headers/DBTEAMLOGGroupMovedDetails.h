///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

#import <Foundation/Foundation.h>

#import "DBSerializableProtocol.h"

@class DBTEAMLOGGroupMovedDetails;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - API Object

///
/// The `GroupMovedDetails` struct.
///
/// Moved a group.
///
/// This class implements the `DBSerializable` protocol (serialize and
/// deserialize instance methods), which is required for all Obj-C SDK API route
/// objects.
///
@interface DBTEAMLOGGroupMovedDetails : NSObject <DBSerializable, NSCopying>

#pragma mark - Instance fields

#pragma mark - Constructors

///
/// Full constructor for the struct (exposes all instance variables).
///
/// @return An initialized instance.
///
- (instancetype)initDefault;

- (instancetype)init NS_UNAVAILABLE;

@end

#pragma mark - Serializer Object

///
/// The serialization class for the `GroupMovedDetails` struct.
///
@interface DBTEAMLOGGroupMovedDetailsSerializer : NSObject

///
/// Serializes `DBTEAMLOGGroupMovedDetails` instances.
///
/// @param instance An instance of the `DBTEAMLOGGroupMovedDetails` API object.
///
/// @return A json-compatible dictionary representation of the
/// `DBTEAMLOGGroupMovedDetails` API object.
///
+ (NSDictionary *)serialize:(DBTEAMLOGGroupMovedDetails *)instance;

///
/// Deserializes `DBTEAMLOGGroupMovedDetails` instances.
///
/// @param dict A json-compatible dictionary representation of the
/// `DBTEAMLOGGroupMovedDetails` API object.
///
/// @return An instantiation of the `DBTEAMLOGGroupMovedDetails` object.
///
+ (DBTEAMLOGGroupMovedDetails *)deserialize:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END