//
//  CollectionCell.h
//  
//
//  Created by Tobias DM on 16/11/13.
//
//

@import UIKit;
#import "HighlightedLabel.h"
#import "TDMZoomCollectionViewCell.h"

@interface ZoomCollectionViewCell : TDMZoomCollectionViewCell

@property (nonatomic, strong) HighlightedLabel *titleLabel;
@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, assign) UIViewController *childViewController;
@property (nonatomic, strong) NSManagedObject *managedObject;
@property (nonatomic, assign) UIEdgeInsets childViewControllerInsets;

- (void)applyDefaultLabelStyling:(HighlightedLabel *)label;

- (void)setupChildViewController;

- (void)didDisappear;

@end
