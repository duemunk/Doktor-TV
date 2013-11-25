//
//  CollectionViewController.m
//  Doktor TV
//
//  Created by Tobias DM on 16/11/13.
//  Copyright (c) 2013 developmunk. All rights reserved.
//

#import "ProgramsCollectionViewController.h"

#import "DRHandler.h"

#import "ProgramCollectionViewCell.h"
#define PROGRAM_COLLECTION_CELL_ID @"PROGRAM_COLLECTION_CELL_ID"


#define SEARCH_BAR_HEIGHT 60.0f


@implementation ProgramsCollectionViewController
{
	UISearchDisplayController *searchController;
	UISearchBar *_searchBar;
}

- (instancetype)init
{
	UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
	layout.itemSize = isPhone ? CGSizeMake(160, 120) : CGSizeMake(256, 192);
	layout.minimumInteritemSpacing =
	layout.minimumLineSpacing = 0.0f;
	
	self = [super initWithCollectionViewLayoutDefaultLayout:layout];
	if (self) {
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
	self.entity = @"Program";
	self.sortKey = @"title";
	self.sortAscending = YES;
	
	self.cellIdentifier = PROGRAM_COLLECTION_CELL_ID;
	[self.collectionView registerClass:[ProgramCollectionViewCell class] forCellWithReuseIdentifier:self.cellIdentifier];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)setZoom:(BOOL)zoom
{
	
	[super setZoom:zoom];
}




#pragma mark - SearchDelegate

- (void)searchedText:(NSString *)searchString
{
	NSPredicate *predicate = nil;
	if ([searchString length])
		predicate = [NSPredicate predicateWithFormat:@"title contains[cd] %@",searchString];
	else
		_searchBar.text = nil; // Force to reflect state of search
	
	[self resetFetchResultsController];
	self.predicate = predicate;
	[self.collectionView reloadData];
}


@end
