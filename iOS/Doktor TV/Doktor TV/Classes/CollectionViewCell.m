//
//  CollectionCell.m
//  
//
//  Created by Tobias DM on 16/11/13.
//
//

#import "CollectionViewCell.h"

@implementation CollectionViewCell
{
	UIImageView *backgroundImageView;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.backgroundColor = [UIColor iOS7blueGradientStartColor];
		self.clipsToBounds = YES;
    }
    return self;
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
		
		backgroundImageView.hidden = !_backgroundImage;
	}
}

- (void)setBlurBackgroundImage:(BOOL)blurBackgroundImage
{
	if (blurBackgroundImage != _blurBackgroundImage) {
		_blurBackgroundImage = blurBackgroundImage;
		
		if (blurBackgroundImage) {
			UIImage *image = [_backgroundImage applyBlurWithRadius:4.0f
														 tintColor:[self.backgroundColor colorWithAlphaComponent:0.0]
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


@end
