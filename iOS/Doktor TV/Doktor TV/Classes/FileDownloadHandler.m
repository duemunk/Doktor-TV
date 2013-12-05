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
	if (!_sessionManager)
	{
		NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration]; // backgroundSessionConfiguration:@"AppIdentifier: Doktor_TV"];
		_sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
	}
	return _sessionManager;
}



- (NSURLSessionDownloadTask *)download:(NSString *)urlString toFileName:(NSString *)fileName completionBlock:(void (^)(BOOL succeeded))completionBlock
{
	NSURLSessionDownloadTask *downloadTask;
	
	NSURL *url = [NSURL URLWithString:urlString];
	NSURL *tempPath = [NSURL fileURLWithPath:[DataHandler pathForTempFile:fileName]];
	
	
	// Check if already downloading
	for (NSURLSessionDownloadTask *_downloadTask in self.sessionManager.downloadTasks)
	{
		NSURL *_url = _downloadTask.currentRequest.URL;
		if ([_url isEqual:url])
		{
			// Cancel running task, and allow new to be created in order to use new completionBlock
			[self cancelDownloadTask:_downloadTask];
		}
	}
	
	// Destination
	NSURL *(^destination)(NSURL *targetPath, NSURLResponse *response) = ^NSURL *(NSURL *targetPath, NSURLResponse *response) {
		//[NSString stringWithFormat:@"%@__%@",urlString.lastPathComponent,response.suggestedFilename];
		return tempPath;
	};
	
	// Progress
	NSProgress *progress;
	
	// Completion handler
	void (^completionHandler)(NSURLResponse *response, NSURL *filePath, NSError *error) = ^(NSURLResponse *response, NSURL *filePath, NSError *error) {
		if (error) {
			DLog(@"%@",error);
			completionBlock(NO);
			return;
		}
		NSURL *cachePath = [NSURL fileURLWithPath:[DataHandler pathForCachedFile:fileName]];
		NSLog(@"File downloaded \nto: \n%@, \nmoving to: \n%@", filePath, cachePath);
		
		
		if ([[NSFileManager defaultManager] fileExistsAtPath:filePath.path isDirectory:NO])
		{
			if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath.path isDirectory:NO]) {
				DLog(@"Already exists %@",cachePath);
			}
			
			NSError *fileMoveError;
			if (![[NSFileManager defaultManager] moveItemAtURL:filePath toURL:cachePath error:&fileMoveError]) {
				DLog(@"%@",fileMoveError);
				completionBlock(NO);
				return;
			}
			completionBlock(YES);
		}
	};
	
	
	// Check if resumable data is available
	NSString *resumeDataFileName = [self resumeDataPathForUrl:url];
	if ([[NSFileManager defaultManager] fileExistsAtPath:resumeDataFileName])
	{
		NSData *resumeData = [NSData dataWithContentsOfFile:resumeDataFileName];
		NSError *error;
		if (![[NSFileManager defaultManager] removeItemAtPath:resumeDataFileName error:&error]) {
			DLog(@"Couldn't remove resumeData file: %@, %@",resumeDataFileName,error);
			return nil;
		}
		downloadTask = [self.sessionManager downloadTaskWithResumeData:resumeData
															  progress:&progress
														   destination:destination
													 completionHandler:completionHandler];
		DLog(@"Resuming download \nurl: \n%@ \nto: \n%@",urlString,tempPath);
		return downloadTask;
	}
	else
	{
		// Regular download
		NSURLRequest *request = [NSURLRequest requestWithURL:url];
		
		downloadTask = [self.sessionManager downloadTaskWithRequest:request
														   progress:&progress
														destination:destination
												  completionHandler:completionHandler];
		
		DLog(@"Starting download \nurl: \n%@ \nto: \n%@",urlString,tempPath);
		[downloadTask resume];
	}
	
	if (downloadTask) {
		[progress addObserver:self
				   forKeyPath:@"fractionCompleted"
					  options:NSKeyValueObservingOptionNew
					  context:NULL];
		downloadTask.taskDescription = fileName;
	}
	
	return downloadTask;
	
	return nil;
}



- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"fractionCompleted"])
	{
		NSProgress *progress = (NSProgress *)object;
		NSLog(@"Progress %@", progress.localizedDescription);
		return;
	}
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}


//- (void)addDownloadTaskToQueue:(NSURLSessionDownloadTask *)downloadTask
//{
//	[self.downloadArray addObject:downloadTask];
//	
//	[self checkDownloadQueue];
//}
//
//- (void)completedDownload:(NSURLSessionDownloadTask *)downloadTask
//{
//	DLog(@"Completed download %@",downloadTask.taskDescription);
//	NSLog(@"%@",self.downloadArray);
//	[self.downloadArray removeObject:downloadTask];
//	downloadTask = nil;
//	NSLog(@"%@",self.downloadArray);
//	
//	[self checkDownloadQueue];
//}
//
//#define maxDownloadCount 1
//- (void)checkDownloadQueue
//{
//	// Remove
//	
//	
//	NSUInteger i = 0;
//	for (NSURLSessionDownloadTask *downloadTask in self.downloadArray)
//	{
//		if (downloadTask.state == NSURLSessionTaskStateSuspended)
//		{
//			if (i < maxDownloadCount)
//			{
//				i++;
//				[downloadTask resume];
//				DLog(@"Resuming download %@",downloadTask.taskDescription);
//			}
//			else
//			{
//				DLog(@"Running downloads too high %lu > %d, total in queue: %lu", i,maxDownloadCount,self.downloadArray.count);
//				return;
//			}
//		}
//		else
//			i++;
//	}
//}


- (void)cancelDownloadTask:(NSURLSessionDownloadTask *)downloadTask
{
	if (downloadTask)
	{
		[downloadTask cancelByProducingResumeData:^(NSData *resumeData) {
			// Save resumable data to disc
			if (resumeData.length)
			{
				NSString *fileName = [self resumeDataPathForUrl:downloadTask.originalRequest.URL];
				[resumeData writeToFile:fileName atomically:YES];
				DLog(@"Saved resume data: %@ size: %lu", fileName,resumeData.length);
			}
		}];
	}
}

- (NSString *)resumeDataPathForUrl:(NSURL *)url
{
	NSString *path = url.lastPathComponent;
	path = [path stringByAppendingPathExtension:@"resumableData"];
	path = [DataHandler pathForTempFile:path];
	return path;
}

@end