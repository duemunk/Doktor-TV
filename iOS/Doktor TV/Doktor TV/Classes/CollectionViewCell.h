//
//  CollectionCell.h
//  
//
//  Created by Tobias DM on 16/11/13.
//
//

@import UIKit;

@interface CollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, assign) BOOL blurBackgroundImage;
@property (nonatomic, strong) UIImage *backgroundImage;

- (void)applyDefaultLabelStyling:(UILabel *)label;

@end
