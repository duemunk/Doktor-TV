//
//  CollectionCell.h
//  
//
//  Created by Tobias DM on 16/11/13.
//
//

@import UIKit;

@interface ZoomCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, assign, getter = isZoomed) BOOL zoom;
@property (nonatomic, assign) UIViewController *childViewController;
@property (nonatomic, strong) NSManagedObject *managedObject;

@property (nonatomic, assign) BOOL alive;

- (void)applyDefaultLabelStyling:(UILabel *)label;

- (void)setupChildViewController;

@end
