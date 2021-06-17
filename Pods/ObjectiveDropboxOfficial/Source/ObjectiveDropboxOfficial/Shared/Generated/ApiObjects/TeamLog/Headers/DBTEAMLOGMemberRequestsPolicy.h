///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

#import <Foundation/Foundation.h>

#import "DBSerializableProtocol.h"

@class DBTEAMLOGMemberRequestsPolicy;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - API Object

///
/// The `MemberRequestsPolicy` union.
///
/// This class implements the `DBSerializable` protocol (serialize and
/// deserialize instance methods), which is required for all Obj-C SDK API route
/// objects.
///
@interface DBTEAMLOGMemberRequestsPolicy : NSObject <DBSerializable, NSCopying>

#pragma mark - Instance fields

/// The `DBTEAMLOGMemberRequestsPolicyTag` enum type represents the possible tag
/// states with which the `DBTEAMLOGMemberRequestsPolicy` union can exist.
typedef NS_ENUM(NSInteger, DBTEAMLOGMemberRequestsPolicyTag) {
  /// (no description).
  DBTEAMLOGMemberRequestsPolicyDisabled,

  /// (no description).
  DBTEAMLOGMemberRequestsPolicyRequireApproval,

  /// (no description).
  DBTEAMLOGMemberRequestsPolicyAutoApproval,

  /// (no description).
  DBTEAMLOGMemberRequestsPolicyOther,

};

/// Represents the union's current tag state.
@property (nonatomic, readonly) DBTEAMLOGMemberRequestsPolicyTag tag;

#pragma mark - Constructors

///
/// Initializes union class with tag state of "disabled".
///
/// @return An initialized instance.
///
- (instancetype)initWithDisabled;

///
/// Initializes union class with tag state of "require_approval".
///
/// @return An initialized instance.
///
- (instancetype)initWithRequireApproval;

///
/// Initializes union class with tag state of "auto_approval".
///
/// @return An initialized instance.
///
- (instancetype)initWithAutoApproval;

///
/// Initializes union class with tag state of "other".
///
/// @return An initialized instance.
///
- (instancetype)initWithOther;

- (instancetype)init NS_UNAVAILABLE;

#pragma mark - Tag state methods

///
/// Retrieves whether the union's current tag state has value "disabled".
///
/// @return Whether the union's current tag state has value "disabled".
///
- (BOOL)isDisabled;

///
/// Retrieves whether the union's current tag state has value
/// "require_approval".
///
/// @return Whether the union's current tag state has value "require_approval".
///
- (BOOL)isRequireApproval;

///
/// Retrieves whether the union's current tag state has value "auto_approval".
///
/// @return Whether the union's current tag state has value "auto_approval".
///
- (BOOL)isAutoApproval;

///
/// Retrieves whether the union's current tag state has value "other".
///
/// @return Whether the union's current tag state has value "other".
///
- (BOOL)isOther;

///
/// Retrieves string value of union's current tag state.
///
/// @return A human-readable string representing the union's current tag state.
///
- (NSString *)tagName;

@end

#pragma mark - Serializer Object

///
/// The serialization class for the `DBTEAMLOGMemberRequestsPolicy` union.
///
@interface DBTEAMLOGMemberRequestsPolicySerializer : NSObject

///
/// Serializes `DBTEAMLOGMemberRequestsPolicy` instances.
///
/// @param instance An instance of the `DBTEAMLOGMemberRequestsPolicy` API
/// object.
///
/// @return A json-compatible dictionary representation of the
/// `DBTEAMLOGMemberRequestsPolicy` API object.
///
+ (NSDictionary *)serialize:(DBTEAMLOGMemberRequestsPolicy *)instance;

///
/// Deserializes `DBTEAMLOGMemberRequestsPolicy` instances.
///
/// @param dict A json-compatible dictionary representation of the
/// `DBTEAMLOGMemberRequestsPolicy` API object.
///
/// @return An instantiation of the `DBTEAMLOGMemberRequestsPolicy` object.
///
+ (DBTEAMLOGMemberRequestsPolicy *)deserialize:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
