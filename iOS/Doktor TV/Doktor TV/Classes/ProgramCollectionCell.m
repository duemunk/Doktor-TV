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
	UIImageView *imageView;
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
			titleLabel.keepInsets.min = KeepRequired(10.0f);
			[titleLabel keepCentered];
			titleLabel.textColor = [UIColor whiteColor];
			titleLabel.numberOfLines = 0;
			titleLabel.textAlignment = NSTextAlignmentCenter;
			titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
			titleLabel.backgroundColor = [self.backgroundColor colorWithAlphaComponent:0.3];
		}
		titleLabel.text = _program.title;
		
		[self setupImage];
		
	}
}


- (void)setShowContent:(BOOL)showContent
{
	if (showContent != _showContent) {
		_showContent = showContent;
		
		titleLabel.hidden = showContent;
		
		if (_showContent) {
			
			if (!programCollectionViewController) {
				programCollectionViewController = [ProgramCollectionViewController new];
				programCollectionViewController.program = self.program;
				
				[self addSubview:programCollectionViewController.view];
				[programCollectionViewController.view keepInsets:UIEdgeInsetsZero];
			}
		}
		else
		{
			if (programCollectionViewController) {
				[programCollectionViewController.view removeFromSuperview];
				programCollectionViewController = nil;
			}
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
