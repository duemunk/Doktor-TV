//
//  DataHandler.h
//  Doktor TV
//
//  Created by Tobias DM on 16/11/13.
//  Copyright (c) 2013 developmunk. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "Program.h"
#import "Season.h"
#import "Episode.h"

@interface DataHandler : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (DataHandler *)sharedInstance;

- (void)saveContext;
- (void)clearCoreData;

- (NSArray *)programs;

- (Program *)newProgram;
- (Program *)newProgramAssociated:(BOOL)associated;
- (Season *)newSeason;
- (Episode *)newEpisode;

- (void)associateObject:(NSManagedObject *)managedObject;

+ (BOOL)fileExists:(NSString *)filename persistent:(BOOL)persistent;
+ (NSString *)pathForFile:(NSString *)filename persistent:(BOOL)persistent;

- (void)clearCaches;
- (void)clearPersistent;
//- (void)cleanUpCachedLocalFiles;

@end
