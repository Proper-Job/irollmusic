///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

#import <Foundation/Foundation.h>

#import "DBPAPERRefPaperDoc.h"
#import "DBSerializableProtocol.h"

@class DBPAPERExportFormat;
@class DBPAPERPaperDocExport;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - API Object

///
/// The `PaperDocExport` struct.
///
/// This class implements the `DBSerializable` protocol (serialize and
/// deserialize instance methods), which is required for all Obj-C SDK API route
/// objects.
///
@interface DBPAPERPaperDocExport : DBPAPERRefPaperDoc <DBSerializable, NSCopying>

#pragma mark - Instance fields

/// (no description).
@property (nonatomic, readonly) DBPAPERExportFormat *exportFormat;

#pragma mark - Constructors

///
/// Full constructor for the struct (exposes all instance variables).
///
/// @param docId The Paper doc ID.
/// @param exportFormat (no description).
///
/// @return An initialized instance.
///
- (instancetype)initWithDocId:(NSString *)docId exportFormat:(DBPAPERExportFormat *)exportFormat;

@end

#pragma mark - Serializer Object

///
/// The serialization class for the `PaperDocExport` struct.
///
@interface DBPAPERPaperDocExportSerializer : NSObject

///
/// Serializes `DBPAPERPaperDocExport` instances.
///
/// @param instance An instance of the `DBPAPERPaperDocExport` API object.
///
/// @return A json-compatible dictionary representation of the
/// `DBPAPERPaperDocExport` API object.
///
+ (NSDictionary *)serialize:(DBPAPERPaperDocExport *)instance;

///
/// Deserializes `DBPAPERPaperDocExport` instances.
///
/// @param dict A json-compatible dictionary representation of the
/// `DBPAPERPaperDocExport` API object.
///
/// @return An instantiation of the `DBPAPERPaperDocExport` object.
///
+ (DBPAPERPaperDocExport *)deserialize:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
