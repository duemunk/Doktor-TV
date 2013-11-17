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
	NSString *query =  @"http://www.dr.dk/mu/view/bundles-with-public-asset?BundleType=Series&ChannelType=TV";
	query = [self addLimit:10 urlString:query];
	query = [self addTitle:@"Broen II" urlString:query];
//	query = [self addTitle:@"Absurdistan" urlString:query];
	
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
- (NSString *)addTitle:(NSString *)title urlString:(NSString *)urlString
{
	NSString *_urlString = [urlString stringByAppendingFormat:@"&Title=$like(\"%@\")",title];
	NSString *escapedUrlString =[_urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	return escapedUrlString;
}



#define kDRResultsGeneratedDate @"ResultsGeneratedDate"
#define kDRData @"Data"
#define kDRResultProcessingTime @"ResultProcessingTime"

#define kDRUrn @"Urn"
#define kDRSeriesIdentifier @"SeriesIdentifier"
#define kDRTitle @"Title"
#define kDRSlug @"Slug"
#define kDRAssets @"Assets"
#define kDRProgramCard @"ProgramCard"

#define kDRKind @"Kind"
#define kDRUri @"Uri"

- (void)validateProgramsData:(NSDictionary *)programsDictionary
{
//	NSLog(@"Series: %@",programsDictionary);
	
	NSArray *data = programsDictionary[kDRData];
	
	NSArray *localPrograms = [[DataHandler sharedInstance] programs];
	
	for (NSDictionary *dict in data)
	{
		NSString *drID = dict[kDRUrn];
		
		NSArray *existingLocalPrograms = [localPrograms filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"drID = %@",drID]];
		
		
		NSDictionary *programCardDict = dict[kDRProgramCard];
		NSArray *assets = programCardDict[kDRAssets];
		
		// Check if program isn't radio-TV
//		NSString *site = programCardDict[@"Site"];
//		if (![site isEqualToString:@"radio-tv"])
//		{
			Program *program;
			if (existingLocalPrograms.count)
			{
				// TODO: Update?
				program = (Program *)existingLocalPrograms.firstObject;
			}
			else
			{
				
				
				
				// Create new program
				program = [[DataHandler sharedInstance] newProgram];
				program.drID = drID;
				program.title = dict[kDRTitle];
				program.slug = dict[kDRSlug];
			}
			
			
			if (assets.count) {
				NSArray *imageAsset = [assets filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K = %@",kDRKind,@"Image"]];
				if (imageAsset.count && !program.image)
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
			
			//			[self validateEpisodesForProgram:program];
			
			[[DataHandler sharedInstance] saveContext];
//		}
	}
	return;
}





- (void)download:(NSString *)urlString toFileName:(NSString *)filename forObject:(NSManagedObject *)object key:(NSString *)key
{
	[self download:urlString toFileName:filename forObject:object key:key block:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
		NSLog(@"Progess: %f", (float)totalBytesRead / (float)totalBytesExpectedToRead);
	}];
}

- (void)download:(NSString *)urlString toFileName:(NSString *)filename forObject:(NSManagedObject *)object key:(NSString *)key block:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progressBlock
{
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
	AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	
	[operation setDownloadProgressBlock:progressBlock];
	
	NSString *path = [DataHandler pathForFileName:filename];
	operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
	
	__block NSManagedObjectID *__objectID = object.objectID;
	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSLog(@"Successfully downloaded file to %@", path);
		
		NSManagedObject *object = [[DataHandler sharedInstance].managedObjectContext objectWithID:__objectID];
		[object setValue:filename forKey:key];
		
		[[DataHandler sharedInstance] saveContext];
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"Error: %@", error);
	}];
	
	[operation start];
}




- (void)validateEpisodesForProgram:(Program *)program
{
	NSString *query = [NSString stringWithFormat:@"http://www.dr.dk/mu/programcard?Relations.Slug=%@",program.slug];
	query = [self addLimit:100 urlString:query];
	NSLog(@"\n\n %@ \n\n",query);
	__block NSManagedObjectID *__objectID = program.objectID;
	[self.afHttpSessionManager GET:query parameters:nil success:^(NSURLSessionDataTask *task, id responseObject)
	 {
		 Program *program = (Program *)[[DataHandler sharedInstance].managedObjectContext objectWithID:__objectID];
		 [self validateEpisodeData:responseObject forProgram:program];
		 
	 } failure:^(NSURLSessionDataTask *task, NSError *error) {
		 NSLog(@"ERROR: %@",error);
	 }];
}

#define kDRSubtitle @"Subtitle"
#define kDRDescription @"Description"
#define kDRDurationInMilliseconds @"DurationInMilliseconds"
#define kDRRestrictedToDenmark @"RestrictedToDenmark"

- (void)validateEpisodeData:(NSDictionary *)episodesDictionary forProgram:(Program *)program
{
	NSArray *data = episodesDictionary[kDRData];
	
	Season *season = program.seasons.firstObject;
	if (!season) {
		season = [[DataHandler sharedInstance] newSeason];
		season.program = program;
	}
	
	int i = 0;
	for (NSDictionary *episodeData in data)
	{
		NSString *drID = episodeData[kDRUrn];
		NSArray *existingLocalEpisodes = [season.episodes.array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"drID = %@",drID]];
		
		Episode *episode;
		if (existingLocalEpisodes.count)
		{
			// TODO: Update?
			episode = (Episode *)existingLocalEpisodes.firstObject;
		}
		else
		{
			Episode *episode = [[DataHandler sharedInstance] newEpisode];
			episode.season = season;
			episode.number = @(++i);
			episode.drID = drID;
		}
		
		episode.slug = episodeData[kDRSlug];
		episode.title = episodeData[kDRTitle];
		episode.subtitle = episodeData[kDRSubtitle];
		episode.desc = episodeData[kDRDescription];
		
		NSArray *assets = episodeData[kDRAssets];
		
		if (assets.count) {
			NSArray *imageAsset = [assets filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K = %@",kDRKind,@"Image"]];
			
			NSDictionary *imageDict = imageAsset.firstObject;
			NSString *imageUrlString = imageDict[kDRUri];
			imageUrlString = [imageUrlString stringByAppendingString:@"?width=320&height=320"];
			NSString *fileName = [NSString stringWithFormat:@"EpisodeImage__%@__%@.jpg",program.drID,episode.drID];
			
			BOOL noImageFileExists = ![UIImage imageWithContentsOfFile:[DataHandler pathForFileName:fileName]];
			BOOL noImageLink = !episode.image;
			if (imageAsset.count && (noImageFileExists || noImageLink))
			{
				[self download:imageUrlString toFileName:fileName forObject:episode key:@"image"];
			}
			
			NSArray *videoAsset = [assets filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K = %@",kDRKind,@"VideoResource"]];
			if (videoAsset.count)
			{
				NSDictionary *videoDict = videoAsset.firstObject;
				
				episode.duration = @([videoDict[kDRDurationInMilliseconds] integerValue]);
				episode.uri = videoDict[kDRUri];
				episode.dkOnly = @([videoDict[kDRRestrictedToDenmark] boolValue]);
			}
		}
		[[DataHandler sharedInstance] saveContext];
	}
}

#define kDRLinks @"Links"
#define kDRTarget @"Target"
#define kDRBitrate @"Bitrate"
- (void)runVideo:(void (^)(NSString *))completion forEpisode:(Episode *)episode
{
	NSString *uri = episode.uri;
	
	NSString *query = uri;
	NSLog(@"\nURI: \n %@ \n\n",query);
	[self.afHttpSessionManager GET:query parameters:nil success:^(NSURLSessionDataTask *task, id responseObject)
	 {
		 NSDictionary *dict = responseObject;
		 NSArray *links = dict[kDRLinks];
		 
		 NSString *urlString;
		 for (NSDictionary *link in links)
		 {
			 if ([link[kDRTarget] isEqualToString:@"Streaming"] && [link[kDRBitrate] integerValue] < 200)
			 {
				 urlString = link[kDRUri];
				 break;
			 }
		 }
		 if (urlString) {
			 urlString = [urlString stringByReplacingOccurrencesOfString:@"rtmp://vod.dr.dk/cms/mp4:CMS" withString:@"http://vodfiles.dr.dk/CMS"];
			 completion(urlString);
		 }

	 } failure:^(NSURLSessionDataTask *task, NSError *error) {
		 NSLog(@"ERROR: %@",error);
	 }];
}

- (void)downloadVideoForEpisode:(Episode *)episode block:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progressBlock
{
	__block NSManagedObjectID *__objectID = episode.objectID;
	[self runVideo:^(NSString *urlString) {
		
		// Download
		Episode *episode = (Episode *)[[DataHandler sharedInstance].managedObjectContext objectWithID:__objectID];
		Program *program = (Program *)episode.season.program;
		NSString *filename = [NSString stringWithFormat:@"EpisodeVideo__%@__%@.mp4",program.drID,episode.drID];
		[self download:urlString toFileName:filename forObject:episode key:@"video" block:progressBlock];
		
	} forEpisode:episode];
}




@end
