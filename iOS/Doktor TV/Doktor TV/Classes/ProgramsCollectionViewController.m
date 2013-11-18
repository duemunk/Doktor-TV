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

@implementation ProgramsCollectionViewController

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

@end
