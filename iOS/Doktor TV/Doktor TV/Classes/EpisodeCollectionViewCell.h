//
//  EpisodeCollectionViewCell.h
//  Doktor TV
//
//  Created by Tobias DM on 16/11/13.
//  Copyright (c) 2013 developmunk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Episode;

#import "CollectionViewCell.h"

@interface EpisodeCollectionViewCell : CollectionViewCell

@property (nonatomic, strong) Episode *episode;

@end
