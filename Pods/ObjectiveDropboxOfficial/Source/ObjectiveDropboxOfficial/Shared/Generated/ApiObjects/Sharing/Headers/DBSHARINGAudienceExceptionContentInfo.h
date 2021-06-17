///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

#import <Foundation/Foundation.h>

#import "DBSerializableProtocol.h"

@class DBSHARINGAudienceExceptionContentInfo;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - API Object

///
/// The `AudienceExceptionContentInfo` struct.
///
/// Information about the content that has a link audience different than that
/// of this folder.
///
/// This class implements the `DBSerializable` protocol (serialize and
/// deserialize instance methods), which is required for all Obj-C SDK API route
/// objects.
///
@interface DBSHARINGAudienceExceptionContentInfo : NSObject <DBSerializable, NSCopying>

#pragma mark - Instance fields

/// The name of the content, which is either a file or a folder.
@property (nonatomic, readonly, copy) NSString *name;

#pragma mark - Constructors

///
/// Full constructor for the struct (exposes all instance variables).
///
/// @param name The name of the content, which is either a file or a folder.
///
/// @return An initialized instance.
///
- (instancetype)initWithName:(NSString *)name;

- (instancetype)init NS_UNAVAILABLE;

@end

#pragma mark - Serializer Object

///
/// The serialization class for the `AudienceExceptionContentInfo` struct.
///
@interface DBSHARINGAudienceExceptionContentInfoSerializer : NSObject

///
/// Serializes `DBSHARINGAudienceExceptionContentInfo` instances.
///
/// @param instance An instance of the `DBSHARINGAudienceExceptionContentInfo`
/// API object.
///
/// @return A json-compatible dictionary representation of the
/// `DBSHARINGAudienceExceptionContentInfo` API object.
///
+ (NSDictionary *)serialize:(DBSHARINGAudienceExceptionContentInfo *)instance;

///
/// Deserializes `DBSHARINGAudienceExceptionContentInfo` instances.
///
/// @param dict A json-compatible dictionary representation of the
/// `DBSHARINGAudienceExceptionContentInfo` API object.
///
/// @return An instantiation of the `DBSHARINGAudienceExceptionContentInfo`
/// object.
///
+ (DBSHARINGAudienceExceptionContentInfo *)deserialize:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
