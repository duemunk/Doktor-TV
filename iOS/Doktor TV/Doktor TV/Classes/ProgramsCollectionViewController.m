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


#define SEARCH_BAR_HEIGHT 60.0f


@implementation ProgramsCollectionViewController
{
	UISearchDisplayController *searchController;
	UISearchBar *_searchBar;
}

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
	
	self.searchBarEnabled = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setSearchBarEnabled:(BOOL)searchBarEnabled
{
	if (searchBarEnabled != _searchBarEnabled)
	{
		_searchBarEnabled = searchBarEnabled;
		
		if (_searchBarEnabled)
		{
			// SEARCH
			if (!_searchBar)
			{
				_searchBar = [UISearchBar new];
				_searchBar.placeholder = NSLocalizedString(@"Søg", @"Search");
				_searchBar.barStyle = UIBarStyleBlack;
				[self.view insertSubview:_searchBar aboveSubview:self.collectionView];
				_searchBar.keepTopInset.equal = KeepRequired(-SEARCH_BAR_HEIGHT);
				_searchBar.keepHeight.equal = KeepRequired(SEARCH_BAR_HEIGHT);
				_searchBar.keepHorizontalInsets.min = KeepRequired(0.0f);
				_searchBar.keepHorizontalInsets.equal = KeepLow(0.0f);
				_searchBar.keepWidth.max = KeepHigh(320.0f);
				[_searchBar keepHorizontallyCenteredWithPriority:KeepPriorityLow];
				
				_searchBar.barTintColor = [UIColor clearColor];
				_searchBar.tintColor = [UIColor whiteColor]; // Tints blinking | and "Cancel"

				[self setSearchBackgroundColor:[self.view.tintColor colorWithAlphaComponent:0.5f]];
				
				_searchBar.delegate = self;
			}
			
			// Hide search bar on intial
			UIEdgeInsets inset = self.collectionView.contentInset;
			inset.top = SEARCH_BAR_HEIGHT;
			self.collectionView.contentInset = inset;
			[self hideSearchBar:YES animated:NO];
		}
		else
		{
			self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
		}
		if (_searchBar)
			_searchBar.hidden = !_searchBarEnabled;
	}
}


- (void)setZoom:(BOOL)zoom
{
	if (zoom && self.isSearchBarEnabled && [_searchBar.text isEqualToString:@""])
	{
		self.searchBarEnabled = NO;
	}
	else if (!zoom && !self.isSearchBarEnabled)
		self.searchBarEnabled = YES;
	
	[super setZoom:zoom];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if (self.isSearchBarEnabled)
	{
		_searchBar.keepTopInset.equal = KeepRequired(-scrollView.contentOffset.y-SEARCH_BAR_HEIGHT);
		if (_searchBar.isFirstResponder) {
			[_searchBar resignFirstResponder];
		}
		
		if (scrollView.contentOffset.y < 0)
			self.collectionView.directionalLockEnabled = YES;
		else
			self.collectionView.directionalLockEnabled = NO;
		
	}
}


- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
	if (self.searchBarEnabled)
	{
		CGFloat target = targetContentOffset->y;
		CGFloat newOffset = -1.0f;
		if (target <= -SEARCH_BAR_HEIGHT) // Target will never be smaller than -SEARCH_BAR_HEIGHT
			newOffset = -SEARCH_BAR_HEIGHT;
		else if (target < SEARCH_BAR_HEIGHT)
			newOffset = 0.0f;
		
		if (newOffset != -1.0f)
		{
			if ((velocity.y > 0 && targetContentOffset->y > newOffset) ||
				(velocity.y < 0 && targetContentOffset->y < newOffset))
			{
				// Changing direction of motion causes the jump to final without animation
				// First, stop at current position
				targetContentOffset->y = scrollView.contentOffset.y;
				// Call change with animation directly
				[scrollView setContentOffset:CGPointMake(0,newOffset) animated:YES];
			}
			else
				targetContentOffset->y = newOffset;
		}
	}
}



- (void)setSearchBackgroundColor:(UIColor *)backgroundColor
{
	for (UIView *subview in [_searchBar.subviews.lastObject subviews])
	{
		if ([subview isKindOfClass:[UITextField class]]) {
			UITextField *textField = (UITextField*)subview;
			textField.backgroundColor = backgroundColor;
		}
	}
}



- (void)hideSearchBar:(BOOL)hideSearchBar animated:(BOOL)animated
{
	CGPoint offset = self.collectionView.contentOffset;
	offset.y = hideSearchBar ? 0 : -SEARCH_BAR_HEIGHT;
	[self.collectionView setContentOffset:offset animated:animated];
}





#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
	[self startSearch];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	[self searchString:searchText];
}

//- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
//{
//	[self stopSearch];
//}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
	[self stopSearch];
}


- (void)startSearch
{
	[_searchBar setShowsCancelButton:YES animated:YES];
	self.collectionView.directionalLockEnabled = YES;
}

- (void)stopSearch
{
	[self searchString:nil];
	[_searchBar setShowsCancelButton:NO animated:YES];
	[_searchBar resignFirstResponder];
	[self hideSearchBar:YES animated:YES];
	
	self.collectionView.directionalLockEnabled = NO;
}

- (void)searchString:(NSString *)searchString
{
	NSPredicate *predicate = nil;
	if ([searchString length])
		predicate = [NSPredicate predicateWithFormat:@"title contains[cd] %@",searchString];
	else
		_searchBar.text = nil; // Force to reflect state of search
	
	[self resetFetchResultsController];
	self.predicate = predicate;
	[self.collectionView reloadData];
}


@end
