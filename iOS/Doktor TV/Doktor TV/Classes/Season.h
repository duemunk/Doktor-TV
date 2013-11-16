//
//  Season.h
//  Doktor TV
//
//  Created by Tobias DM on 16/11/13.
//  Copyright (c) 2013 developmunk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Season : NSManagedObject

@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) NSManagedObject *program;
@property (nonatomic, retain) NSOrderedSet *episodes;
@end

@interface Season (CoreDataGeneratedAccessors)

- (void)insertObject:(NSManagedObject *)value inEpisodesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromEpisodesAtIndex:(NSUInteger)idx;
- (void)insertEpisodes:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeEpisodesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInEpisodesAtIndex:(NSUInteger)idx withObject:(NSManagedObject *)value;
- (void)replaceEpisodesAtIndexes:(NSIndexSet *)indexes withEpisodes:(NSArray *)values;
- (void)addEpisodesObject:(NSManagedObject *)value;
- (void)removeEpisodesObject:(NSManagedObject *)value;
- (void)addEpisodes:(NSOrderedSet *)values;
- (void)removeEpisodes:(NSOrderedSet *)values;
@end
