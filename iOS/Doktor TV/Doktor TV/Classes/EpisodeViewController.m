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
#import "MoviePlayerViewController.h"

#import "FileDownloadHandler.h"

@import AVFoundation;

@import MediaPlayer;

@interface EpisodeViewController ()

@property (nonatomic, weak) NSURLSessionDownloadTask *downloadTask;

@end

@implementation EpisodeViewController
{
	Button *streamButton, *downloadButton;
	UITextView *textView;
	MoviePlayerViewController *moviePlayerViewController;
	AVPlayer *avPlayer;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// Do any additional setup after loading the view
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self checkDownload];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)setEpisode:(Episode *)episode
{
	if (episode != _episode)
	{
		_episode = episode;
		
		[self layoutButtons];
		
		if (!textView) {
			textView = [UITextView new];
			[self.view addSubview:textView];
			[textView keepInsets:UIEdgeInsetsMake(50.0f, 0, 0, 0)];
			textView.contentInset = UIEdgeInsetsMake(0.0f, 0, 20.0f, 0);
			
			textView.font = [UIFont preferredCustomFontForTextStyle:UIFontTextStyleBody];
			textView.backgroundColor = [UIColor clearColor];
			textView.textColor = [UIColor whiteColor];
			textView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
			textView.textContainerInset = UIEdgeInsetsMake(0, 20.f, 0, 20.0f);
			textView.textContainer.lineFragmentPadding = 0.0f;
			textView.alwaysBounceVertical = YES;
			textView.editable = NO; // Should allow user to change content
		}
		textView.text = [NSString stringWithFormat:@"%@ \n%@ \n%@",_episode.title,_episode.subtitle,_episode.desc];
		
		[self checkDownload];
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

	
	BOOL hasVideoFile = self.episode.video && [DataHandler fileExists:self.episode.video];
	if (hasVideoFile)
	{
		DLog(@"Has videofile %@ for episode %@", self.episode.video,self.episode.title);
		
		downloadButton.title = @"Afspil";
		
		downloadButton.keepWidth.min = KeepRequired(maxWidth);
		[downloadButton keepHorizontallyCentered];
		downloadButton.keepTopInset.equal = KeepRequired(0.0f);
	}
	else // Has link, only show play
	{
		DLog(@"No videofile for episode %@", self.episode.title);
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
		
		downloadButton.keepTopInset.equal = KeepRequired(0.0f);
	}
}



- (void)checkDownload
{
	[[DRHandler sharedInstance] getVideoLinkForEpisode:self.episode completion:^(NSString *urlString)
	 {
		 [[FileDownloadHandler sharedInstance] findExistingDownload:urlString backgroundTransfer:YES observer:self selector:@selector(downloadNotification:) completion:^(NSURLSessionDownloadTask *downloadTask) {
			 self.downloadTask = downloadTask;
		 }];
	 }];
}




- (void)download
{
	BOOL hasVideoFile = self.episode.video && [DataHandler fileExists:self.episode.video];
	if (hasVideoFile)
	{
		DLog(@"Video available %@ for episode %@",self.episode.video,self.episode.title);
		
		NSString *urlString = [DataHandler pathForCachedFile:self.episode.video];
		NSURL *url = [NSURL fileURLWithPath:urlString];
		[self playVideoWithURL:url movieSourceType:MPMovieSourceTypeFile];
	}
	else
	{
		DLog(@"No video %@ for episode %@",self.episode.video,self.episode.title);
		
		if (_downloadTask)
		{
			if (_downloadTask.state == NSURLSessionTaskStateRunning)
			{
				// Already downloading – pause
				[self.downloadTask cancelByProducingResumeData:^(NSData *resumeData){}];
				[self layoutButtons];
				return;
			}
			else
				[self.downloadTask resume];
		}
		
		[[DRHandler sharedInstance] getVideoLinkForEpisode:self.episode completion:^(NSString *urlString)
		{
			DLog(@"Begin download of video for episode %@ in program %@",self.episode.title,((Program *)self.episode.season.program).title);
			
			[[FileDownloadHandler sharedInstance] download:urlString
													toFile:self.episode.video
										backgroundTransfer:YES
												  observer:self
												  selector:@selector(downloadNotification:) completion:^(NSURLSessionDownloadTask *downloadTask) {
													  self.downloadTask = downloadTask;
												  }];
		}];
	}
}



- (void)downloadNotification:(NSNotification *)notification
{
	if ([notification.name isEqualToString:NOTIFICATION_DOWNLOAD_COMPLETE])
	{
		[self layoutButtons];
	}
	if ([notification.name isEqualToString:NOTIFICATION_DOWNLOAD_PROGRESS])
	{
		float progress = [notification.userInfo[kPROGRESS] floatValue];
		DLog(@"Progess: %f", progress);
		downloadButton.title = [NSString stringWithFormat:@"Henter %.0f%%",ceilf(100.0f*progress)];
	}
}


- (void)stream
{
	[[DRHandler sharedInstance] getVideoLinkForEpisode:self.episode completion:^(NSString *urlString) {
		NSURL *url = [NSURL URLWithString:urlString];
		[self playVideoWithURL:url movieSourceType:MPMovieSourceTypeStreaming];
	}];
}



- (void)playVideoWithURL:(NSURL *)url movieSourceType:(MPMovieSourceType)movieSourceType
{
	// Allow audio playback with muteswitch in mute
	NSError *setCategoryErr = nil;
    NSError *activationErr  = nil;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error:&setCategoryErr];
    [[AVAudioSession sharedInstance] setActive: YES error:&activationErr];
	
#define MPvsAV 0
	if (MPvsAV == 0) {
		moviePlayerViewController = [MoviePlayerViewController new];
		moviePlayerViewController.moviePlayer.movieSourceType = movieSourceType; // Source must be set before url
		moviePlayerViewController.moviePlayer.contentURL = url;
		//	moviePlayerViewController.moviePlayer.controlStyle = MPMovieControlStyleEmbedded;
		
		UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
		[rootViewController presentMoviePlayerViewControllerAnimated:moviePlayerViewController];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(moviePlaybackDidFinish:)
													 name:MPMoviePlayerPlaybackDidFinishNotification
												   object:nil];
	}
	else
	{
		avPlayer = [AVPlayer playerWithURL:url];
		
		AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:avPlayer];
		avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
		layer.frame = CGRectMake(0, 0, 1024, 768);
		[self.view.layer addSublayer: layer];
		
		[avPlayer play];
	}
	
	
	UIImage *image = [UIImage imageWithContentsOfFile:[DataHandler pathForCachedFile:self.episode.image]];
	NSDictionary *songInfo = @{MPMediaItemPropertyTitle : self.episode.title,
							   MPMediaItemPropertyArtist : @"Doktor TV",
							   MPMediaItemPropertyPlaybackDuration : @(self.episode.duration.floatValue/1000.0f),
							   MPNowPlayingInfoPropertyPlaybackRate : @(1), // Duration and Rate _must_ be set to show up on lock screen
							   MPMediaItemPropertyArtwork : [[MPMediaItemArtwork alloc] initWithImage:image],
							   };
	[MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = songInfo;
}



- (void)moviePlaybackDidFinish:(NSNotification *)notification
{
	int reason = [[notification userInfo][MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
	switch (reason) {
		case MPMovieFinishReasonPlaybackEnded:
			DLog(@"Playback ended");
			break;
		case MPMovieFinishReasonUserExited:
			DLog(@"User exited");
			break;
		case MPMovieFinishReasonPlaybackError:
			DLog(@"Playback error");
			break;
			
		default:
			break;
	}
	
}




@end
