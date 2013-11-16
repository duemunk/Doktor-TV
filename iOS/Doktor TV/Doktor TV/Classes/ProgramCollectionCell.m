//
//  ProgramCollectionCell.m
//  Doktor TV
//
//  Created by Tobias DM on 16/11/13.
//  Copyright (c) 2013 developmunk. All rights reserved.
//

#import "ProgramCollectionCell.h"
#import "ProgramCollectionViewController.h"

#import "DataHandler.h"

@implementation ProgramCollectionCell
{
	UILabel *titleLabel;
	UIImageView *imageView, *blurredImageView;
	ProgramCollectionViewController *programCollectionViewController;
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

- (void)dealloc
{
	if (_program) {
		[_program removeObserver:self forKeyPath:@"image"];
	}
}


- (void)setProgram:(Program *)program
{
	if (program != _program)
	{
		if (_program) {
			[_program removeObserver:self forKeyPath:@"image"];
		}
	
		_program = program;
		
		[_program addObserver:self forKeyPath:@"image" options:0 context:0];
		
		if (!titleLabel) {
			titleLabel = [UILabel new];
			[self addSubview:titleLabel];
			titleLabel.keepInsets.min = KeepRequired(0.0f);
			titleLabel.keepLeftInset.equal =
			titleLabel.keepTopInset.equal = KeepRequired(0.0f);
			titleLabel.textColor = [UIColor whiteColor];
			titleLabel.numberOfLines = 0;
			titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
			titleLabel.backgroundColor = [self.backgroundColor colorWithAlphaComponent:0.5];
		}
		titleLabel.text = _program.title;
		
		[self setupImage];
		
	}
}


- (void)setShowContent:(BOOL)showContent
{
	if (showContent != _showContent) {
		_showContent = showContent;
		
//		titleLabel.hidden = showContent;
		
		if (_showContent)
		{
			if (imageView) {
				UIImage *image = [imageView.image copy];
				image = [image applyBlurWithRadius:4.0f
										 tintColor:[self.backgroundColor colorWithAlphaComponent:0.0]
							 saturationDeltaFactor:0.5f
										 maskImage:nil];
				blurredImageView = [UIImageView new];
				blurredImageView.image = image;
				[self insertSubview:blurredImageView aboveSubview:imageView];
				[blurredImageView keepInsets:UIEdgeInsetsZero];
				blurredImageView.contentMode = UIViewContentModeScaleAspectFill;
				blurredImageView.hidden = NO;
			}
			
			if (!programCollectionViewController) {
				programCollectionViewController = [ProgramCollectionViewController new];
				programCollectionViewController.program = self.program;
				
				[self addSubview:programCollectionViewController.view];
				programCollectionViewController.view.keepHorizontalInsets.equal =
				programCollectionViewController.view.keepBottomInset.equal = KeepRequired(0.0f);
				programCollectionViewController.view.keepTopOffsetTo(titleLabel).equal = KeepRequired(10.0f);
			}
		}
		else
		{
			if (programCollectionViewController) {
				[programCollectionViewController.view removeFromSuperview];
				programCollectionViewController = nil;
			}
			if (blurredImageView)
				blurredImageView.hidden = YES;
		}
		[self setNeedsDisplay];
	}
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"image"])
	{
		[self setupImage];
	}
}



- (void)setupImage 
{
	if (_program.image)
	{
		if (!imageView)
		{
			imageView = [UIImageView new];
			[self insertSubview:imageView atIndex:0];
			[imageView keepInsets:UIEdgeInsetsZero];
			imageView.contentMode = UIViewContentModeScaleAspectFill;
		}
		NSString *imagePath = [DataHandler pathForFileName:_program.image];
		UIImage *image = [[UIImage alloc] initWithContentsOfFile:imagePath];
		imageView.image = image;
	}
	else
	{
		if (imageView) {
			imageView.image = nil;
		}
	}
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
