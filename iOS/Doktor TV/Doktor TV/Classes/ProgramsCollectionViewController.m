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

@interface ProgramsCollectionViewController ()

@end

@implementation ProgramsCollectionViewController
{
	BOOL isBig;
}

- (instancetype)init
{
	self = [super initWithCollectionViewLayout:[self defaultCollectionViewLayout]];
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
	
	self.collectionView.alwaysBounceVertical = YES;
	
	[self.collectionView registerClass:[ProgramCollectionViewCell class] forCellWithReuseIdentifier:PROGRAM_COLLECTION_CELL_ID];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UICollectionViewLayout *)defaultCollectionViewLayout
{
	UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
	layout.itemSize = CGSizeMake(160, 120);
	layout.minimumInteritemSpacing =
	layout.minimumLineSpacing = 0.0f;
	return layout;
}
- (UICollectionViewLayout *)bigCollectionViewLayout
{
	UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
	CGSize itemSize = self.collectionView.bounds.size;
	itemSize.height -= self.topLayoutGuide.length;
	layout.itemSize = itemSize;
	layout.minimumInteritemSpacing =
	layout.minimumLineSpacing = 0.0f;
	layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
	layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
	return layout;
}


// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	ProgramCollectionViewCell *cell = (ProgramCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:PROGRAM_COLLECTION_CELL_ID forIndexPath:indexPath];
    
    Program *program = [self programForIndexPath:indexPath];
	if (program) {
		cell.program = program;
		cell.showContent = isBig;
	}
    
    return cell;
}



- (Program *)programForIndexPath:(NSIndexPath *)indexPath
{
	NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	if ([object isKindOfClass:[Program class]]) {
		Program *program = (Program *)object;
		return program;
	}
	return nil;
}





#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//	for (UICollectionViewCell *cell in [collectionView visibleCells] ) {
//		ProgramCollectionViewCell *programCell = (ProgramCollectionViewCell *)cell;
//		programCell.showContent = !isBig;
//	}
	
	ProgramCollectionViewCell *programCell = (ProgramCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
	if (programCell) {
		programCell.showContent = !isBig;
//		[[DRHandler sharedInstance] validateEpisodesForProgram:self.program];
	}
	
//	Program *program = [self programForIndexPath:indexPath];
//	[[DRHandler sharedInstance] validateEpisodesForProgram:program];
	
	
	if (isBig)
	{
		isBig = NO;
		[self.collectionView setCollectionViewLayout:[self defaultCollectionViewLayout] animated:YES completion:^(BOOL finished) {
			
			collectionView.pagingEnabled = NO;
			collectionView.alwaysBounceVertical = YES;
		}];
	}
	else
	{
		isBig = YES;
		[self.collectionView setCollectionViewLayout:[self bigCollectionViewLayout] animated:YES completion:^(BOOL finished) {
			
			collectionView.alwaysBounceVertical = NO;
			collectionView.pagingEnabled = YES;
		}];
	}
}

@end
