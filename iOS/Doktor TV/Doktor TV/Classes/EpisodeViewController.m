//
//  EpisodeViewController.m
//  Doktor TV
//
//  Created by Tobias DM on 16/11/13.
//  Copyright (c) 2013 developmunk. All rights reserved.
//

#import "EpisodeViewController.h"

#import "Button.h"

@interface EpisodeViewController ()

@end

@implementation EpisodeViewController
{
	Button *streamButton, *downloadButton;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// Do any additional setup after loading the view.
	downloadButton = [Button new];
	downloadButton.title = @"Hent";
	[self.view addSubview:downloadButton];
	[downloadButton addTarget:self action:@selector(download) forControlEvents:UIControlEventTouchUpInside];
	
	streamButton = [Button new];
	[streamButton setTitle:@"Afspil" forState:UIControlStateNormal];
	[self.view addSubview:streamButton];
	[streamButton addTarget:self action:@selector(stream) forControlEvents:UIControlEventTouchUpInside];
	
	CGFloat padding = 20.0f;
	downloadButton.keepLeftInset.equal =
	streamButton.keepRightInset.equal = KeepRequired(padding);
	
	NSArray *buttons = @[downloadButton,streamButton];
	[buttons keepBaselineAligned];
	[buttons keepHorizontalOffsets:KeepRequired(padding)];
	[buttons keepSizesEqual];
	 
	[downloadButton keepVerticallyCentered];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setEpisode:(Episode *)episode
{
	if (episode != _episode) {
		_episode = episode;
		
		streamButton.enabled =
		downloadButton.enabled = episode.uri.boolValue;
	}
}



- (void)download
{
	
}

- (void)stream
{
	
}

@end
