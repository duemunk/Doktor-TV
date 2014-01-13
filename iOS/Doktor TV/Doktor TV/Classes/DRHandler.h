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
@property (nonatomic, assign) BOOL useOwnServer; // ONLY USE IN DEVELOPMENT

+ (DRHandler *)sharedInstance;

- (void)refreshMainData:(RefreshCompletionHandler)refreshCompletionHandler;

- (void)queryPrograms;

// Test queries
- (void)queryPrograms9outof10;
- (void)queryPrograms1outof10;

- (void)validateImageForProgram:(Program *)program;
- (void)validateImageForEpisode:(Episode *)episode;
- (void)validateEpisodesForProgram:(Program *)program;
- (void)getVideoLinkForEpisode:(Episode *)episode completion:(void (^)(NSString *))completion;

@end
