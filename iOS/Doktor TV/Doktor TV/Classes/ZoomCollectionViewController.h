//
//  CollectionViewController.h
//  
//
//  Created by Tobias DM on 16/11/13.
//
//

@import UIKit;

#import "DataHandler.h"

@interface ZoomCollectionViewController : UICollectionViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) NSString *entity;
@property (nonatomic, strong) NSPredicate *predicate;
@property (nonatomic, strong) NSString *sortKey;
@property (nonatomic, assign) BOOL sortAscending;

@property (nonatomic, assign) UICollectionViewLayout *defaultCollectionViewLayout;

@property (nonatomic, assign) NSString *cellIdentifier;

- (void)resetFetchResultsController;

@end
