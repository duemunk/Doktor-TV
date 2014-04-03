//
//  CollectionCell.m
//  
//
//  Created by Tobias DM on 16/11/13.
//
//

#import "ZoomCollectionViewCell.h"
#import "Button.h"

@implementation ZoomCollectionViewCell
{
	UIImageView *backgroundImageView;
	BOOL _blurBackgroundImage;
	Button *closeButton;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.backgroundColor = [self.tintColor colorWithAlphaComponent:alphaBackground];
		self.clipsToBounds = YES;
    }
    return self;
}

- (void)tintColorDidChange
{
	self.backgroundColor = [self.tintColor colorWithAlphaComponent:alphaBackground];
	self.titleLabel.highlightBackgroundColor = [self.tintColor colorWithAlphaComponent:alphaOverlay];
}



- (void)setZoom:(BOOL)zoom
{
	[super setZoom:zoom];
	
	[self blurBackgroundImage:zoom];
	[self setupChildViewController];
	[self setupCloseButton];
}

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
	if (backgroundImage != _backgroundImage)
	{
		_backgroundImage = backgroundImage;
		
		if (!backgroundImageView)
		{
			backgroundImageView = [UIImageView new];
			self.backgroundView = backgroundImageView;
			backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
		}
		backgroundImageView.image = _backgroundImage;
		[self forceBlurBackgroundImage:self.isZoomed];
		
		backgroundImageView.hidden = !_backgroundImage;
	}
}

- (void)blurBackgroundImage:(BOOL)blurBackgroundImage
{
	if (blurBackgroundImage != _blurBackgroundImage)
	{
		[self forceBlurBackgroundImage:blurBackgroundImage];
	}
}

- (void)forceBlurBackgroundImage:(BOOL)blurBackgroundImage
{
	_blurBackgroundImage = blurBackgroundImage;
	
	if (blurBackgroundImage) {
		UIImage *image = [_backgroundImage applyBlurWithRadius:10.0f
													 tintColor:[UIColor colorWithWhite:0.0f alpha:0.2f]
										 saturationDeltaFactor:1.9f
													 maskImage:nil];
		
		backgroundImageView.image = image;
	}
	else
	{
		backgroundImageView.image = _backgroundImage;
	}
}

- (UILabel *)titleLabel
{
	if (!_titleLabel)
	{
		_titleLabel = [HighlightedLabel new];
		[self.contentView addSubview:_titleLabel];
		_titleLabel.keepLeftInset.equal =
		_titleLabel.keepTopInset.equal = KeepRequired(0.0f);
		
		_titleLabel.font = [UIFont preferredCustomFontForTextStyle:UIFontTextStyleHeadline];
		
		[self applyDefaultLabelStyling:_titleLabel];
	}
	
	return _titleLabel;
}



- (void)applyDefaultLabelStyling:(HighlightedLabel *)label
{
	label.keepInsets.min = KeepRequired(0.0f);
	label.textColor = [UIColor whiteColor];
	label.numberOfLines = 0;
	label.highlightBackgroundColor = [self.tintColor colorWithAlphaComponent:alphaOverlay];
}



- (void)setupChildViewController
{
	if (self.isZoomed)
	{
		if (![self.contentView.subviews containsObject:self.childViewController.view]) {
			[self.contentView insertSubview:self.childViewController.view belowSubview:self.titleLabel];
			
			if ([self.childViewController.view isKindOfClass:[UIScrollView class]])
			{
				[self.childViewController.view keepInsets:UIEdgeInsetsZero];
				((UIScrollView *)self.childViewController.view).contentInset = self.childViewControllerInsets;
				((UIScrollView *)self.childViewController.view).scrollIndicatorInsets = self.childViewControllerInsets;
			}
			else if ([self.childViewController isKindOfClass:[UICollectionViewController class]])
			{
				[self.childViewController.view keepInsets:UIEdgeInsetsZero];
				((UICollectionViewController *)self.childViewController).collectionView.contentInset = self.childViewControllerInsets;
				((UICollectionViewController *)self.childViewController).collectionView.scrollIndicatorInsets = self.childViewControllerInsets;
			}
			else
				[self.childViewController.view keepInsets:self.childViewControllerInsets];
		}
	}
	else
	{
		if (_childViewController) {
			[self.childViewController.view removeFromSuperview];
			self.childViewController = nil;
		}
	}
}


- (void)setupCloseButton
{
	if (self.isZoomed)
	{
		if (!closeButton) {
			closeButton = [Button new];
			closeButton.title = @"Close";
			[self.contentView addSubview:closeButton];
			
			[closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
			
			closeButton.keepRightInset.equal =
			closeButton.keepTopInset.equal = KeepRequired(0.0f);
		}
	}
	else
	{
		if (closeButton) {
			[closeButton removeTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
			[closeButton removeFromSuperview];
			closeButton = nil;
		}
	}
}



- (void)layoutSubviews
{
	[super layoutSubviews];
	
	if (_titleLabel) // Update max width for label. Autolayout doesn't do this.
		_titleLabel.preferredMaxLayoutWidth = self.bounds.size.width;
}


- (void)didDisappear
{
	
}


@end
