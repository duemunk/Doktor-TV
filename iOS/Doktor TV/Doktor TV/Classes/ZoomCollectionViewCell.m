//
//  CollectionCell.m
//  
//
//  Created by Tobias DM on 16/11/13.
//
//

#import "ZoomCollectionViewCell.h"

@implementation ZoomCollectionViewCell
{
	UIImageView *backgroundImageView;
	BOOL _blurBackgroundImage;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.backgroundColor = [UIColor colorWithWhite:0.5f alpha:0.5f];
		self.clipsToBounds = YES;
    }
    return self;
}



- (void)setZoom:(BOOL)zoom
{
	if (zoom != _zoom)
	{
		_zoom = zoom;
		
		[self blurBackgroundImage:zoom];
		[self setupChildViewController];
	}
}

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
	if (backgroundImage != _backgroundImage)
	{
		_backgroundImage = backgroundImage;
		
		if (!backgroundImageView)
		{
			backgroundImageView = [UIImageView new];
			[self insertSubview:backgroundImageView atIndex:0];
			[backgroundImageView keepInsets:UIEdgeInsetsZero];
			backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
		}
		backgroundImageView.image = _backgroundImage;
		[self blurBackgroundImage:self.isZoomed];
		
		backgroundImageView.hidden = !_backgroundImage;
	}
}

- (void)blurBackgroundImage:(BOOL)blurBackgroundImage
{
	if (blurBackgroundImage != _blurBackgroundImage) {
		_blurBackgroundImage = blurBackgroundImage;
		
		if (blurBackgroundImage) {
			UIImage *image = [_backgroundImage applyBlurWithRadius:4.0f
														 tintColor:nil
											 saturationDeltaFactor:0.5f
														 maskImage:nil];
			
			backgroundImageView.image = image;
		}
		else
		{
			backgroundImageView.image = _backgroundImage;
		}
	}
}


- (UILabel *)titleLabel
{
	if (!_titleLabel) {
		_titleLabel = [UILabel new];
		[self addSubview:_titleLabel];
		_titleLabel.keepLeftInset.equal =
		_titleLabel.keepTopInset.equal = KeepRequired(0.0f);
		
		_titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
		
		[self applyDefaultLabelStyling:_titleLabel];
	}
	
	return _titleLabel;
}

- (void)applyDefaultLabelStyling:(UILabel *)label
{
	label.keepInsets.min = KeepRequired(0.0f);
	label.textColor = [UIColor whiteColor];
	label.numberOfLines = 0;
	label.backgroundColor = [self.backgroundColor colorWithAlphaComponent:0.5];
}



- (void)setupChildViewController
{
	if (self.isZoomed)
	{
		if (![self.subviews containsObject:self.childViewController.view]) {
			[self insertSubview:self.childViewController.view belowSubview:self.titleLabel];
			
			UIEdgeInsets insets = UIEdgeInsetsMake(100.0f, 0, 0, 0);
			if ([self.childViewController.view isKindOfClass:[UIScrollView class]])
			{
				[self.childViewController.view keepInsets:UIEdgeInsetsZero];
				((UIScrollView *)self.childViewController.view).contentInset = insets;
			}
			else if ([self.childViewController isKindOfClass:[UICollectionViewController class]])
			{
				[self.childViewController.view keepInsets:UIEdgeInsetsZero];
				((UICollectionViewController *)self.childViewController).collectionView.contentInset = insets;
			}
			else
				[self.childViewController.view keepInsets:insets];
			
		}
		
	}
	else
	{
		if (_childViewController) {
			[_childViewController.view removeFromSuperview];
			_childViewController = nil;
		}
	}
}


@end
