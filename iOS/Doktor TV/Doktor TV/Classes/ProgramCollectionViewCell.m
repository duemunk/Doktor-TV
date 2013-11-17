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
	ProgramCollectionViewController *programCollectionViewController;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.backgroundColor = [UIColor iOS7lightBlueColor];
    }
    return self;
}

- (void)dealloc
{
	if (_program) {
		[_program removeObserver:self forKeyPath:@"image"];
	}
}

- (void)setManagedObject:(NSManagedObject *)managedObject
{
	[super setManagedObject:managedObject];
	
	NSAssert([self.managedObject isKindOfClass:[Program class]], @"Incorrect class for managedObject (Program)");
	self.program = (Program *)self.managedObject;
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
		self.managedObject = _program;
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"image"])
		[self setupImage];
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

- (void)setupChildViewController
{
	if (self.isZoomed)
	{
		if (!programCollectionViewController) {
			programCollectionViewController = [ProgramCollectionViewController new];
			programCollectionViewController.program = self.program;
			
			self.childViewController = programCollectionViewController;
		}
		else
			programCollectionViewController.program = self.program;
	}
	
	[super setupChildViewController];
}


@end
