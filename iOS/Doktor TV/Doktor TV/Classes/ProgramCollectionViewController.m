//
//  ProgramCollectionViewController.m
//  Doktor TV
//
//  Created by Tobias DM on 16/11/13.
//  Copyright (c) 2013 developmunk. All rights reserved.
//

#import "ProgramCollectionViewController.h"

#import "EpisodeCollectionViewCell.h"
#import "DRHandler.h"

@interface ProgramCollectionViewController ()

@end

#define EPISODE_COLLECTION_CELL_ID @"EPISODE_COLLECTION_CELL_ID"

@implementation ProgramCollectionViewController

- (id)init
{
    self = [super initWithCollectionViewLayout:[self defaultLayout]];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
	self.collectionView.backgroundColor = [UIColor clearColor];
	self.collectionView.alwaysBounceVertical = YES;
	
	self.entity = @"Episode";
	self.sortKey = @"season.number";
	self.sortAscending = YES;
	
	[self updateToProgram];
	
	self.managedObjectContext = self.program.managedObjectContext;
	
	[self.collectionView registerClass:[EpisodeCollectionViewCell class] forCellWithReuseIdentifier:EPISODE_COLLECTION_CELL_ID];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
	[[DRHandler sharedInstance] validateEpisodesForProgram:self.program];
}

- (void)updateToProgram
{
	[self resetFetchResultsController];
	self.predicate = [NSPredicate predicateWithFormat:@"season.program = %@", self.program];
	[self.collectionView reloadData];
}


- (void)setProgram:(Program *)program
{
	if (program != _program) {
		_program = program;
		[self updateToProgram];
	}
}


- (UICollectionViewLayout *)defaultLayout
{
	UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
	layout.itemSize = CGSizeMake(130.0f, 100.0f);
	layout.minimumInteritemSpacing =
	layout.minimumLineSpacing = 20.0f;
	layout.sectionInset = UIEdgeInsetsMake(0.0f, 20.0f, 0.0f, 20.0f);
	layout.headerReferenceSize = CGSizeMake(10.0f, 10.0f);
	return layout;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[self.collectionView setCollectionViewLayout:[self defaultLayout] animated:YES];
}


// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	EpisodeCollectionViewCell *cell = (EpisodeCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:EPISODE_COLLECTION_CELL_ID forIndexPath:indexPath];
    
    Episode *episode = [self episodeForIndexPath:indexPath];
	if (episode) {
		cell.episode = episode;
	}
    
    return cell;
}

//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
//{
//	if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
//		UICollectionReusableView *header = [[UICollectionReusableView alloc] initWithFrame:CGRectMake(0, 0, 100, 10.0f)];
//		header.backgroundColor = [UIColor yellowColor];
//		return header;
//	}
//	return nil;
//}



- (Episode *)episodeForIndexPath:(NSIndexPath *)indexPath
{
	NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	if ([object isKindOfClass:[Episode class]]) {
		Episode *episode = (Episode *)object;
		return episode;
	}
	return nil;
}




@end
