///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

#import <Foundation/Foundation.h>

#import "DBSerializableProtocol.h"

@class DBTEAMRevokeDeviceSessionArg;
@class DBTEAMRevokeDeviceSessionBatchArg;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - API Object

///
/// The `RevokeDeviceSessionBatchArg` struct.
///
/// This class implements the `DBSerializable` protocol (serialize and
/// deserialize instance methods), which is required for all Obj-C SDK API route
/// objects.
///
@interface DBTEAMRevokeDeviceSessionBatchArg : NSObject <DBSerializable, NSCopying>

#pragma mark - Instance fields

/// (no description).
@property (nonatomic, readonly) NSArray<DBTEAMRevokeDeviceSessionArg *> *revokeDevices;

#pragma mark - Constructors

///
/// Full constructor for the struct (exposes all instance variables).
///
/// @param revokeDevices (no description).
///
/// @return An initialized instance.
///
- (instancetype)initWithRevokeDevices:(NSArray<DBTEAMRevokeDeviceSessionArg *> *)revokeDevices;

- (instancetype)init NS_UNAVAILABLE;

@end

#pragma mark - Serializer Object

///
/// The serialization class for the `RevokeDeviceSessionBatchArg` struct.
///
@interface DBTEAMRevokeDeviceSessionBatchArgSerializer : NSObject

///
/// Serializes `DBTEAMRevokeDeviceSessionBatchArg` instances.
///
/// @param instance An instance of the `DBTEAMRevokeDeviceSessionBatchArg` API
/// object.
///
/// @return A json-compatible dictionary representation of the
/// `DBTEAMRevokeDeviceSessionBatchArg` API object.
///
+ (NSDictionary *)serialize:(DBTEAMRevokeDeviceSessionBatchArg *)instance;

///
/// Deserializes `DBTEAMRevokeDeviceSessionBatchArg` instances.
///
/// @param dict A json-compatible dictionary representation of the
/// `DBTEAMRevokeDeviceSessionBatchArg` API object.
///
/// @return An instantiation of the `DBTEAMRevokeDeviceSessionBatchArg` object.
///
+ (DBTEAMRevokeDeviceSessionBatchArg *)deserialize:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
