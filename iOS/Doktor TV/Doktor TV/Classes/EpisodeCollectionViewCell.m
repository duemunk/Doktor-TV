//
//  EpisodeCollectionViewCell.m
//  Doktor TV
//
//  Created by Tobias DM on 16/11/13.
//  Copyright (c) 2013 developmunk. All rights reserved.
//

#import "EpisodeCollectionViewCell.h"
#import "EpisodeViewController.h"

#import "DataHandler.h"
#import "DRHandler.h"

#import "FileDownloadHandler.h"

@interface EpisodeCollectionViewCell ()

@property (nonatomic, weak) NSURLSessionDownloadTask *downloadTask;

@end

@implementation EpisodeCollectionViewCell
{
	EpisodeViewController *episodeViewController;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		self.childViewControllerInsets = UIEdgeInsetsMake(60.0f, 0, 0, 0);
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
	
	NSAssert([self.managedObject isKindOfClass:[Episode class]], @"Incorrect class for managedObject (Episode)");
	self.episode = (Episode *)self.managedObject;
}

- (void)setEpisode:(Episode *)episode
{
	if (episode != _episode)
	{
		if (_downloadTask) {
			if (self.downloadTask.state == NSURLSessionTaskStateRunning)
			{
				DLog(@"Cell had running downloadtask %@",_downloadTask.taskDescription);
				[self.downloadTask suspend];
			}
		}
		
		_episode = episode;
		
		self.titleLabel.text = _episode.title;
		[self setupImage];
		self.managedObject = _episode;
		
		if (episodeViewController)
			episodeViewController.episode = self.episode;
	}
}

#define STORE_IMAGE_PERSISTENT NO

- (void)setupImage
{
	if (_episode.image)
	{
		NSString *imagePath = [DataHandler pathForFile:_episode.image persistent:STORE_IMAGE_PERSISTENT];
		
		if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath])
		{
			UIImage *image = [[UIImage alloc] initWithContentsOfFile:imagePath];
			self.backgroundImage = image;
		}
		else
		{
			self.backgroundImage = nil; // Clear up when waiting for download
			
			[[FileDownloadHandler sharedInstance] download:_episode.imageUrl
													toFile:_episode.image
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
		DLog(@"Progess: %f", progress);
	}
}


- (UIViewController *)childViewController
{
	if (!episodeViewController)
		episodeViewController = [EpisodeViewController new];
	
	episodeViewController.episode = self.episode;
	return episodeViewController;
}
- (void)setChildViewController:(UIViewController *)childViewController
{
	if (childViewController)
		NSAssert([childViewController isKindOfClass:[EpisodeViewController class]], @"Incorrect class");
	
	episodeViewController = (EpisodeViewController *)childViewController;
}

- (void)didDisappear
{
	[super didDisappear];
	
	if (_downloadTask) {
		if (self.downloadTask.state == NSURLSessionTaskStateRunning)
		{
			DLog(@"Cell had running downloadtask %@",_downloadTask.taskDescription);
			[self.downloadTask suspend];
		}
	}
}

@end
