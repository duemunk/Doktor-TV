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
#import "CollectionHeaderView.h"
#define PROGRAM_COLLECTION_HEADER_ID @"PROGRAM_COLLECTION_HEADER_ID"


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
	self.sectionKey = @"subscribe";
	
	self.cellIdentifier = PROGRAM_COLLECTION_CELL_ID;
	[self.collectionView registerClass:[ProgramCollectionViewCell class] forCellWithReuseIdentifier:self.cellIdentifier];
	[self.collectionView registerClass:[CollectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:PROGRAM_COLLECTION_HEADER_ID];
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



#pragma mark - UICollectionViewDataSource

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
	if ([kind isEqualToString:UICollectionElementKindSectionHeader])
	{
		if (self.fetchedResultsController.sections.count > 1)
		{
			id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[indexPath.section];
			
			// FIX: Support changes from fetchcontroller
			CollectionHeaderView *header = (CollectionHeaderView *)[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:PROGRAM_COLLECTION_HEADER_ID forIndexPath:indexPath];
			
			header.title = [sectionInfo name].boolValue ? @"Favoritter" : @"";
			return header;
		}
		else
			return [super collectionView:collectionView viewForSupplementaryElementOfKind:kind atIndexPath:indexPath];
	}
	return nil;
}


#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
	if (self.fetchedResultsController.sections.count > 1 && !self.isZoomed) {
		CGSize size = collectionView.bounds.size;
		size.height = 60;
		return size;
	}

	return CGSizeZero;
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
