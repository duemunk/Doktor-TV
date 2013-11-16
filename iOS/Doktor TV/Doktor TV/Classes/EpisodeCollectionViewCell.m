//
//  EpisodeCollectionViewCell.m
//  Doktor TV
//
//  Created by Tobias DM on 16/11/13.
//  Copyright (c) 2013 developmunk. All rights reserved.
//

#import "EpisodeCollectionViewCell.h"

#import "DataHandler.h"

@implementation EpisodeCollectionViewCell
{
	UILabel *testLabel;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.4];
    }
    return self;
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
	}
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"image"])
	{
		[self setupImage];
	}
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
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
