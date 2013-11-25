//
//  SearchScrollViewController.m
//  Doktor TV
//
//  Created by Tobias DM on 20/11/13.
//  Copyright (c) 2013 developmunk. All rights reserved.
//

#import "SearchScrollViewController.h"

#import "TDMScreenEdgePanGestureRecognizer.h"

#define SEARCH_BAR_HEIGHT 60.0f

@interface SearchScrollViewController ()

@property (nonatomic, assign) BOOL userInteractionEnabledForSubviews;

@end

@implementation SearchScrollViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
	self.view = [UIScrollView new];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
	self.scrollView.alwaysBounceVertical = YES;
	self.scrollView.delegate = self;
	self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
	[self setupSearchBar];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self updateContentSize];
	_searchBarVisible = YES;
	self.searchBarVisible = NO;
	
	
	TDMScreenEdgePanGestureRecognizer *edgePan = [[TDMScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(pannedFromTop:)];
	[self.scrollView addGestureRecognizer:edgePan];
	edgePan.edges = UIRectEdgeTop;
	[edgePan requireToFailSubScrollViewsPanGestures];
	[self.scrollView.panGestureRecognizer requireGestureRecognizerToFail:edgePan];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)addViewController:(UIViewController *)viewController
{
	[super addViewController:viewController];
	
	CGRect r = self.scrollView.bounds;
	r.origin.y = SEARCH_BAR_HEIGHT;
	viewController.view.frame = r;
}

- (UIScrollView *)scrollView
{
	if ([self.view isKindOfClass:[UIScrollView class]]) {
		return (UIScrollView *)self.view;
	}
	return nil;
}



- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[self updateContentSize];
}

- (void)updateContentSize
{
	CGSize contentSize = self.view.bounds.size;
	contentSize.height += SEARCH_BAR_HEIGHT;
	self.scrollView.contentSize = contentSize;
}


- (UISearchBar *)searchBar
{
	// SEARCH
	[self setupSearchBar];
	return _searchBar;
}

- (void)setupSearchBar
{
	if (!_searchBar)
	{
		_searchBar = [UISearchBar new];
		_searchBar.placeholder = NSLocalizedString(@"Søg", @"Search");
		_searchBar.barStyle = UIBarStyleBlack;
		[self.scrollView addSubview:_searchBar];
		[_searchBar keepHorizontallyCentered];
		_searchBar.keepTopInset.equal = KeepRequired(0.0f);
		_searchBar.keepHorizontalInsets.equal = KeepFitting(0.0f);
		_searchBar.keepHeight.equal = KeepRequired(SEARCH_BAR_HEIGHT);
		_searchBar.keepWidth.max = KeepRequired(320.0f);
		
		_searchBar.barTintColor = [UIColor clearColor];
		_searchBar.tintColor = [UIColor whiteColor]; // Tints blinking "|" and "Cancel"
		
		[self setSearchBackgroundColor:[self.view.tintColor colorWithAlphaComponent:alphaOverlay]];
		
		_searchBar.delegate = self;
		
		id<UITextInputTraits> trait;
		for (UIView *sub in self.searchBar.subviews)
		{
			if ([sub conformsToProtocol: @protocol(UITextInputTraits)])
				trait = (id<UITextInputTraits>) sub;
			for (UIView *subSub in sub.subviews) {
				if ([subSub conformsToProtocol: @protocol(UITextInputTraits)])
					trait = (id<UITextInputTraits>) subSub;
			}
		}
		if (trait) {
			[trait setKeyboardAppearance:UIKeyboardAppearanceDark];
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


- (void)setSearchBarVisible:(BOOL)searchBarVisible
{
	if (searchBarVisible != _searchBarVisible)
	{
		_searchBarVisible = searchBarVisible;
		
		CGPoint contentOffset = self.scrollView.contentOffset;
		contentOffset.y = _searchBarVisible ? 0.0f : SEARCH_BAR_HEIGHT;
		[self.scrollView setContentOffset:contentOffset animated:YES];
		
//		self.userInteractionEnabledForSubviews = !_searchBarVisible;
	}
}

- (void)setUserInteractionEnabledForSubviews:(BOOL)userInteractionEnabledForSubviews
{
	if (userInteractionEnabledForSubviews != _userInteractionEnabledForSubviews)
	{
		_userInteractionEnabledForSubviews = userInteractionEnabledForSubviews;
		
		for (UIView *subview in self.view.subviews)
		{
			if (subview != self.searchBar) {
				subview.userInteractionEnabled = _userInteractionEnabledForSubviews;
			}
		}
	}
}






- (void)pannedFromTop:(UIScreenEdgePanGestureRecognizer *)edgePan
{
	static CGPoint contentOffset;
	
	if (edgePan.state == UIGestureRecognizerStateBegan)
	{
		contentOffset = self.scrollView.contentOffset;
	}
	
	CGFloat change = [edgePan translationInView:edgePan.view].y;
	if (contentOffset.y < 0) {
		change = powf(1+change,0.3)-1;
	}
	contentOffset.y -= change;
	self.scrollView.contentOffset = contentOffset;
	[edgePan setTranslation:CGPointZero inView:edgePan.view];
	
	if (edgePan.state == UIGestureRecognizerStateEnded)
	{
		if (contentOffset.y <= 0)
			contentOffset.y = 0;
		else
			contentOffset.y = SEARCH_BAR_HEIGHT;
		[self.scrollView setContentOffset:contentOffset animated:YES];
		[self updateToContentOffset:contentOffset];
	}
}

- (void)updateToContentOffset:(CGPoint)contentOffset
{
	if (contentOffset.y == 0)
	{
		[self startSearch];
		self.searchBarVisible = YES;
	}
	else
	{
		self.searchBarVisible = NO;
		[self.searchBar resignFirstResponder];
	}
}





#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
	if (targetContentOffset->y == 0)
		targetContentOffset->y = 0;
	else if (targetContentOffset->y <= SEARCH_BAR_HEIGHT)
		targetContentOffset->y = SEARCH_BAR_HEIGHT;
	
	CGPoint contentOffset = self.scrollView.contentOffset;
	contentOffset.y = targetContentOffset->y;
	[self updateToContentOffset:contentOffset];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	if (!decelerate) {
		[self updateToContentOffset:scrollView.contentOffset];
	}
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	[self updateToContentOffset:scrollView.contentOffset];
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
	[self.searchBar becomeFirstResponder];
	[_searchBar setShowsCancelButton:YES animated:YES];
//	self.userInteractionEnabledForSubviews = NO;
}

- (void)stopSearch
{
	[self searchString:nil];
	[_searchBar setShowsCancelButton:NO animated:YES];
	[_searchBar resignFirstResponder];
	self.searchBarVisible = NO;
}

- (void)searchString:(NSString *)searchString
{
	NSPredicate *predicate = nil;
	if ([searchString length])
		predicate = [NSPredicate predicateWithFormat:@"title contains[cd] %@",searchString];
	else
		_searchBar.text = nil; // Force to reflect state of search
	
	if ([self.delegate respondsToSelector:@selector(searchedText:)]) {
		[self.delegate searchedText:_searchBar.text];
	}
}



@end
