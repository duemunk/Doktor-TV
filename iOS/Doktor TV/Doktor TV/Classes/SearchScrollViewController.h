//
//  SearchScrollViewController.h
//  Doktor TV
//
//  Created by Tobias DM on 20/11/13.
//  Copyright (c) 2013 developmunk. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SearchDelegate;


@interface SearchScrollViewController : UIViewController <UIScrollViewDelegate, UISearchBarDelegate>

@property (nonatomic, strong, readonly) UIScrollView *scrollView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, assign, getter = isSearchBarVisible) BOOL searchBarVisible;
@property (nonatomic, readonly, getter = isSearcing) BOOL search;
@property (nonatomic, strong) id<SearchDelegate> delegate;

@end


@protocol SearchDelegate <NSObject>

- (void)searchedText:(NSString *)searchString;

@end


