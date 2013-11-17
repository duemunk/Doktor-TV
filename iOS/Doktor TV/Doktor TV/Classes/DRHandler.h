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

- (void)validateEpisodesForProgram:(Program *)program;
- (void)runVideo:(void (^)(NSString *urlString))completion forEpisode:(Episode *)episode;
- (void)downloadVideoForEpisode:(Episode *)episode block:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progressBlock;

@end
