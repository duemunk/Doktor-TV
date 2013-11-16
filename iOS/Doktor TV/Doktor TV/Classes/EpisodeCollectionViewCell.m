//
//  EpisodeCollectionViewCell.m
//  Doktor TV
//
//  Created by Tobias DM on 16/11/13.
//  Copyright (c) 2013 developmunk. All rights reserved.
//

#import "EpisodeCollectionViewCell.h"

#import "Episode.h"
#import "Season.h"

@implementation EpisodeCollectionViewCell
{
	UILabel *testLabel;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.backgroundColor = [UIColor iOS7lightGrayColor];
    }
    return self;
}

- (void)setEpisode:(Episode *)episode
{
	if (episode != _episode) {
		_episode = episode;
		
		if (!testLabel) {
			testLabel = [UILabel new];
			[self addSubview:testLabel];
			[testLabel keepInsets:UIEdgeInsetsZero];
			testLabel.numberOfLines = 0;
			testLabel.textColor = [UIColor whiteColor];
		}
		
		testLabel.text = [NSString stringWithFormat:@"Season %@, \nEpisode %@",self.episode.season.number,self.episode.number];
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
