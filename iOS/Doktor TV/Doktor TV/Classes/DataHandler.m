//
//  DataHandler.m
//  Doktor TV
//
//  Created by Tobias DM on 16/11/13.
//  Copyright (c) 2013 developmunk. All rights reserved.
//

#import "DataHandler.h"


@implementation DataHandler

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;



+ (DataHandler *)sharedInstance
{
    static DataHandler *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [DataHandler new];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}


- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			// Replace this implementation with code to handle the error appropriately.
			// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            DLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
		else
		{
			DLog(@"Saved context succesfully");
		}
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Model.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
	NSDictionary *options = @{ NSMigratePersistentStoresAutomaticallyOption : @YES, NSInferMappingModelAutomaticallyOption : @YES };
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        DLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}



#pragma mark - 

- (NSArray *)programs
{
	NSManagedObjectModel *model = self.managedObjectModel;
	
	NSFetchRequest *fetchRequest = [NSFetchRequest new];
	fetchRequest.entity = [model.entitiesByName objectForKey:@"Program"];
	
	NSError *error = nil;
	NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if (error)
	{
		DLog(@"Err %@",error.description);
	}
	return results;
}


- (Program *)newProgram
{
	return [self newProgramAssociated:YES];
}

- (Program *)newProgramAssociated:(BOOL)associated
{
	NSString *key = @"Program";
	if (associated)
		return (Program *)[self newManagedObjectWithKey:key];
	else
		return (Program *)[self newManagedObjectUnassociatedWithKey:key];
}
- (Season *)newSeason
{
	return (Season *)[self newManagedObjectWithKey:@"Season"];
}
- (Episode *)newEpisode
{
	return (Episode *)[self newManagedObjectWithKey:@"Episode"];
}


- (NSManagedObject *)newManagedObjectWithKey:(NSString *)key
{
	DLog(@"Key %@",key);
	NSManagedObjectModel *managedObjectModel = self.managedObjectContext.persistentStoreCoordinator.managedObjectModel;
	
	NSEntityDescription *entity = [[managedObjectModel entitiesByName] objectForKey:key];
	NSManagedObject *newMangedObject = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
	
	return newMangedObject;
}

- (NSManagedObject *)newManagedObjectUnassociatedWithKey:(NSString *)key
{
	DLog(@"Key %@",key);
	NSEntityDescription *entity = [NSEntityDescription entityForName:key inManagedObjectContext:self.managedObjectContext];
	NSManagedObject *unassociatedObject = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
	return unassociatedObject;
}
- (void)associateObject:(NSManagedObject *)managedObject
{
	[self.managedObjectContext insertObject:managedObject];
	[self saveContext];
}





#pragma mark - File Handling

+ (NSString *)documentPath
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *path = paths.firstObject;
	return path;
}

#define cacheDirectory @"Cache"
#define tempDirectory @"Temp"

+ (NSString *)cachePath
{
	NSString *cachePath = [[DataHandler documentPath] stringByAppendingPathComponent:cacheDirectory];
	if (![[NSFileManager defaultManager] fileExistsAtPath:cachePath])
	{
		NSError *error;
		[[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
	}
	return cachePath;
}
+ (NSString *)tempPath
{
	NSString *tempPath = [[DataHandler documentPath] stringByAppendingPathComponent:tempDirectory];
	if (![[NSFileManager defaultManager] fileExistsAtPath:tempPath])
	{
		NSError *error;
		[[NSFileManager defaultManager] createDirectoryAtPath:tempPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
	}
	return tempPath;
}

+ (NSString *)pathForTempFile:(NSString *)filename
{
	return [[DataHandler tempPath] stringByAppendingPathComponent:filename];
}
+ (NSString *)pathForCachedFile:(NSString *)filename
{
	return [[DataHandler cachePath] stringByAppendingPathComponent:filename];
}
+ (BOOL)fileExists:(NSString *)filename
{
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[DataHandler pathForCachedFile:filename] isDirectory:NO];
	return fileExists;
}



- (void)cleanUpCachedLocalFiles
{
	NSError *error;
	NSArray *allFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[DataHandler cachePath]
																			error:&error];
	
	NSMutableArray *invalidFiles = [allFiles pathsMatchingExtensions:@[@"jpg",@"mp4"]].mutableCopy;
	
	// TODO: on iOS file:///private/var/ vs. file:///var/
	for (Program *program in self.programs)
	{
		NSString *fileName = program.image;
		NSUInteger index = [invalidFiles indexOfObject:fileName];
		if (index != NSNotFound) {
			[invalidFiles removeObjectAtIndex:index];
		}
		
		for (Season *season in program.seasons) {
			for (Episode *episode in season.episodes) {
				NSString *fileName = episode.image;
				NSUInteger index = [invalidFiles indexOfObject:fileName];
				if (index != NSNotFound) {
					[invalidFiles removeObjectAtIndex:index];
				}
			}
		}
	}
	
	for (NSString *invalidFileName in invalidFiles)
	{
		NSError *error;
		DLog(@"Delete file %@",invalidFileName);
		[[NSFileManager defaultManager] removeItemAtPath:[DataHandler pathForCachedFile:invalidFileName]
												  error:&error];
	}
	
	// Clear temp folder
//	allFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[DataHandler tempPath]
//																			error:&error];
//	for (NSURL *invalidFileURL in allFiles)
//	{
//		NSError *error;
//		DLog(@"Delete temp file %@",invalidFileURL);
//		[[NSFileManager defaultManager] removeItemAtURL:invalidFileURL error:&error];
//	}
}

@end
