//
//  CollectionViewController.h
//  Doktor TV
//
//  Created by Tobias DM on 16/11/13.
//  Copyright (c) 2013 developmunk. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ZoomCollectionViewController.h"

@interface ProgramsCollectionViewController : ZoomCollectionViewController <UISearchBarDelegate>

@property (nonatomic, assign, getter = isSearchBarEnabled) BOOL searchBarEnabled;


@end
