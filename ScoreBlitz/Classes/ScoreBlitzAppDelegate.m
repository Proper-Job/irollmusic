//
//  ScoreBlitzAppDelegate.m
//  ScoreBlitz
//
//  Created by Moritz Pfeiffer on 18.01.11.
//  Copyright 2011 Alp Phone. All rights reserved.
//

#import "ScoreBlitzAppDelegate.h"
#import <AFNetworking/AFNetworking.h>
#import <ISO8601/ISO8601.h>
#import "ScoreManager.h"
#import "SettingsManager.h"
#import "Score.h"
#import "NSString+Digest.h"
#import "Measure.h"
#import "CentralViewController.h"
#import "DropboxTransferManager.h"
#import "PerformancePagingViewController.h"
#import "PerformanceScrollingViewController.h"
#import "EditorViewController.h"
#import "FileImportViewController.h"
#import "MZFormSheetPresentationController.h"
#import "QueryHelper.h"
#import "Purchase.h"
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>
#import "TrackingManager.h"

@implementation ScoreBlitzAppDelegate

NSString *const FBSessionStateChangedNotification = @"ch.alp-phone.irollmusic:FBSessionStateChangedNotification";

#pragma mark -
#pragma mark Application lifecycle

- (id)init {
    self = [super init];
    if (self) {

    }
    return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{  
    // Registers app defaults
	[SettingsManager sharedInstance];
    [Helpers configureAppearances];
    [TrackingManager sharedInstance];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
    
#if CopySampleData 
    
    UIBackgroundTaskIdentifier taskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^(void)
    {
        if(APP_DEBUG) {
            NSLog(@"remaining processing time for application:didFinishLaunchWithOptions: %f",
                    [[UIApplication sharedApplication] backgroundTimeRemaining]);
        }
    }];
    
    if (UIBackgroundTaskInvalid == taskIdentifier) {
        if(APP_DEBUG) {
            NSLog(@"Couldn't register application:didFinishLaunchWithOptions: for background execution");
        }
    }
    
    // copy default database on first boot
    if ([[defaults objectForKey:kFirstBootFlag] boolValue]) {
        // write firstBoot flag
        [defaults setBool:NO forKey:kFirstBootFlag];
        
        // for a new install we don't need to migrate the database
        [defaults setBool:YES forKey:kDidMigrateMeasureToVersionOnePointOne];
        
        [defaults synchronize];
        
        NSString *dbPath = [[NSBundle mainBundle] pathForResource:kDataBaseFileName 
                                                           ofType:kDataBaseFileExtension 
                                                      inDirectory:kDefaultDataDirectory];
        
        // copy the files
        NSError *error = nil;
        
        NSString *newDbPath = [[[self applicationLibraryDirectory] path] stringByAppendingPathComponent:[dbPath lastPathComponent]];
        [[NSFileManager defaultManager] copyItemAtPath:dbPath 
                                                toPath:newDbPath 
                                                 error:&error];
        if (nil != error) {
            if(APP_DEBUG) {
                NSLog(@"Error while copying the default dataBase file: %@, %@", error, [error userInfo]);
            }
            error = nil;
        }
    }
    
    // copy default score data whenever the score is present in the db but missing from the fs    
    // [self performSelectorInBackground:@selector(copySampleData) withObject:nil];
    self.isCopyingDefaultData = YES;
    [self copySampleData];
    
    [[UIApplication sharedApplication] endBackgroundTask:taskIdentifier];
#endif
    
    // dropbox single sign on
    NSString *appKey = kDropBoxAppKey;
    [DBClientsManager setupWithAppKey:appKey];    
    
    // View Setup
    self.navigationController.delegate = self;
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    
	return YES;
}

- (BOOL)application:(UIApplication *)application 
			openURL:(NSURL *)newURL 
  sourceApplication:(NSString *)sourceApplication 
		 annotation:(id)annotation
{
    if (APP_DEBUG) {
        NSLog(@"%s: openURL: %@", __func__, newURL);
        NSLog(@"%s: sourceApplication: %@", __func__, sourceApplication);
    }
    
    // handling the pdf urls
	if (nil == newURL || self.isCopyingDefaultData ||
        ![[NSUserDefaults standardUserDefaults] boolForKey:kDidMigrateMeasureToVersionOnePointOne])
    {
        /// No check for analysing needed, analysing is always canceled when application enters background
		return FALSE;
	} else {
        
        DBOAuthResult *authResult = [DBClientsManager handleRedirectURL:newURL];
        if (authResult != nil) {
            if ([authResult isSuccess]) {
                NSLog(@"Success! User is logged into Dropbox.");
            } else if ([authResult isCancel]) {
                NSLog(@"Authorization flow was manually canceled by user!");
            } else if ([authResult isError]) {
                NSLog(@"Error: %@", authResult);
            }
        }
        
        if ([[ScoreManager sharedInstance] handleOpenURL:newURL]) {
            //[[ScoreManager sharedInstance] launchedWithUrl:newURL sourceApplication:sourceApplication];
            self.cachedImportFilePath = [newURL path];            
            return TRUE;
        }
        
        return FALSE;
	}
}

/*
 Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
 Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
 */
- (void)applicationWillResignActive:(UIApplication *)application {
    [[NSNotificationCenter defaultCenter] postNotificationName:kCancelScoreImportNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kCancelScoreAnalysingNotification object:nil];
    
    if ([[DropboxTransferManager sharedInstance] isTransfering]) {
        [[DropboxTransferManager sharedInstance] cancelTransfer];
    }
    
    [self saveContext];
}


- (void)applicationDidBecomeActive:(UIApplication *)application 
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults boolForKey:kDidMigrateMeasureToVersionOnePointOne]) {
        @autoreleasepool {

            if(APP_DEBUG) {
                NSLog(@"Migrating measures to data model 2");
            }
            NSDate *startDate = [NSDate date];
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            [fetchRequest setEntity:[Measure entityDescription]];

            
            NSError *error = nil;
            NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            if (nil == fetchedObjects) {
                if(APP_DEBUG) {
                    NSLog(@"%@ %s %d", error, __FUNCTION__, __LINE__);
                }
            }
            
            for (Measure *aMeasure in fetchedObjects) {
                NSInteger newBpm = [aMeasure.bpm intValue] - 60;
                aMeasure.bpm = [NSNumber numberWithInteger:newBpm];
            }        
            
            
            [[ScoreManager sharedInstance] saveTheFuckingContext];
            
            [userDefaults setBool:YES forKey:kDidMigrateMeasureToVersionOnePointOne];
            [userDefaults synchronize];

            if(APP_DEBUG) {
                NSDate *endDate = [NSDate date];
                NSTimeInterval duration = [endDate timeIntervalSinceDate:startDate];
                NSLog(@"Database migration for %d measures took %d:%d",
                        [fetchedObjects count], (NSInteger) (duration / 60.0), (NSInteger) duration % 60);
            }
        
        }
    }
    
    // Sample content had to marked as "do not backup" so it needs to be recreated in case it was deleted
    [[ScoreManager sharedInstance] copySampleData];
    
    // File import
    if (self.cachedImportFilePath == nil) {
        if ([FileImportViewController filesInDocumentsDirectory]) {
            [self showFoundNewScoresAlertView];
        }
    } else {
        NSArray *pdfFilePaths = @[];
        NSArray *irmFilePaths = @[];
        
        if ([kIrmFileExtensions containsObject:[self.cachedImportFilePath pathExtension]]) {
            irmFilePaths = @[self.cachedImportFilePath];
        } else {
            if ([Helpers verifyPdfFile:self.cachedImportFilePath]) {
                pdfFilePaths = @[self.cachedImportFilePath];
            } else {  // not a valid PDF file
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:MyLocalizedString(@"corruptPdfFileAlertViewTitle", nil)
                                                                               message:MyLocalizedString(@"corruptPdfFileAlertViewMessage", nil)
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* okAction = [UIAlertAction actionWithTitle:MyLocalizedString(@"buttonOkay", nil)
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:nil];
                [alert addAction:okAction];
                [self.navigationController.topViewController presentViewController:alert animated:YES completion:nil];
            }
        }
        
        if (([pdfFilePaths count] > 0) || ([irmFilePaths count] > 0)) {
            FileImportViewController *fileImportViewController = [[FileImportViewController alloc] initWithFilePaths:pdfFilePaths irmFilePaths:irmFilePaths];
            
            MZFormSheetPresentationController *formSheet = [[MZFormSheetPresentationController alloc] initWithContentViewController:fileImportViewController];
            formSheet.shouldCenterVertically = YES;
            
            [self.navigationController.topViewController presentViewController:formSheet animated:YES completion:nil];
        }
        self.cachedImportFilePath = nil;
    }
}


/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application
{
    [self saveContext];
}

- (void)copySampleData
{
    UIBackgroundTaskIdentifier taskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^(void) {
        if(APP_DEBUG) {
            NSLog(@"%s: remaining processing time for copySampleData %f", __func__, [[UIApplication sharedApplication] backgroundTimeRemaining]);
        }
    }];
    if (UIBackgroundTaskInvalid == taskIdentifier) {
        if(APP_DEBUG) {
            NSLog(@"%s: Couldn't register copySampleData for background execution", __func__);
        }
    }

    if(APP_DEBUG) {
        NSLog(@"%s: Starting copy sample data", __func__);
    }

    
    @autoreleasepool {
    
        NSArray *imageDirectories = [[NSBundle mainBundle] pathsForResourcesOfType:nil 
                                                                       inDirectory:kDefaultImageDirectory];
        NSString *scoresDirectoryPath = [[self applicationScoreDirectory] path];
        
        NSError *error = nil;
            
        // create score directory
        [[NSFileManager defaultManager] createDirectoryAtPath:scoresDirectoryPath 
                                  withIntermediateDirectories:YES 
                                                   attributes:nil 
                                                        error:&error];
        if (nil != error) {
            if(APP_DEBUG) {
                NSLog(@"%s: Error while creating Scores directory: %@, %@", __func__, error, [error userInfo]);
            }
            error = nil;
        } 
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:[Score entityDescription]];

        for (NSString *imageDirectoryPath in imageDirectories) {
            NSString *hash = [imageDirectoryPath lastPathComponent];
            NSString *destinationPath = [scoresDirectoryPath stringByAppendingPathComponent:hash];
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:destinationPath]) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sha1Hash == %@", hash];
                [fetchRequest setPredicate:predicate];
                NSError *fetchError = nil;
                NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
                if (1 == fetchedObjects.count) {
                    NSError *fileCopyError = nil;    
                    [[NSFileManager defaultManager] copyItemAtPath:imageDirectoryPath toPath:destinationPath error:&fileCopyError];
                    if (nil == fileCopyError) {
                        if(APP_DEBUG) {
                            NSLog(@"%s: Copying sample score directory: %@", __func__, destinationPath);
                        }
                    }else {
                        if(APP_DEBUG) {
                            NSLog(@"%s: Error while copying the sample score directory: %@, %@, %s, %d", __func__, fileCopyError, [fileCopyError userInfo], __func__, __LINE__);
                        }
                    }
                    
                    NSURL *destinationUrl = [NSURL fileURLWithPath:destinationPath];
                    if([[ScoreManager sharedInstance] addSkipBackupAttributeToItemAtURL:destinationUrl]) {
                        if(APP_DEBUG) {
                            NSLog(@"%s: Adding 'Do Not Backup' attribute to directory at url: %@", __func__, destinationUrl);
                        }
                    }else {
                        if(APP_DEBUG) {
                            NSLog(@"%s: Error adding 'Do Not Backup' attribute to directory at url: %@", __func__, destinationUrl);
                        }
                    }
                    
                }else if (0 == fetchedObjects.count) {
                    if(APP_DEBUG) {
                        NSLog(@"%s: Sample score has been user removed.  Hash: %@", __func__, hash);
                    }
                }else if (nil != fetchError) {
                    NSLog(@"%s: Error fetching sample score from database: %@, %@, %s, %d", __func__, fetchError, [fetchError userInfo], __func__, __LINE__);
                }
            }
        }

        if(APP_DEBUG) {
            NSLog(@"%s: Finished copy sample data", __func__);
        }
        self.isCopyingDefaultData = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:kDidFinischCopyingDefaultData object:self];
    }
    [[UIApplication sharedApplication] endBackgroundTask:taskIdentifier];
}


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    
    if (managedObjectContext_ != nil) {
        return managedObjectContext_;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext_ = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [managedObjectContext_ setPersistentStoreCoordinator:coordinator];
        // NSRollbackMergePolicy This policy discards all state for the changed objects in conflict. The persistent store's version of the object is used.
        [managedObjectContext_ setMergePolicy:NSRollbackMergePolicy];  // NSRollbackMergePolicy NSMergeByPropertyStoreTrumpMergePolicy
    }
    return managedObjectContext_;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel_ != nil) {
        return managedObjectModel_;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:kDataBaseFileName withExtension:@"momd"];
    managedObjectModel_ = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return managedObjectModel_;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    @synchronized(self) {
        if (persistentStoreCoordinator_ != nil) {
            return persistentStoreCoordinator_;
        }
        
        NSURL *storeURL = [[self applicationLibraryDirectory] URLByAppendingPathComponent:[kDataBaseFileName stringByAppendingPathExtension:kDataBaseFileExtension]];
        
        NSError *error = nil;
        
        persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
        
        if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             
             Typical reasons for an error here include:
             * The persistent store is not accessible;
             * The schema for the persistent store is incompatible with current managed object model.
             Check the error message to determine what the actual problem was.
             
             
             If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
             
             If you encounter schema incompatibility errors during development, you can reduce their frequency by:
             * Simply deleting the existing store:
             [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
             
             * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
             [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
             
             Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
             
             */
            if(APP_DEBUG) {
                NSLog(@"Unresolved error %@, %@, %s, %d", error, [error userInfo], __func__, __LINE__);
            }
        }    
        
        return persistentStoreCoordinator_;
    }
}


- (void)saveContext {
    
    NSError *error = nil;
	NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Main Context: Unresolved error %@, %@, %s, %d", error, [error userInfo], __func__, __LINE__);
        } 
    }
}   

#pragma mark -
#pragma mark Custom Accessors

- (CentralViewController *)centralViewController
{
	return [self.navigationController.viewControllers objectAtIndex:0];
}

#pragma mark -
#pragma mark Application's directories

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


/**
 Returns the path to the application's Library directory.
 */
- (NSURL *)applicationLibraryDirectory
{
	return [[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
}

/**
 Returns the path to the application's Score directory.
 */
- (NSURL *)applicationScoreDirectory
{
	return [[self applicationLibraryDirectory] URLByAppendingPathComponent:kApplicationScoresDirectory];
}

- (NSURL *)applicationImportDirectory
{
	return [[self applicationLibraryDirectory] URLByAppendingPathComponent:kApplicationImportDirectory];
}


- (void)dealloc {
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([viewController isKindOfClass:[CentralViewController class]]) {
        [navigationController setNavigationBarHidden:YES animated:YES];
    } else if ([viewController isKindOfClass:[PerformancePagingViewController class]]) {
        [navigationController setNavigationBarHidden:YES animated:YES];
    } else if ([viewController isKindOfClass:[PerformanceScrollingViewController class]]) {
        [navigationController setNavigationBarHidden:YES animated:YES];
    } else if ([viewController isKindOfClass:[EditorViewController class]]) {
        [navigationController setNavigationBarHidden:YES animated:YES];
    } else {
        [navigationController setNavigationBarHidden:NO animated:YES];
    }
}


#pragma mark - Score Import Handling

-(void)showFoundNewScoresAlertView
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:MyLocalizedString(@"FoundNewScoresAlertControllerTitle", nil)
                                                                   message:[NSString stringWithFormat:MyLocalizedString(@"FoundNewScoresAlertControllerMessage", nil), NumberOfSampleScores]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:MyLocalizedString(@"buttonOkay", nil)
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         NSArray *pdfFilePaths = [FileImportViewController pdfFilePaths];
                                                         NSArray *irmFilePaths = [FileImportViewController irmFilePaths];
                                                         NSInteger numberOfFiles = [pdfFilePaths count] + [irmFilePaths count];
                                                         
                                                         if (numberOfFiles > 0) {
                                                             FileImportViewController *fileImportViewController = [[FileImportViewController alloc] initWithFilePaths:pdfFilePaths irmFilePaths:irmFilePaths];
                                                             
                                                             MZFormSheetPresentationController *formSheet = [[MZFormSheetPresentationController alloc] initWithContentViewController:fileImportViewController];
                                                             formSheet.shouldCenterVertically = YES;
                                                             
                                                             [self.navigationController.topViewController presentViewController:formSheet animated:YES completion:nil];
                                                         }
                                                     }];
    [alert addAction:okAction];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:MyLocalizedString(@"buttonCancel", nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {}];
    [alert addAction:cancelAction];
    
    [self.navigationController.topViewController presentViewController:alert animated:YES completion:nil];    
}

@end

