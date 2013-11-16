//
//  DRHandler.m
//  Doktor TV
//
//  Created by Tobias DM on 16/11/13.
//  Copyright (c) 2013 developmunk. All rights reserved.
//

#import "DRHandler.h"

#import "DataHandler.h"

#import "AFNetworking.h"

@implementation DRHandler
{
	
}


+ (DRHandler *)sharedInstance
{
    static DRHandler *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [DRHandler new];
        // Do any other initialisation stuff here
		
		NSURL *URL = [NSURL URLWithString:@"http://www.dr.dk/mu"];
		sharedInstance.afHttpSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:URL];
		
		[sharedInstance queryPrograms];
    });
    return sharedInstance;
}





- (void)queryPrograms
{
	NSString *query =  @"http://www.dr.dk/mu/view/bundles-with-public-asset?ChannelType=TV";
	query = [self addLimit:16 urlString:query];
	
	[self.afHttpSessionManager GET:query parameters:nil success:^(NSURLSessionDataTask *task, id responseObject)
	{
		[self validateProgramsData:responseObject];
		
	} failure:^(NSURLSessionDataTask *task, NSError *error) {
		NSLog(@"ERROR: %@",error);
	}];
}

- (NSString *)addLimit:(NSUInteger)limit urlString:(NSString *)urlString
{
	return [urlString stringByAppendingFormat:@"&limit=$eq(%d)",limit];
}
- (NSString *)addOffset:(NSUInteger)offset urlString:(NSString *)urlString
{
	return [urlString stringByAppendingFormat:@"&offset=$eq(%d)",offset];
}



#define kDRResultsGeneratedDate @"ResultsGeneratedDate"
#define kDRData @"Data"
#define kDRResultProcessingTime @"ResultProcessingTime"

#define kDRUrn @"Urn"
#define kDRSeriesIdentifier @"SeriesIdentifier"
#define kDRTitle @"Title"
#define kDRSlug @"Slug"
#define kDRAssets @"Assets"

- (void)validateProgramsData:(NSDictionary *)programsDictionary
{
//	NSLog(@"Series: %@",programsDictionary);
	
	NSArray *data = programsDictionary[kDRData];
	
	NSArray *localPrograms = [[DataHandler sharedInstance] programs];
	
	for (NSDictionary *dict in data)
	{
		NSString *drID = dict[kDRUrn];
		
		NSArray *existingLocalPrograms = [localPrograms filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"drID = %@",drID]];
		if (existingLocalPrograms.count)
		{
			// TODO: Update?
		}
		else
		{
			// Check if program has content
			
			// Create new program
			Program *program = [[DataHandler sharedInstance] newProgramAssociated:NO];
			program.drID = drID;
			program.title = dict[kDRTitle];
			program.slug = dict[kDRSlug];
			
			[self validateProgram:program];
		}
	}
	
	
//	[[DataHandler sharedInstance] saveContext];
	
	
	
	return;
}



- (void)validateProgram:(Program *)progam
{
	NSString *query = [NSString stringWithFormat:@"http://www.dr.dk/mu/programcard?Relations.Slug=%@",progam.slug];
	
	__block Program *p = progam;
	[self.afHttpSessionManager GET:query parameters:nil success:^(NSURLSessionDataTask *task, id responseObject)
	 {
		 [self validateProgramData:responseObject forProgram:p];
		 
	 } failure:^(NSURLSessionDataTask *task, NSError *error) {
		 NSLog(@"ERROR: %@",error);
	 }];
}

#define kDRContentType @"ContentType"
#define kDRKind @"Kind"
#define kDRUri @"Uri"

- (void)validateProgramData:(NSDictionary *)programDictionary forProgram:(Program *)program
{
	NSArray *data = programDictionary[kDRData];
	
	NSDictionary *lastEpisodeData = data.firstObject;
	NSArray *assets = lastEpisodeData[kDRAssets];
	
	BOOL failed = YES;
	if (assets.count) {
		NSArray *imageAsset = [assets filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K = %@",kDRContentType,@"image/jpeg"]];
		if (!imageAsset.count) {
			imageAsset = [assets filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K = %@",kDRKind,@"Image"]];
		}
		if (imageAsset.count)
		{
			[[DataHandler sharedInstance] associateObject:program];
			[[DataHandler sharedInstance] saveContext];
			
			NSDictionary *imageDict = imageAsset.firstObject;
			NSString *imageUrlString = imageDict[kDRUri];
			imageUrlString = [imageUrlString stringByAppendingString:@"?width=320&height=320"];
			NSString *fileName = [NSString stringWithFormat:@"ProgramImage__%@.jpg",program.drID];
			[self download:imageUrlString toFileName:fileName forObject:program key:@"image"];
		}
	}
	
	
	return;
}



- (void)download:(NSString *)urlString toFileName:(NSString *)filename forObject:(NSManagedObject *)object key:(NSString *)key
{
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
	AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	
	NSString *path = [DataHandler pathForFileName:filename];
	operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
	
	__block NSManagedObjectID *__objectID = object.objectID;
	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//		NSLog(@"Successfully downloaded file to %@", path);
		
		NSManagedObject *object = [[DataHandler sharedInstance].managedObjectContext objectWithID:__objectID];
		[object setValue:filename forKey:key];
		
		[[DataHandler sharedInstance] saveContext];
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"Error: %@", error);
	}];
	
	[operation start];
}







@end
