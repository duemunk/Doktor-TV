//
//  CollectionViewController.m
//  
//
//  Created by Tobias DM on 16/11/13.
//
//

#import "ZoomCollectionViewController.h"

@interface ZoomCollectionViewController ()

@property (assign, nonatomic) BOOL isZooming;

@end

@implementation ZoomCollectionViewController
{
    NSMutableArray *_objectChanges;
    NSMutableArray *_sectionChanges;
}


- (void)viewDidLoad
{
	[super viewDidLoad];
	
	_objectChanges = [NSMutableArray array];
    _sectionChanges = [NSMutableArray array];
	
	self.collectionView.backgroundColor = [UIColor clearColor];
	self.collectionView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	self.collectionView.alwaysBounceVertical = YES;
	self.view.clipsToBounds = YES;
	self.collectionView.clipsToBounds = YES;
	
	self.managedObjectContext = [DataHandler sharedInstance].managedObjectContext;
}



#define kCache @"ProgramCache"
- (void)resetFetchResultsController
{
	[NSFetchedResultsController deleteCacheWithName:kCache];
	self.fetchedResultsController = nil;
}




#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	NSUInteger count = self.fetchedResultsController.sections.count;
	DDLogVerbose(@"%lu",(unsigned long)count);
    return count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
	NSUInteger count = [sectionInfo numberOfObjects];
	DDLogVerbose(@"%lu",(unsigned long)count);
    return count;
}



// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	ZoomCollectionViewCell *cell = (ZoomCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
	cell.managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return cell;
}








#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
	// Clear cache – might be left over from previous crash
	[self resetFetchResultsController];
	
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:self.entity inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    // Set the batch size to a suitable number.
    fetchRequest.fetchBatchSize = 10;
	
	// Predicate
	if (_predicate)
		fetchRequest.predicate = self.predicate;
    
    // Edit the sort key as appropriate.
	NSMutableArray *sortDescriptors = [@[] mutableCopy];
	if (_sectionKey) {
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:self.sectionKey ascending:self.sectionAscending];
		[sortDescriptors addObject:sortDescriptor];
	}
	if (_sortKey)
	{
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:self.sortKey ascending:self.sortAscending];
		[sortDescriptors addObject:sortDescriptor];
	}
    
    fetchRequest.sortDescriptors = sortDescriptors;
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:self.sectionKey cacheName:kCache];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
		// Replace this implementation with code to handle the error appropriately.
		// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
		DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
    
    return _fetchedResultsController;
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    NSMutableDictionary *change = [NSMutableDictionary new];
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = @(sectionIndex); DDLogVerbose(@"Insert section %d",sectionIndex);
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = @(sectionIndex); DDLogVerbose(@"Delete section %d",sectionIndex);
            break;
    }
    
    [_sectionChanges addObject:change];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
	__block BOOL containedInInsert = NO, containedInDelete = NO;
	for (NSDictionary *change in _sectionChanges)
	{
		[change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop)
		 {
			 NSFetchedResultsChangeType type = [key unsignedIntegerValue];
			 NSUInteger sectionIndex = [obj unsignedIntegerValue];
			 switch (type)
			 {
				 case NSFetchedResultsChangeInsert:
					 if (sectionIndex == indexPath.section) containedInInsert = YES;
					 break;
				 case NSFetchedResultsChangeDelete:
					 if (sectionIndex == indexPath.section) containedInDelete = YES;
					 break;
			 }
		 }];
	}
	
    NSMutableDictionary *change = [NSMutableDictionary new];
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
		{
			if (!containedInInsert) {
				change[@(type)] = newIndexPath;
				DDLogVerbose(@"Insert section %d item %d",indexPath.section,indexPath.item);
			}
		}
            break;
        case NSFetchedResultsChangeDelete:
		{
			if (!containedInDelete) {
				change[@(type)] = indexPath;
				DDLogVerbose(@"Delete section %d item %d",indexPath.section,indexPath.item);
			}
		}
            break;
        case NSFetchedResultsChangeUpdate:
		{
            change[@(type)] = indexPath;
			DDLogVerbose(@"Update section %d item %d",indexPath.section,indexPath.item);
		}
            break;
        case NSFetchedResultsChangeMove:
		{
			if (!containedInInsert)
			{
				change[@(NSFetchedResultsChangeInsert)] = newIndexPath;
				DDLogVerbose(@"Insert section %d item %d",indexPath.section,indexPath.item);
			}
			if (!containedInDelete)
			{
				change[@(NSFetchedResultsChangeDelete)] = indexPath;
				DDLogVerbose(@"Delete section %d item %d",indexPath.section,indexPath.item);
			}
//			else
//			{
//				change[@(type)] = @[indexPath, newIndexPath]; DLog(@"Move section %d item %d to section %d item %d",indexPath.section,indexPath.item,newIndexPath.section,newIndexPath.item);
//			}
		}
            break;
    }
	if (change.count) {
		[_objectChanges addObject:change];
	}
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
//	[self.collectionView reloadData];
//	return;
	
	if (_sectionChanges.count > 0 && _objectChanges.count > 0)
	{
//		[self.collectionView performBatchUpdates:^{
//            
//			// Sections
//            for (NSDictionary *change in _sectionChanges)
//            {
//                [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop)
//				 {
//					 NSFetchedResultsChangeType type = [key unsignedIntegerValue];
//					 switch (type)
//					 {
//						 case NSFetchedResultsChangeInsert:
//							 [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
//							 break;
//						 case NSFetchedResultsChangeDelete:
//							 [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
//							 break;
//						 case NSFetchedResultsChangeUpdate:
//							 [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
//							 break;
//					 }
//				 }];
//            }
//			// Items
//			for (NSDictionary *change in _objectChanges)
//			{
//				[change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
//					
//					NSFetchedResultsChangeType type = [key unsignedIntegerValue];
//					switch (type)
//					{
//						case NSFetchedResultsChangeInsert:
//							[self.collectionView insertItemsAtIndexPaths:@[obj]];
//							break;
//						case NSFetchedResultsChangeDelete:
//							[self.collectionView deleteItemsAtIndexPaths:@[obj]];
//							break;
//						case NSFetchedResultsChangeUpdate:
//							[self.collectionView reloadItemsAtIndexPaths:@[obj]];
//							break;
//						case NSFetchedResultsChangeMove:
//							[self.collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
//							break;
//					}
//				}];
//			}
//			
//        } completion:nil];
		
		
		[self.collectionView reloadData];
		
		[_sectionChanges removeAllObjects];
		[_objectChanges removeAllObjects];
		return;
	}
	
    if (_sectionChanges.count > 0)
    {
        [self.collectionView performBatchUpdates:^{
            
            for (NSDictionary *change in _sectionChanges)
            {
                [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop)
				{
                    NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                    switch (type)
                    {
                        case NSFetchedResultsChangeInsert:
                            [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeDelete:
                            [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeUpdate:
                            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                    }
                }];
            }
        } completion:nil];
    }
    
    if (_objectChanges.count > 0 && _sectionChanges.count == 0)
    {
        if ([self shouldReloadCollectionViewToPreventKnownIssue] || self.collectionView.window == nil)
		{
            // This is to prevent a bug in UICollectionView from occurring.
            // The bug presents itself when inserting the first object or deleting the last object in a collection view.
            // http://stackoverflow.com/questions/12611292/uicollectionview-assertion-failure
            // This code should be removed once the bug has been fixed, it is tracked in OpenRadar
            // http://openradar.appspot.com/12954582
            [self.collectionView reloadData];
            
        }
		else
		{
            [self.collectionView performBatchUpdates:^{
                
                for (NSDictionary *change in _objectChanges)
                {
                    [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                        
                        NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                        switch (type)
                        {
                            case NSFetchedResultsChangeInsert:
                                [self.collectionView insertItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeDelete:
                                [self.collectionView deleteItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeUpdate:
//								if (self.isZoomed)
//									DLog(@"Didn't reload item at (%d,%d) since isZoomed",((NSIndexPath *)obj).section,((NSIndexPath *)obj).item);
//								else
//								{
//									DLog(@"Request reload item at (%d,%d)",((NSIndexPath *)obj).section,((NSIndexPath *)obj).item);
									[self.collectionView reloadItemsAtIndexPaths:@[obj]];
//								}
                                break;
                            case NSFetchedResultsChangeMove:
                                [self.collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                                break;
                        }
                    }];
                }
            } completion:nil];
        }
    }
	
    [_sectionChanges removeAllObjects];
    [_objectChanges removeAllObjects];
}

- (BOOL)shouldReloadCollectionViewToPreventKnownIssue
{
    __block BOOL shouldReload = NO;
    for (NSDictionary *change in _objectChanges) {
        [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSFetchedResultsChangeType type = [key unsignedIntegerValue];
            NSIndexPath *indexPath = obj;
            switch (type) {
                case NSFetchedResultsChangeInsert:
                    if ([self.collectionView numberOfItemsInSection:indexPath.section] == 0) {
                        shouldReload = YES;
                    } else {
                        shouldReload = NO;
                    }
                    break;
                case NSFetchedResultsChangeDelete:
                    if ([self.collectionView numberOfItemsInSection:indexPath.section] == 1) {
                        shouldReload = YES;
                    } else {
                        shouldReload = NO;
                    }
                    break;
                case NSFetchedResultsChangeUpdate:
                    shouldReload = NO;
                    break;
                case NSFetchedResultsChangeMove:
                    shouldReload = NO;
                    break;
            }
        }];
    }
    
    return shouldReload;
}

@end
