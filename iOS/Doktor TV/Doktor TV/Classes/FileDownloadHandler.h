//
//  FileDownloadHandler.h
//  Doktor TV
//
//  Created by Tobias DM on 05/12/13.
//  Copyright (c) 2013 developmunk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileDownloadHandler : NSObject <NSURLSessionDelegate>

+ (FileDownloadHandler *)sharedInstance;

//- (void)download:(NSString *)urlString toFileName:(NSString *)filename progressBlock:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progressBlock priority:(NSOperationQueuePriority)priority completionBlock:(void (^)(BOOL succeeced))completionBlock;

- (NSURLSessionDownloadTask *)download:(NSString *)urlString toFileName:(NSString *)fileName completionBlock:(void (^)(BOOL succeeded))completionBlock;
- (void)cancelDownloadTask:(NSURLSessionDownloadTask *)downloadTask;

@end
