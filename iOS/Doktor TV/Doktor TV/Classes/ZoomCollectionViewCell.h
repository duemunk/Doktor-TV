//
//  CollectionCell.h
//  
//
//  Created by Tobias DM on 16/11/13.
//
//

@import UIKit;

@protocol ZoomCollectionViewCellDelegate;

@interface ZoomCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, assign, getter = isZoomed) BOOL zoom;
@property (nonatomic, assign) UIViewController *childViewController;
@property (nonatomic, strong) NSManagedObject *managedObject;
@property (nonatomic, strong) id<ZoomCollectionViewCellDelegate> delegate;

- (void)applyDefaultLabelStyling:(UILabel *)label;

- (void)setupChildViewController;

@end


@protocol ZoomCollectionViewCellDelegate <NSObject>

- (void)zoomCollectionViewCell:(ZoomCollectionViewCell *)cell changedZoom:(BOOL)zoom;

@end
