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

typedef void (^RefreshCompletionHandler)(BOOL didReceiveNewData);

@interface DRHandler : NSObject

@property (nonatomic, strong) AFHTTPSessionManager *afHttpSessionManager;

+ (DRHandler *)sharedInstance;

- (void)refreshMainData:(RefreshCompletionHandler)refreshCompletionHandler;

- (void)queryPrograms;
- (void)validateImageForProgram:(Program *)program;
- (void)validateImageForEpisode:(Episode *)episode;
- (void)validateEpisodesForProgram:(Program *)program;
- (void)getVideoLinkForEpisode:(Episode *)episode completion:(void (^)(NSString *))completion;

@end
