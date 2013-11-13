//
//  VideoViewController.m
//  Doktor TV
//
//  Created by Tobias DM on 13/11/13.
//  Copyright (c) 2013 developmunk. All rights reserved.
//

#import "VideoViewController.h"

#import "KeepLayout.h"

@interface VideoViewController ()

@end

@implementation VideoViewController

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
	
	
	MPMoviePlayerController *moviePlayerController = [MPMoviePlayerController new];
	
	NSString *link = @"http://vodfiles.dr.dk/CMS/Resources/dr.dk/NETTV/DR3/2013/11/dd50a214-8aee-4c6a-8631-70a0c671a1b1/BoesseStudier---Stereotyper--2_9a4fb08b27d24c46992e81bd967a52b4_122.mp4?ID=1629336";
	moviePlayerController.contentURL = [NSURL URLWithString:link];
	moviePlayerController.movieSourceType = MPMovieSourceTypeStreaming;
	
	[self.view addSubview:moviePlayerController.view];
	
	moviePlayerController.view.keepInsets.equal = KeepRequired(0.0f);
	
	[moviePlayerController play];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
