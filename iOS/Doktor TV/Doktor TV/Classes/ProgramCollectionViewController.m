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


- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
	self = [super init];
	if (self) {
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view
	
	self.entity = @"Episode";
	self.sortKey = @"season.number";
	self.sortAscending = YES;
	
	[self updateToProgram];
	
	self.managedObjectContext = self.program.managedObjectContext;
	
	self.cellIdentifier = EPISODE_COLLECTION_CELL_ID;
	[self.collectionView registerClass:[EpisodeCollectionViewCell class] forCellWithReuseIdentifier:self.cellIdentifier];
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


- (UICollectionViewLayout *)defaultCollectionViewLayout
{
	UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
	layout.itemSize = CGSizeMake(130.0f, 100.0f);
	layout.minimumInteritemSpacing =
	layout.minimumLineSpacing = 20.0f;
	layout.sectionInset = UIEdgeInsetsMake(0.0f, 20.0f, 0.0f, 20.0f);
	layout.headerReferenceSize = CGSizeMake(10.0f, 10.0f);
	return layout;
}




@end
