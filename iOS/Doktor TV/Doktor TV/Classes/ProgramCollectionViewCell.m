//
//  ProgramCollectionCell.m
//  Doktor TV
//
//  Created by Tobias DM on 16/11/13.
//  Copyright (c) 2013 developmunk. All rights reserved.
//

#import "ProgramCollectionViewCell.h"
#import "ProgramCollectionViewController.h"

#import "Button.h"

#import "DataHandler.h"
#import "DRHandler.h"


@interface ProgramCollectionViewCell ()

@property (nonatomic, strong) Button *subscribeButton;

@end

@implementation ProgramCollectionViewCell
{
	ProgramCollectionViewController *programCollectionViewController;
	
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		self.childViewControllerInsets = UIEdgeInsetsMake(100.0f, 0, 0, 0);
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
		
		self.managedObject = _program;
		
		[self setupTitle];
		[self setupImage];
		[self setupSubscribeButton];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"image"])
		[self setupImage];
}



- (void)tintColorDidChange
{
	[super tintColorDidChange];
	
	[self setupTitle];
	[self setupSubscribeButton];
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
		[[DRHandler sharedInstance] validateImageForProgram:_program];
		self.backgroundImage = nil;
	}
}


- (UIViewController *)childViewController
{
	if (!programCollectionViewController)
		programCollectionViewController = [ProgramCollectionViewController new];
	
	programCollectionViewController.program = self.program;
	return programCollectionViewController;
}
- (void)setChildViewController:(UIViewController *)childViewController
{
	if (childViewController)
		NSAssert([childViewController isKindOfClass:[ProgramCollectionViewController class]], @"Incorrect class");
	
	programCollectionViewController = (ProgramCollectionViewController *)childViewController;
}




- (void)setZoom:(BOOL)zoom
{
	[super setZoom:zoom];
	
	if (zoom)
	{
		[self setupTitle];
		[self setupSubscribeButton];
	}
	else
	{
		[_subscribeButton removeFromSuperview];
		_subscribeButton = nil;
	}
}



- (void)setupTitle
{
	if (_program) {
		self.titleLabel.text = _program.title;
		UIColor *color = _program.subscribe.boolValue ? subscribedColor : self.tintColor;
		self.titleLabel.highlightBackgroundColor = [color colorWithAlphaComponent:alphaOverlay];
	}
}



- (Button *)subscribeButton
{
	if (!_subscribeButton)
	{
		[self setupSubscribeButton];
	}
	return _subscribeButton;
}

- (void)setupSubscribeButton
{
	if (!_subscribeButton && self.isZoomed)
	{
		_subscribeButton = [Button new];
		[self.contentView addSubview:_subscribeButton];
		
		[_subscribeButton setTitle:@"Abonnér" forState:UIControlStateNormal];
		[_subscribeButton setTitle:@"Abonnérer" forState:UIControlStateSelected];
		
		_subscribeButton.keepTopInset.equal = KeepRequired(50.0f);
		_subscribeButton.keepWidth.max = KeepRequired(250.0f);
		_subscribeButton.keepHorizontalInsets.min = KeepRequired(20.0f);
		[_subscribeButton keepHorizontallyCentered];
		
		[_subscribeButton addTarget:self action:@selector(subscribeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
	}
	
	if (_subscribeButton)
	{
		_subscribeButton.tintColor = _program.subscribe.boolValue ? subscribedColor : self.superview.tintColor;
		_subscribeButton.selected = _program.subscribe.boolValue;
	}
}

- (void)subscribeButtonTapped
{
	self.program.subscribe = @(!self.program.subscribe.boolValue);
	DLog(@"Program %@subscribed",self.program.subscribe.boolValue ? @"" : @"un-");
	[[DataHandler sharedInstance] saveContext];
}

@end
