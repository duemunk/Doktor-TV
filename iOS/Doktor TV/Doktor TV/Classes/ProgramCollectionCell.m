//
//  ProgramCollectionCell.m
//  Doktor TV
//
//  Created by Tobias DM on 16/11/13.
//  Copyright (c) 2013 developmunk. All rights reserved.
//

#import "ProgramCollectionCell.h"
#import "ProgramCollectionViewController.h"

@implementation ProgramCollectionCell
{
	UILabel *titleLabel;
	ProgramCollectionViewController *programCollectionViewController;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.backgroundColor = [UIColor iOS7blueGradientStartColor];
    }
    return self;
}


- (void)setProgram:(Program *)program
{
	if (program != _program) {
		_program = program;
		
		if (!titleLabel) {
			titleLabel = [UILabel new];
			[self addSubview:titleLabel];
			[titleLabel keepCentered];
			titleLabel.textColor = [UIColor whiteColor];
		}
		titleLabel.text = _program.title;
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
