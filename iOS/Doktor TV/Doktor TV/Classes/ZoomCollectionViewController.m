//
//  CollectionViewController.m
//  
//
//  Created by Tobias DM on 16/11/13.
//
//

#import "ZoomCollectionViewController.h"

@implementation ZoomCollectionViewController
{
    NSMutableArray *_objectChanges;
    NSMutableArray *_sectionChanges;
	
	BOOL isZooming;
	
	UICollectionViewLayout *defaultLayout;
}


- (instancetype)initWithCollectionViewLayoutDefaultLayout:(UICollectionViewLayout *)layout
{
	self = [super initWithCollectionViewLayout:layout];
	if (self) {
		defaultLayout = layout;
		_zoom = NO;
	}
	return self;
}


- (void)viewDidLoad
{
	_objectChanges = [NSMutableArray array];
    _sectionChanges = [NSMutableArray array];
	
	self.collectionView.backgroundColor = [UIColor clearColor];
	self.collectionView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	self.collectionView.alwaysBounceVertical = YES;
	self.view.clipsToBounds = YES;
	self.collectionView.clipsToBounds = YES;
	
	self.managedObjectContext = [DataHandler sharedInstance].managedObjectContext;
	
	[self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderIdentifier"];
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	UICollectionViewLayout *layout = self.isZoomed ? [self zoomedCollectionViewLayout] : defaultLayout;
	[self.collectionView setCollectionViewLayout:layout animated:YES];
}


#define kCache @"ProgramCache"
- (void)resetFetchResultsController
{
	[NSFetchedResultsController deleteCacheWithName:kCache];
	self.fetchedResultsController = nil;
}



- (UICollectionViewLayout *)zoomedCollectionViewLayout
{
	UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
	CGSize itemSize = self.collectionView.bounds.size;
	UIEdgeInsets insets = self.collectionView.contentInset;
	itemSize.height -= insets.top + insets.bottom;
	itemSize.width -= insets.left + insets.right;
	layout.itemSize = itemSize;
	layout.minimumInteritemSpacing =
	layout.minimumLineSpacing = 0.0f;
	layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
	layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
	return layout;
}





#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	NSUInteger count = self.fetchedResultsController.sections.count;
	DLog(@"%lu",(unsigned long)count);
    return count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
	NSUInteger count = [sectionInfo numberOfObjects];
	DLog(@"%lu",(unsigned long)count);
    return count;
}



// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	DLog(@"%ld,%ld",(long)indexPath.section,(long)indexPath.item);
	ZoomCollectionViewCell *cell = (ZoomCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:self.cellIdentifier forIndexPath:indexPath];
	
	cell.managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
	cell.zoom = self.isZoomed;
	cell.delegate = self;
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
	if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
		// FIX: Support changes from fetchcontroller
		UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"HeaderIdentifier" forIndexPath:indexPath];
		return header;
	}
	return nil;
}




#pragma mark - UICollectionViewDelegate



- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	self.zoom = !_zoom;
	
	ZoomCollectionViewCell *zoomCell = (ZoomCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
	if (zoomCell) {
		zoomCell.zoom = _zoom;
	}
}

- (void)setZoom:(BOOL)zoom
{
	if (!isZooming)
	{
		if (zoom != _zoom)
		{
			_zoom = zoom;
		
			__block UICollectionView *__collectionView = self.collectionView;
			isZooming = YES;
			if (!_zoom)
			{
				[self.collectionView setCollectionViewLayout:defaultLayout animated:YES completion:^(BOOL finished) {
					isZooming = NO;
					__collectionView.pagingEnabled = NO;
					__collectionView.alwaysBounceVertical = YES;
				}];
			}
			else
			{
				[self.collectionView setCollectionViewLayout:[self zoomedCollectionViewLayout] animated:YES completion:^(BOOL finished) {
					isZooming = NO;
					__collectionView.alwaysBounceVertical = NO;
					__collectionView.pagingEnabled = YES;
				}];
			}
		}
	}
}





#pragma mark - ZoomCollectionViewCellDelegate

- (void)zoomCollectionViewCell:(ZoomCollectionViewCell *)cell changedZoom:(BOOL)zoom
{
	self.zoom = cell.zoom;
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
	NSArray *sortDescriptors;
	if (_sortKey)
	{
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:self.sortKey ascending:self.sortAscending];
		sortDescriptors = @[sortDescriptor];
	}
    
    fetchRequest.sortDescriptors = sortDescriptors;
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:kCache];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
		// Replace this implementation with code to handle the error appropriately.
		// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
		DLog(@"Unresolved error %@, %@", error, [error userInfo]);
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
            change[@(type)] = @(sectionIndex);
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = @(sectionIndex);
            break;
    }
    
    [_sectionChanges addObject:change];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    NSMutableDictionary *change = [NSMutableDictionary new];
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = newIndexPath;
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeUpdate:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeMove:
            change[@(type)] = @[indexPath, newIndexPath];
            break;
    }
    [_objectChanges addObject:change];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if ([_sectionChanges count] > 0)
    {
        [self.collectionView performBatchUpdates:^{
            
            for (NSDictionary *change in _sectionChanges)
            {
                [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                    
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
    
    if ([_objectChanges count] > 0 && [_sectionChanges count] == 0)
    {
        
        if ([self shouldReloadCollectionViewToPreventKnownIssue] || self.collectionView.window == nil) {
            // This is to prevent a bug in UICollectionView from occurring.
            // The bug presents itself when inserting the first object or deleting the last object in a collection view.
            // http://stackoverflow.com/questions/12611292/uicollectionview-assertion-failure
            // This code should be removed once the bug has been fixed, it is tracked in OpenRadar
            // http://openradar.appspot.com/12954582
            [self.collectionView reloadData];
            
        } else {
			
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
								if (self.isZoomed)
									DLog(@"Didn't reload item at (%d,%d) since isZoomed",((NSIndexPath *)obj).section,((NSIndexPath *)obj).item);
								else
								{
									DLog(@"Request reload item at (%d,%d)",((NSIndexPath *)obj).section,((NSIndexPath *)obj).item);
									[self.collectionView reloadItemsAtIndexPaths:@[obj]];
								}
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
