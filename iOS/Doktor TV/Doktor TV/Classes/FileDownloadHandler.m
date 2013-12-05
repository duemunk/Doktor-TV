//
//  FileDownloadHandler.m
//  Doktor TV
//
//  Created by Tobias DM on 05/12/13.
//  Copyright (c) 2013 developmunk. All rights reserved.
//

#import "FileDownloadHandler.h"

#import "AFNetworking.h"
#import "DataHandler.h"

@interface FileDownloadHandler ()

//@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) AFURLSessionManager *sessionManager;
@property (nonatomic, strong) NSMutableArray *downloadArray;

@end


@implementation FileDownloadHandler

+ (FileDownloadHandler *)sharedInstance
{
    static FileDownloadHandler *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [FileDownloadHandler new];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}



- (instancetype)init
{
	self = [super init];
	if (self) {
	}
	return self;
}




//- (NSOperationQueue *)operationQueue
//{
//	if (!_operationQueue) {
//		_operationQueue = [NSOperationQueue new];
//		_operationQueue.name = @"File download operation queue";
//		_operationQueue.maxConcurrentOperationCount = 1;
//	}
//	return _operationQueue;
//}


- (NSMutableArray *)downloadArray
{
	if (!_downloadArray) {
		_downloadArray = [@[] mutableCopy];
	}
	return _downloadArray;
}



//- (void)download:(NSString *)urlString toFileName:(NSString *)filename progressBlock:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progressBlock priority:(NSOperationQueuePriority)priority completionBlock:(void (^)(BOOL succeeded))completionBlock
//{
//	// Init
//	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
//	AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//	
//	// If progress block, use default
//	if (!progressBlock) {
//		progressBlock = ^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
//			DLog(@"Progess: %f", (float)totalBytesRead / (float)totalBytesExpectedToRead);
//		};
//	}
//	[operation setDownloadProgressBlock:progressBlock];
//	
//	// Save to temp
//	NSString *tempPath = [DataHandler pathForTempFile:filename];
//	operation.outputStream = [NSOutputStream outputStreamToFileAtPath:tempPath append:NO];
//	
//	DLog(@"Begins download of %@ to %@",urlString,tempPath);
//	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
//	 {
//		 DLog(@"Successfully downloaded file to %@", tempPath);
//		 // Move to cache folder
//		 NSString *cachePath = [DataHandler pathForCachedFile:filename];
//		 [[NSFileManager defaultManager] moveItemAtPath:tempPath toPath:cachePath error:nil];
//		 
//		 // Run completionblock
//		 completionBlock(YES);
//		 
//	 } failure:^(AFHTTPRequestOperation *operation, NSError *error)
//	 {
//		 DLog(@"Error: %@", error);
//		 // Run completionblock
//		 completionBlock(NO);
//	 }];
//	
//	operation.queuePriority = priority;
//	
//	[self.operationQueue addOperation:operation];
//}



- (AFURLSessionManager *)sessionManager
{
	if (!_sessionManager) {
		NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:@"AppIdentifier: Doktor_TV"];
		_sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
	}
	return _sessionManager;
}



- (void)download:(NSString *)urlString toFileName:(NSString *)fileName completionBlock:(void (^)(BOOL succeeded))completionBlock
{
	// TODO: Check if resumable data is avialable
	
	
	
	
	
	// 
	NSURL *URL = [NSURL URLWithString:urlString];
	NSURLRequest *request = [NSURLRequest requestWithURL:URL];
	
	__block NSURLSessionDownloadTask *downloadTask =
	[self.sessionManager downloadTaskWithRequest:request
										progress:nil
									 destination: ^NSURL *(NSURL *targetPath, NSURLResponse *response) {
										 NSString *filePath = response.suggestedFilename;
										 filePath = [DataHandler pathForTempFile:filePath];
										 return [NSURL fileURLWithPath:filePath];
									 }
							   completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
								   if (error) {
									   DLog(@"%@",error);
									   completionBlock(NO);
									   return;
								   }
								   NSURL *cachePath = [NSURL fileURLWithPath:[DataHandler pathForCachedFile:fileName]];
								   NSLog(@"File downloaded to: %@, moving to: %@", filePath, cachePath);
								   
								   
								   if ([[NSFileManager defaultManager] fileExistsAtPath:filePath.path isDirectory:NO])
								   {
									   NSError *fileMoveError;
									   [[NSFileManager defaultManager] moveItemAtURL:filePath toURL:cachePath error:&fileMoveError];
									   if (fileMoveError) {
										   DLog(@"%@",fileMoveError);
										   completionBlock(NO);
										   return;
									   }
									   completionBlock(YES);
								   }
								   
								   [self completedDownload:downloadTask];
							   }];
	
	downloadTask.taskDescription = fileName;
	[self addDownloadTaskToQueue:downloadTask];
}


- (void)addDownloadTaskToQueue:(NSURLSessionDownloadTask *)downloadTask
{
	[self.downloadArray addObject:downloadTask];
	
	[self checkDownloadQueue];
}

- (void)completedDownload:(NSURLSessionDownloadTask *)downloadTask
{
	DLog(@"Completed download %@",downloadTask.taskDescription);
	[self.downloadArray removeObject:downloadTask];
	
	[self checkDownloadQueue];
}

#define maxDownloadCount 3
- (void)checkDownloadQueue
{
	NSUInteger i = 0;
	for (NSURLSessionDownloadTask *downloadTask in self.downloadArray)
	{
		if (downloadTask.state == NSURLSessionTaskStateSuspended)
		{
			if (i < maxDownloadCount)
			{
				i++;
				[downloadTask resume];
				DLog(@"Resuming download %@",downloadTask.taskDescription);
			}
			else
			{
				DLog(@"Running downloads too high %lu > %d, total in queue: %lu", i,maxDownloadCount,self.downloadArray.count);
				return;
			}
		}
		else
			i++;
	}
}


- (void)cancelDownloadTask:(NSURLSessionDownloadTask *)downloadTask
{
	[downloadTask cancelByProducingResumeData:^(NSData *resumeData) {
		// TODO:
//		NSString *fileName = downloadTask.originalRequest.URL.lastPathComponent;
//		fileName = [fileName stringByAppendingPathExtension:@""];
//		[DataHandler]
//		[resumeData writeToFile:<#(NSString *)#> atomically:YES];
	}];
	[self.downloadArray removeObject:downloadTask];
	[self checkDownloadQueue];
}

@end