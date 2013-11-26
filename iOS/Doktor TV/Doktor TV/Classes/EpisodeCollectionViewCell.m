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
	if (_episode) {
		[_episode removeObserver:self forKeyPath:@"image"];
	}
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
		if (_episode)
			[_episode removeObserver:self forKeyPath:@"image"];
		_episode = episode;
		[_episode addObserver:self forKeyPath:@"image" options:0 context:0];
		
		self.titleLabel.text = _episode.title;
		[self setupImage];
		self.managedObject = _episode;
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"image"])
		[self setupImage];
}

- (void)setupImage
{
	if (_episode.image)
	{
		NSString *imagePath = [DataHandler pathForFileName:_episode.image];
		UIImage *image = [[UIImage alloc] initWithContentsOfFile:imagePath];
		self.backgroundImage = image;
	}
	else
	{
		self.backgroundImage = nil;
	}
	[[DRHandler sharedInstance] validateImageForEpisode:_episode];
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

@end
