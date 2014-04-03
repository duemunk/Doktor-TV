
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
#import "FileDownloadHandler.h"


@interface ProgramCollectionViewCell ()

@property (nonatomic, strong) Button *subscribeButton;
@property (nonatomic, weak) NSURLSessionDownloadTask *downloadTask;

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
	[[NSNotificationCenter defaultCenter] removeObserver:self];
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
		if (_downloadTask) {
			if (self.downloadTask.state == NSURLSessionTaskStateRunning)
			{
				DDLogInfo(@"Cell had running downloadtask %@",_downloadTask.taskDescription);
				[self.downloadTask suspend];
			}
		}
		_program = program;
		
		self.managedObject = _program;
		
		[self setupImage];
		
		if (self.isZoomed) {
			[self setupTitle];
			[self setupSubscribeButton];
			
			if (programCollectionViewController) {
				programCollectionViewController.program = self.program;
			}
		}
	}
}



- (void)tintColorDidChange
{
	[super tintColorDidChange];
	
	[self setupTitle];
	[self setupSubscribeButton];
}

#define STORE_IMAGE_PERSISTENT NO

- (void)setupImage 
{
	if (_program.image)
	{
		NSString *imagePath = [DataHandler pathForFile:_program.image persistent:STORE_IMAGE_PERSISTENT];
		
		if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath])
		{
			UIImage *image = [[UIImage alloc] initWithContentsOfFile:imagePath];
			self.backgroundImage = image;
		}
		else
		{
			self.backgroundImage = nil; // Clear up when waiting for download
			
			[[FileDownloadHandler sharedInstance] download:_program.imageUrl
													toFile:_program.image
										backgroundTransfer:NO
												  observer:self
												  selector:@selector(downloadNotification:)
												completion:^(NSURLSessionDownloadTask *downloadTask) {
													self.downloadTask = downloadTask;
												}
												persistent:STORE_IMAGE_PERSISTENT];
		}
	}
	else
	{
		self.backgroundImage = nil;
	}
}


- (void)downloadNotification:(NSNotification *) notification
{
	if ([notification.name isEqualToString:NOTIFICATION_DOWNLOAD_COMPLETE])
	{
		[self setupImage];
	}
	if ([notification.name isEqualToString:NOTIFICATION_DOWNLOAD_PROGRESS])
	{
		float progress = [notification.userInfo[kPROGRESS] floatValue];
		DDLogInfo(@"Progess: %f", progress);
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
	if (childViewController) {
		NSAssert([childViewController isKindOfClass:[ProgramCollectionViewController class]], @"Incorrect class");
	}
	
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
	DDLogInfo(@"Program %@subscribed",self.program.subscribe.boolValue ? @"" : @"un-");
	[[DataHandler sharedInstance] saveContext];
}



- (void)didDisappear
{
	[super didDisappear];
	
	if (_downloadTask) {
		if (self.downloadTask.state == NSURLSessionTaskStateRunning)
		{
			DDLogInfo(@"Cell had running downloadtask %@",_downloadTask.taskDescription);
			[self.downloadTask suspend];
		}
	}
}

@end
