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

@property (nonatomic, strong) NSURLSession *defaultSession;

@property (strong, nonatomic) NSMutableDictionary *completionHandlerDictionary;

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
		
		NSString *bundleIDString = [NSBundle mainBundle].infoDictionary[@"CFBundleIdentifier"];
		NSString *sessionName = [NSString stringWithFormat:@"%@.bgSession", bundleIDString];
		
		// TODO: Add new not-background session for small downloads (as program and episode images)
		NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:sessionName];
//		configuration.allowsCellularAccess = NO;
		_backgroundTransferSession = [NSURLSession sessionWithConfiguration:configuration
																   delegate:self
															  delegateQueue:nil];
		
		_defaultSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
														delegate:self
												   delegateQueue:nil];
		
		
//		NSURLSessionDownloadTask *downloadTask = [self download:@"http://vodfiles.dr.dk/CMS/Resources/dr.dk/NETTV/DR3/2013/11/dd50a214-8aee-4c6a-8631-70a0c671a1b1/BoesseStudier---Stereotyper--2_9a4fb08b27d24c46992e81bd967a52b4_122.mp4?ID=1629336"
//														 toFile:@"testFile.mp4"];
		
//		[downloadTask performSelector:@selector(suspend) withObject:nil afterDelay:10.0f];
//		[self performSelector:@selector(cancelDownloadTask:) withObject:downloadTask afterDelay:5.0f];
	}
	return self;
}






- (void)wakeSessionWithCompletionHandler:(CompletionHandlerType)handler sessionIdentifier:(NSString *)identifier
{
	NSAssert([identifier isEqualToString:self.backgroundTransferSession.configuration.identifier], @"Identifer doesn't match background session");
	
	[self addCompletionHandler:handler forSession:identifier];
}


- (void)addCompletionHandler:(CompletionHandlerType)handler forSession:(NSString *)identifier
{
    if ([self.completionHandlerDictionary objectForKey:identifier]) {
        NSLog(@"Error: Got multiple handlers for a single session identifier.  This should not happen.\n");
    }
	
    [self.completionHandlerDictionary setObject:handler forKey:identifier];
}

- (void)callCompletionHandlerForSession:(NSString *)identifier
{
    CompletionHandlerType handler = [self.completionHandlerDictionary objectForKey:identifier];
	
    if (handler) {
        [self.completionHandlerDictionary removeObjectForKey: identifier];
        NSLog(@"Calling completion handler for session %@", identifier);
		
        handler();
    }
}

- (NSMutableDictionary *)completionHandlerDictionary
{
	if (!_completionHandlerDictionary) {
		_completionHandlerDictionary = [@{} mutableCopy];
	}
	return _completionHandlerDictionary;
}


#pragma mark - NSURLSessionDelegate

// Is called after NSURLSession delegate messages are sent
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    NSLog(@"Background URL session %@ finished events.\n", session);
	
    if (session.configuration.identifier)
	{
		// Notify user that all downloads are finished
		UILocalNotification *notification = [UILocalNotification new];
		notification.alertBody = NSLocalizedString(@"Dine programmer er blevet hentet", @"");
		notification.alertAction = NSLocalizedString(@"Se", nil);
		notification.soundName = UILocalNotificationDefaultSoundName;
		notification.applicationIconBadgeNumber = 1;
		[[UIApplication sharedApplication] presentLocalNotificationNow:notification];
		
        // Call the handler we stored in -application:handleEventsForBackgroundURLSession:
        [self callCompletionHandlerForSession:session.configuration.identifier];
    }
}
















#pragma mark - Download methods


#define kFILE_NAME @"FILE_NAME"
#define kPERSISTENT @"kPERSISTENT"
- (void)download:(NSString *)urlString toFile:(NSString *)fileName backgroundTransfer:(BOOL)backgroundTransfer completion:(void (^)(NSURLSessionDownloadTask *downloadTask))completion
{
	[self download:urlString toFile:fileName backgroundTransfer:backgroundTransfer observer:nil selector:0 completion:completion];
}
- (void)download:(NSString *)urlString toFile:(NSString *)fileName backgroundTransfer:(BOOL)backgroundTransfer observer:(id)observer selector:(SEL)selector completion:(void (^)(NSURLSessionDownloadTask *downloadTask))completion
{
	[self download:urlString toFile:fileName backgroundTransfer:backgroundTransfer observer:observer selector:selector completion:completion persistent:YES]; // Default to store persistent and not in Caches
}
/**
 @param persistent File is stored persistently. For non-persistent file is save in Caches directory and might be deleted by OS. Use  method pathForFile:persistent: to get file path for filename
 */
- (void)download:(NSString *)urlString toFile:(NSString *)fileName backgroundTransfer:(BOOL)backgroundTransfer observer:(id)observer selector:(SEL)selector completion:(void (^)(NSURLSessionDownloadTask *downloadTask))completion persistent:(BOOL)persistent
{
	NSParameterAssert(urlString);
	NSParameterAssert(fileName);
	
	NSURLSession *session = backgroundTransfer ? self.backgroundTransferSession : self.defaultSession;
	
	// Check if already downloading
	[self findExistingDownload:^(NSURLSessionDownloadTask *downloadTask)
	{
		if (!downloadTask)
		{
			NSURL *url = [NSURL URLWithString:urlString];
			// First check for resume data
			NSData *resumeData = [self resumeDataForUrl:url];
			// If no resume data, create new downloadTask
			downloadTask = resumeData ? [session downloadTaskWithResumeData:resumeData] : [session downloadTaskWithURL:url];
		}
		
		[[NSUserDefaults standardUserDefaults] setObject:@{kFILE_NAME:fileName,
														   kPERSISTENT:@(persistent)}
												  forKey:@(downloadTask.taskIdentifier).stringValue];
		
		[downloadTask resume];
		
		if (observer)
		{
			[[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:NOTIFICATION_DOWNLOAD_PROGRESS object:downloadTask];
			[[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:NOTIFICATION_DOWNLOAD_COMPLETE object:downloadTask];
		}
		completion(downloadTask);
		
	} urlString:urlString session:session];
}

- (void)findExistingDownload:(NSString *)urlString backgroundTransfer:(BOOL)backgroundTransfer observer:(id)observer selector:(SEL)selector completion:(void (^)(NSURLSessionDownloadTask *downloadTask))completion
{
	NSParameterAssert(urlString);
	NSParameterAssert(completion);
	
	NSURLSession *session = backgroundTransfer ? self.backgroundTransferSession : self.defaultSession;
	[self findExistingDownload:^(NSURLSessionDownloadTask *downloadTask)
	{
		if (downloadTask)
		{
			if (observer)
			{
				[[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:NOTIFICATION_DOWNLOAD_PROGRESS object:downloadTask];
				[[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:NOTIFICATION_DOWNLOAD_COMPLETE object:downloadTask];
			}
		}
		completion(downloadTask);
	} urlString:urlString session:session];
}

- (void)findExistingDownload:(void (^)(NSURLSessionDownloadTask *downloadTask))completion urlString:(NSString *)urlString session:(NSURLSession *)session
{
	__block NSURL *url = [NSURL URLWithString:urlString];
	
	[session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks)
	{
		NSURLSessionDownloadTask *downloadTask;
		DLog(@"%lu",(unsigned long)downloadTasks.count);
		for (NSURLSessionDownloadTask *_downloadTask in downloadTasks)
		{
			DLog(@"\n\n%@\n\n%@\n\n",url,_downloadTask.originalRequest.URL);
			if ([url isEqual:_downloadTask.originalRequest.URL])
				downloadTask = _downloadTask;
		}
		completion(downloadTask);
	}];
}















#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
	if (error)
	{
		NSData *resumeData = error.userInfo[NSURLSessionDownloadTaskResumeData];
		[self saveResumeData:resumeData forURL:task.originalRequest.URL];
	}
}

#pragma mark - NSURLSessionDownloadTaskDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
	float progress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
	DLog(@"Progess: %f", progress);
	dispatch_async(dispatch_get_main_queue(), ^{
		[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DOWNLOAD_PROGRESS object:downloadTask userInfo:@{kPROGRESS:@(progress)}];
	});
}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
	DLog(@"%@",downloadTask);
	DLog(@"%@",location);
	
	NSDictionary *info = [[NSUserDefaults standardUserDefaults] objectForKey:@(downloadTask.taskIdentifier).stringValue];
	NSString *fileName = info[kFILE_NAME];
	if (!fileName) {
		DLog(@"No filename for task %lu",(unsigned long)downloadTask.taskIdentifier);
		return;
	}
	
	NSNumber *persistent = info[kPERSISTENT];
	if (!persistent) {
		persistent = @YES; // Default
		DLog(@"Persistence not set for task %lu",(unsigned long)downloadTask.taskIdentifier);
	}
	
	NSString *filePath = [DataHandler pathForFile:fileName persistent:persistent.boolValue];
	NSURL *fileURL = [NSURL fileURLWithPath:filePath];
	NSLog(@"File downloaded \nto: \n%@, \nmoving to: \n%@", location, fileURL);
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:location.path isDirectory:NO])
	{
		if ([fileManager fileExistsAtPath:fileURL.path isDirectory:NO])
		{
			DLog(@"Already exists %@",fileURL);
			[fileManager removeItemAtURL:location error:nil];
			return;
		}
		else
		{
			NSError *fileMoveError;
			if (![fileManager moveItemAtURL:location toURL:fileURL error:&fileMoveError]) {
				DLog(@"%@",fileMoveError);
				return;
			}
			
			// Tell iCloud not to backup this file
			[self addSkipBackupAttributeToItemAtURL:fileURL];
		}
	}
	
	dispatch_async(dispatch_get_main_queue(), ^{
		[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DOWNLOAD_COMPLETE object:downloadTask userInfo:nil];
	});
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
	DLog(@"Resuming %@, offset %lld, expectedTotal %lld",downloadTask.originalRequest.URL.path,fileOffset,expectedTotalBytes);
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
		NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
		_sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
	}
	return _sessionManager;
}


//- (NSURLSessionDownloadTask *)download:(NSString *)urlString toFileName:(NSString *)fileName completionBlock:(void (^)(BOOL succeeded))completionBlock
//{
//	// Progress
//	NSProgress *progress;
//	NSURLSessionDownloadTask *downloadTask = [self download:urlString toFileName:fileName progress:&progress completionBlock:completionBlock];
//	if (downloadTask)
//	{
//		[progress addObserver:self
//				   forKeyPath:@"fractionCompleted"
//					  options:NSKeyValueObservingOptionNew
//					  context:NULL];
//	}
//	return downloadTask;
//}

//- (NSURLSessionDownloadTask *)download:(NSString *)urlString toFileName:(NSString *)fileName progress:(NSProgress * __autoreleasing *)progress completionBlock:(void (^)(BOOL succeeded))completionBlock
//{
//	return nil;
//	
//	
//	NSURLSessionDownloadTask *downloadTask;
//	
//	NSURL *url = [NSURL URLWithString:urlString];
//	NSURL *tempPath = [NSURL fileURLWithPath:[DataHandler pathForCachedFile:fileName] isDirectory:NO];
//	
//	
//	// Destination
//	NSURL *(^destination)(NSURL *targetPath, NSURLResponse *response) = ^NSURL *(NSURL *targetPath, NSURLResponse *response) {
//		//[NSString stringWithFormat:@"%@__%@",urlString.lastPathComponent,response.suggestedFilename];
//		return tempPath;
//	};
//	
//	
//	// Completion handler
//	void (^completionHandler)(NSURLResponse *response, NSURL *filePath, NSError *error) = ^(NSURLResponse *response, NSURL *filePath, NSError *error) {
//		if (error) {
//			DLog(@"%@",error);
//			completionBlock(NO);
//			return;
//		}
//		NSURL *cachePath = [NSURL fileURLWithPath:[DataHandler pathForCachedFile:fileName]];
//		NSLog(@"File downloaded \nto: \n%@, \nmoving to: \n%@", filePath, cachePath);
//		
//		
//		if ([[NSFileManager defaultManager] fileExistsAtPath:filePath.path isDirectory:NO])
//		{
//			if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath.path isDirectory:NO]) {
//				DLog(@"Already exists %@",cachePath);
//			}
//			
//			NSError *fileMoveError;
//			if (![[NSFileManager defaultManager] moveItemAtURL:filePath toURL:cachePath error:&fileMoveError]) {
//				DLog(@"%@",fileMoveError);
//				completionBlock(NO);
//				return;
//			}
//			completionBlock(YES);
//		}
//	};
//	
//	
//	
//	// Check if already downloading
//	for (NSURLSessionDownloadTask *_downloadTask in self.sessionManager.downloadTasks)
//	{
//		NSURL *_url = _downloadTask.originalRequest.URL;
//		if ([_url isEqual:url])
//		{
//			downloadTask = _downloadTask;
//		}
//	}
//	
//	
//	if (downloadTask)
//	{
//		downloadTask = [self.sessionManager downloadTaskWithRequest:downloadTask.currentRequest
//														   progress:progress
//														destination:destination
//												  completionHandler:completionHandler];
//		DLog(@"Resuming download \nurl: \n%@ \nto: \n%@",urlString,tempPath);
//	}
////	// Check if resumable data is available
////	NSString *resumeDataFileName = [self resumeDataPathForUrl:url];
////	else if ([[NSFileManager defaultManager] fileExistsAtPath:resumeDataFileName])
////	{
////		NSData *resumeData = [NSData dataWithContentsOfFile:resumeDataFileName];
////		NSError *error;
////		if (![[NSFileManager defaultManager] removeItemAtPath:resumeDataFileName error:&error]) {
////			DLog(@"Couldn't remove resumeData file: %@, %@",resumeDataFileName,error);
////			return nil;
////		}
////		downloadTask = [self.sessionManager downloadTaskWithResumeData:resumeData
////															  progress:progress
////														   destination:destination
////													 completionHandler:completionHandler];
////		DLog(@"Resuming download \nurl: \n%@ \nto: \n%@",urlString,tempPath);
////	}
//	else
//	{
//		// Regular download
//		NSURLRequest *request = [NSURLRequest requestWithURL:url];
//		
//		downloadTask = [self.sessionManager downloadTaskWithRequest:request
//														   progress:progress
//														destination:destination
//												  completionHandler:completionHandler];
//		
//		DLog(@"Starting download \nurl: \n%@ \nto: \n%@",urlString,tempPath);
//	}
//	
//	if (downloadTask) {
//		[downloadTask resume];
//		downloadTask.taskDescription = fileName;
//	}
//	
//	return downloadTask;
//}



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


- (void)saveResumeData:(NSData *)resumeData forURL:(NSURL *)url
{
	if (resumeData.length)
	{
		NSString *fileName = [self resumeDataPathForUrl:url];
		[resumeData writeToFile:fileName atomically:YES];
		DLog(@"Saved resume data: %@ size: %lu", fileName,(unsigned long)resumeData.length);
	}
}

- (NSData *)resumeDataForUrl:(NSURL *)url
{
	NSString *resumeDataFileName = [self resumeDataPathForUrl:url];
	if ([[NSFileManager defaultManager] fileExistsAtPath:resumeDataFileName])
	{
		NSData *resumeData = [NSData dataWithContentsOfFile:resumeDataFileName];
		NSError *error;
		if (![[NSFileManager defaultManager] removeItemAtPath:resumeDataFileName error:&error])
			DLog(@"Couldn't remove resumeData file: %@, %@",resumeDataFileName,error);
		
		return resumeData;
	}
	return nil;
}

- (NSString *)resumeDataPathForUrl:(NSURL *)url
{
	NSString *path = url.lastPathComponent;
	path = [path stringByAppendingPathExtension:@"resumableData"];
	path = [DataHandler pathForFile:path persistent:NO];
	return path;
}














- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    assert([[NSFileManager defaultManager] fileExistsAtPath:URL.path]);
	
    NSError *error = nil;
    BOOL success = [URL setResourceValue:@YES
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", URL.lastPathComponent, error);
    }
    return success;
}




@end