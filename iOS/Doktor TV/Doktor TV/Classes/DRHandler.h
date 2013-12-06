//
//  DRHandler.h
//  Doktor TV
//
//  Created by Tobias DM on 16/11/13.
//  Copyright (c) 2013 developmunk. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AFNetworking.h"

@class Program, Episode;


@interface DRHandler : NSObject

@property (nonatomic, strong) AFHTTPSessionManager *afHttpSessionManager;

+ (DRHandler *)sharedInstance;

- (void)queryPrograms;
- (void)validateImageForProgram:(Program *)program;
- (void)validateImageForEpisode:(Episode *)episode;
- (void)validateEpisodesForProgram:(Program *)program;
- (void)getVideoLinkForEpisode:(Episode *)episode completion:(void (^)(NSString *))completion;

@end
