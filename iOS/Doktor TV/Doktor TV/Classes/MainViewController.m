//
//  MainViewController.m
//  Doktor TV
//
//  Created by Tobias DM on 16/11/13.
//  Copyright (c) 2013 developmunk. All rights reserved.
//

#import "MainViewController.h"

#import "ProgramsCollectionViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController
{
	ProgramsCollectionViewController *collectionViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
	UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
	layout.itemSize = CGSizeMake(130, 130);
	collectionViewController = [[ProgramsCollectionViewController alloc] initWithCollectionViewLayout:layout];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:collectionViewController];
	[self addViewController:navigationController];
	[navigationController.view keepInsets:UIEdgeInsetsZero];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
