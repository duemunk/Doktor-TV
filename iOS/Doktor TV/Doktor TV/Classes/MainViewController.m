//
//  MainViewController.m
//  Doktor TV
//
//  Created by Tobias DM on 16/11/13.
//  Copyright (c) 2013 developmunk. All rights reserved.
//

#import "MainViewController.h"

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
	[self addViewController:collectionViewController];
	[collectionViewController.view keepInsets:UIEdgeInsetsZero];
	
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

@end
