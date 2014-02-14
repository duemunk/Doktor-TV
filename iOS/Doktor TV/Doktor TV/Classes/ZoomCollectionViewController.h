//
//  CollectionViewController.h
//  
//
//  Created by Tobias DM on 16/11/13.
//
//

@import UIKit;

#import "DataHandler.h"
#import "TDMZoomCollectionViewController.h"
#import "ZoomCollectionViewCell.h"

@interface ZoomCollectionViewController : TDMZoomCollectionViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) NSString *entity;
@property (nonatomic, strong) NSPredicate *predicate;
@property (nonatomic, strong) NSString *sortKey;
@property (nonatomic, assign) BOOL sortAscending;
@property (nonatomic, strong) NSString *sectionKey;
@property (nonatomic, assign) BOOL sectionAscending;

- (void)resetFetchResultsController;

@end
