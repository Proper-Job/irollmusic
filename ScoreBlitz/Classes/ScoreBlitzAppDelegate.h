//
//  ScoreBlitzAppDelegate.h
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 18.01.11.
//  Copyright 2011 Alp Phone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <StoreKit/StoreKit.h>

@class CentralViewController;

@interface ScoreBlitzAppDelegate : NSObject <UIApplicationDelegate, UINavigationControllerDelegate> {
    
@private
    NSManagedObjectContext *managedObjectContext_;
    NSManagedObjectModel *managedObjectModel_;
    NSPersistentStoreCoordinator *persistentStoreCoordinator_;
}

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet UINavigationController *navigationController;

@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) SKProductsResponse *skProductsResponse;
@property (strong, nonatomic) SKReceiptRefreshRequest *receiptRefreshRequest;

@property (nonatomic, strong) NSString *cachedImportFilePath;

@property (assign) BOOL isCopyingDefaultData;

- (CentralViewController *)centralViewController;

- (NSURL *)applicationDocumentsDirectory;
- (NSURL *)applicationLibraryDirectory;
- (NSURL *)applicationScoreDirectory;
- (NSURL *)applicationImportDirectory;

- (void)saveContext;

@end

