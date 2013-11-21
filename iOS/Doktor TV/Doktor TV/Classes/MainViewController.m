//
//  MainViewController.m
//  Doktor TV
//
//  Created by Tobias DM on 16/11/13.
//  Copyright (c) 2013 developmunk. All rights reserved.
//

#import "MainViewController.h"

#import "SearchScrollViewController.h"
#import "ProgramsCollectionViewController.h"

#import "DRHandler.h"

@interface MainViewController ()

@end

@implementation MainViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// Do any additional setup after loading the view.
	self.view.backgroundColor = [UIColor blackColor];
	
	ProgramsCollectionViewController *collectionViewController = [ProgramsCollectionViewController new];
	SearchScrollViewController *searchController = [SearchScrollViewController new];
	[searchController addViewController:collectionViewController];
	[self addViewController:searchController];
	[searchController.view keepInsets:UIEdgeInsetsZero];
	searchController.delegate = collectionViewController;
	
//	collectionViewController.program = [[DataHandler sharedInstance] programs][1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
	[DRHandler sharedInstance];
}

- (NSUInteger)supportedInterfaceOrientations
{
	return isPhone ? UIInterfaceOrientationMaskPortrait : UIInterfaceOrientationMaskAll;
}

@end
