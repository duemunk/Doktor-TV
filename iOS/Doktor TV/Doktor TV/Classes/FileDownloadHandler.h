//
//  FileDownloadHandler.h
//  Doktor TV
//
//  Created by Tobias DM on 05/12/13.
//  Copyright (c) 2013 developmunk. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^DRCompletionBlock)(BOOL succeeded);
typedef void (^CompletionHandlerType)(); // Should be defined in AppDelegate application:handleEventsForBackgroundURLSession:completionHandler:(void (^)())completionHandler


#define NOTIFICATION_DOWNLOAD_PROGRESS @"NOTIFICATION_DOWNLOAD_PROGRESS"
#define kPROGRESS @"kPROGRESS"
#define NOTIFICATION_DOWNLOAD_COMPLETE @"NOTIFICATION_DOWNLOAD_COMPLETE"



@interface FileDownloadHandler : NSObject <NSURLSessionDelegate, NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSURLSession *backgroundTransferSession;

+ (FileDownloadHandler *)sharedInstance;


- (void)wakeSessionWithCompletionHandler:(CompletionHandlerType)handler sessionIdentifier:(NSString *)identifier;

- (void)download:(NSString *)urlString toFile:(NSString *)fileName backgroundTransfer:(BOOL)backgroundTransfer completion:(void (^)(NSURLSessionDownloadTask *downloadTask))completion;
- (void)download:(NSString *)urlString toFile:(NSString *)fileName backgroundTransfer:(BOOL)backgroundTransfer observer:(id)observer selector:(SEL)selector completion:(void (^)(NSURLSessionDownloadTask *downloadTask))completion;
- (void)download:(NSString *)urlString toFile:(NSString *)fileName backgroundTransfer:(BOOL)backgroundTransfer observer:(id)observer selector:(SEL)selector completion:(void (^)(NSURLSessionDownloadTask *downloadTask))completion persistent:(BOOL)persistent;
/** Find download task, and if available, add observer
 @param urlString The URL of the source file.
 @param backgroundTransfer Look for download task in background transfers
 @param observer (Optional)
 @param selector (Optional)
 @param completion Completion handler with found download task
 */
- (void)findExistingDownload:(NSString *)urlString backgroundTransfer:(BOOL)backgroundTransfer observer:(id)observer selector:(SEL)selector completion:(void (^)(NSURLSessionDownloadTask *downloadTask))completion;

//- (void)download:(NSString *)urlString toFileName:(NSString *)filename progressBlock:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progressBlock priority:(NSOperationQueuePriority)priority completionBlock:(void (^)(BOOL succeeced))completionBlock;

//- (NSURLSessionDownloadTask *)download:(NSString *)urlString toFileName:(NSString *)fileName completionBlock:(void (^)(BOOL succeeded))completionBlock;
//- (NSURLSessionDownloadTask *)download:(NSString *)urlString toFileName:(NSString *)fileName progress:(NSProgress * __autoreleasing *)progress completionBlock:(void (^)(BOOL succeeded))completionBlock;

@end
