///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

#import <Foundation/Foundation.h>

#import "DBSerializableProtocol.h"

@class DBTEAMLOGGroupAddMemberDetails;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - API Object

///
/// The `GroupAddMemberDetails` struct.
///
/// Added team members to a group.
///
/// This class implements the `DBSerializable` protocol (serialize and
/// deserialize instance methods), which is required for all Obj-C SDK API route
/// objects.
///
@interface DBTEAMLOGGroupAddMemberDetails : NSObject <DBSerializable, NSCopying>

#pragma mark - Instance fields

/// Is group owner.
@property (nonatomic, readonly) NSNumber *isGroupOwner;

#pragma mark - Constructors

///
/// Full constructor for the struct (exposes all instance variables).
///
/// @param isGroupOwner Is group owner.
///
/// @return An initialized instance.
///
- (instancetype)initWithIsGroupOwner:(NSNumber *)isGroupOwner;

- (instancetype)init NS_UNAVAILABLE;

@end

#pragma mark - Serializer Object

///
/// The serialization class for the `GroupAddMemberDetails` struct.
///
@interface DBTEAMLOGGroupAddMemberDetailsSerializer : NSObject

///
/// Serializes `DBTEAMLOGGroupAddMemberDetails` instances.
///
/// @param instance An instance of the `DBTEAMLOGGroupAddMemberDetails` API
/// object.
///
/// @return A json-compatible dictionary representation of the
/// `DBTEAMLOGGroupAddMemberDetails` API object.
///
+ (NSDictionary *)serialize:(DBTEAMLOGGroupAddMemberDetails *)instance;

///
/// Deserializes `DBTEAMLOGGroupAddMemberDetails` instances.
///
/// @param dict A json-compatible dictionary representation of the
/// `DBTEAMLOGGroupAddMemberDetails` API object.
///
/// @return An instantiation of the `DBTEAMLOGGroupAddMemberDetails` object.
///
+ (DBTEAMLOGGroupAddMemberDetails *)deserialize:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
