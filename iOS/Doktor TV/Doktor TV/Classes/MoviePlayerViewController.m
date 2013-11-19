//
//  MoviePlayerViewController.m
//  Doktor TV
//
//  Created by Tobias DM on 19/11/13.
//  Copyright (c) 2013 developmunk. All rights reserved.
//

#import "MoviePlayerViewController.h"

@interface MoviePlayerViewController ()

@end

@implementation MoviePlayerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
	[self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[[UIApplication sharedApplication] endReceivingRemoteControlEvents];
	[self resignFirstResponder];
}


- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
	NSMutableDictionary *playingInfo = [[MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo mutableCopy];
	BOOL changedPlayingInfo = NO;
	
	switch (event.subtype) {
		case UIEventSubtypeRemoteControlPlay:
			DLog(@"Remote play");
			[self.moviePlayer play];
			break;
		case UIEventSubtypeRemoteControlPause:
			DLog(@"Remote pause");
			[self.moviePlayer pause];
			break;
		case UIEventSubtypeRemoteControlStop:
			DLog(@"Remote stop");
			[self.moviePlayer stop];
			break;
		case UIEventSubtypeRemoteControlTogglePlayPause:
			DLog(@"Remote toggle play/pause");
			if (self.moviePlayer.playbackState == MPMoviePlaybackStatePlaying)
				[self.moviePlayer pause];
			else
				[self.moviePlayer play];
			break;
		case UIEventSubtypeRemoteControlBeginSeekingForward:
			DLog(@"Remote begin seeking forward");
			[self.moviePlayer beginSeekingForward];
			break;
		case UIEventSubtypeRemoteControlBeginSeekingBackward:
			DLog(@"Remote begin seeking backward");
			[self.moviePlayer beginSeekingBackward];
			break;
		case UIEventSubtypeRemoteControlEndSeekingForward:
		case UIEventSubtypeRemoteControlEndSeekingBackward:
			DLog(@"Remote end seeking");
			[self.moviePlayer endSeeking];
			break;
		case UIEventSubtypeRemoteControlNextTrack:
			self.moviePlayer.currentPlaybackTime += 15.0f;
			break;
		case UIEventSubtypeRemoteControlPreviousTrack:
			self.moviePlayer.currentPlaybackTime -= 15.0f;
			break;
		default:
			DLog(@"Remote unused");
			break;
	}
	
	playingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = @(self.moviePlayer.currentPlaybackTime);
	changedPlayingInfo = YES;
	
	if (changedPlayingInfo) {
		[MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = playingInfo;
	}
}

@end
