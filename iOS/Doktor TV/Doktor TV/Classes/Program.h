//
//  Program.h
//  Doktor TV
//
//  Created by Tobias DM on 18/11/13.
//  Copyright (c) 2013 developmunk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Season;

@interface Program : NSManagedObject

@property (nonatomic, retain) NSString * drID;
@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) NSString * slug;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSOrderedSet *seasons;
@end

@interface Program (CoreDataGeneratedAccessors)

- (void)insertObject:(Season *)value inSeasonsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromSeasonsAtIndex:(NSUInteger)idx;
- (void)insertSeasons:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeSeasonsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInSeasonsAtIndex:(NSUInteger)idx withObject:(Season *)value;
- (void)replaceSeasonsAtIndexes:(NSIndexSet *)indexes withSeasons:(NSArray *)values;
- (void)addSeasonsObject:(Season *)value;
- (void)removeSeasonsObject:(Season *)value;
- (void)addSeasons:(NSOrderedSet *)values;
- (void)removeSeasons:(NSOrderedSet *)values;
@end
