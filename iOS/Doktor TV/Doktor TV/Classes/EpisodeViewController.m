//
//  EpisodeViewController.m
//  Doktor TV
//
//  Created by Tobias DM on 16/11/13.
//  Copyright (c) 2013 developmunk. All rights reserved.
//

#import "EpisodeViewController.h"

#import "DRHandler.h"
#import "DataHandler.h"
#import "Button.h"

@import MediaPlayer;

@interface EpisodeViewController ()

@end

@implementation EpisodeViewController
{
	Button *streamButton, *downloadButton;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// Do any additional setup after loading the view
	[self layoutButtons];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setEpisode:(Episode *)episode
{
	if (episode != _episode)
	{
		if (_episode)
		{
			[_episode removeObserver:self forKeyPath:@"video"];
		}
		_episode = episode;
		[_episode addObserver:self forKeyPath:@"video" options:0 context:0];
		
//		streamButton.enabled =
//		downloadButton.enabled = (episode.uri.length > 0);
		
		[self layoutButtons];
		
	}
}

- (void)layoutButtons
{
	CGFloat padding = 20.0f;
	CGFloat maxWidth = 130.0f;

	// Clear
	if (downloadButton)
	{
		[downloadButton removeFromSuperview];
		downloadButton = nil;
	}
	if (streamButton)
	{
		[streamButton removeFromSuperview];
		streamButton = nil;
	}
	
	// Has potential for video
	if (!self.episode.uri)
		return;
	
	//
	downloadButton = [Button new];
	[self.view addSubview:downloadButton];
	[downloadButton addTarget:self action:@selector(download) forControlEvents:UIControlEventTouchUpInside];
	

	
	BOOL noVideoFile = ![DataHandler fileExists:self.episode.video];
	if (noVideoFile)
	{
		streamButton = [Button new];
		[self.view addSubview:streamButton];
		[streamButton addTarget:self action:@selector(stream) forControlEvents:UIControlEventTouchUpInside];
		
		downloadButton.title = @"Hent";
		streamButton.title = @"Afspil (Stream)";
		
		
		downloadButton.keepLeftInset.equal =
		streamButton.keepRightInset.equal = KeepHigh(padding);
		
		NSArray *buttons = @[downloadButton,streamButton];
		[buttons keepBaselineAligned];
		[buttons keepHorizontalOffsets:KeepRequired(padding)];
		[buttons keepSizesEqualWithPriority:KeepPriorityHigh];
		buttons.keepWidth.max = KeepRequired(maxWidth);
		
		[downloadButton keepVerticallyCentered];
	}
	else // Has link, only show play
	{
		downloadButton.title = @"Afspil";
		
		downloadButton.keepWidth.min = KeepRequired(maxWidth);
		[downloadButton keepCentered];
	}
}



- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"video"])
	{
		[self layoutButtons];
	}
}


- (void)download
{
	BOOL noVideoFile = ![DataHandler fileExists:self.episode.video];
	if (noVideoFile)
	{
		[[DRHandler sharedInstance] downloadVideoForEpisode:self.episode block:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
			dispatch_async(dispatch_get_main_queue(), ^{
				
				CGFloat progress = (float)totalBytesRead / (float)totalBytesExpectedToRead;
				downloadButton.title = [NSString stringWithFormat:@"Henter %.0f%%",ceilf(100.0f*progress)];
			});
		}];
	}
	else
	{
		NSString *urlString = [DataHandler pathForFileName:self.episode.video];
		NSURL *url = [NSURL fileURLWithPath:urlString];
		MPMoviePlayerViewController *moviePlayerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
		moviePlayerViewController.moviePlayer.fullscreen = YES;
		moviePlayerViewController.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
		
		UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
		[rootViewController presentMoviePlayerViewControllerAnimated:moviePlayerViewController];
	}
}

- (void)stream
{
	[[DRHandler sharedInstance] runVideo:^(NSString *urlString) {
	
		NSURL *url = [NSURL URLWithString:urlString];
		MPMoviePlayerViewController *moviePlayerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
		moviePlayerViewController.moviePlayer.fullscreen = YES;
		moviePlayerViewController.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
		
		UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
		[rootViewController presentMoviePlayerViewControllerAnimated:moviePlayerViewController];
		
	} forEpisode:self.episode];
}




@end
