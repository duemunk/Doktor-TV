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


- (instancetype)init
{
	UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
	layout.itemSize = CGSizeMake(130.0f, 100.0f);
	layout.minimumInteritemSpacing =
	layout.minimumLineSpacing = 20.0f;
	layout.sectionInset = UIEdgeInsetsMake(0.0f, 20.0f, 20.0f, 20.0f);
	
	self = [super initWithCollectionViewLayoutDefaultLayout:layout];
	if (self) {
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view
	
	self.entity = @"Episode";
	self.sortKey = @"number";
	self.sortAscending = YES;
	
	self.managedObjectContext = [DataHandler sharedInstance].managedObjectContext;
	
	self.cellIdentifier = EPISODE_COLLECTION_CELL_ID;
	[self.collectionView registerClass:[EpisodeCollectionViewCell class] forCellWithReuseIdentifier:self.cellIdentifier];
	
	[self updateToProgram];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)viewDidAppear:(BOOL)animated
//{
//	[self resetFetchResultsController];
//	[[DRHandler sharedInstance] validateEpisodesForProgram:self.program];
//}

- (void)updateToProgram
{
	[self resetFetchResultsController];
	self.predicate = [NSPredicate predicateWithFormat:@"season.program = %@", self.program];
	[self.collectionView reloadData];
	
	if (self.program)
	{
		[[DRHandler sharedInstance] validateEpisodesForProgram:self.program];
	}
}

- (void)setProgram:(Program *)program
{
	if (program != _program) {
		_program = program;
		[self updateToProgram];
	}
}


@end
