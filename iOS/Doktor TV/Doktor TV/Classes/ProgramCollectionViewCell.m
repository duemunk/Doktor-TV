//
//  ProgramCollectionCell.m
//  Doktor TV
//
//  Created by Tobias DM on 16/11/13.
//  Copyright (c) 2013 developmunk. All rights reserved.
//

#import "ProgramCollectionViewCell.h"
#import "ProgramCollectionViewController.h"

#import "DataHandler.h"
#import "DRHandler.h"

@implementation ProgramCollectionViewCell
{
	UIImageView *blurredImageView;
	ProgramCollectionViewController *programCollectionViewController;
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
		if (_program)
			[_program removeObserver:self forKeyPath:@"image"];
		_program = program;
		[_program addObserver:self forKeyPath:@"image" options:0 context:0];
		
		self.titleLabel.text = _program.title;
		
		[self setupImage];
		
		[self setupCollectionViewController];
	}
}


- (void)setShowContent:(BOOL)showContent
{
	if (showContent != _showContent)
	{
		_showContent = showContent;
		
		self.blurBackgroundImage = showContent;

		[self setupCollectionViewController];
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
		NSString *imagePath = [DataHandler pathForFileName:_program.image];
		UIImage *image = [[UIImage alloc] initWithContentsOfFile:imagePath];
		self.backgroundImage = image;
	}
	else
	{
		self.backgroundImage = nil;
	}
}

- (void)setupCollectionViewController
{
	if (_showContent)
	{
		if (!programCollectionViewController) {
			programCollectionViewController = [ProgramCollectionViewController new];
			programCollectionViewController.program = self.program;
			
			[self insertSubview:programCollectionViewController.view belowSubview:self.titleLabel];
			[programCollectionViewController.view keepInsets:UIEdgeInsetsZero];
			programCollectionViewController.collectionView.contentInset = UIEdgeInsetsMake(100.0f, 0, 0, 0);
		}
		else
			programCollectionViewController.program = self.program;
	}
	else
	{
		if (programCollectionViewController) {
			[programCollectionViewController.view removeFromSuperview];
			programCollectionViewController = nil;
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
