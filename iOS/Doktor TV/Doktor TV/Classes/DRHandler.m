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

#import "DMTestSettings.h"
#import "DRTestSettingsPlugin.h"

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
		
		sharedInstance.afHttpSessionManager = [AFHTTPSessionManager new];
		
		sharedInstance.useOwnServer = [[[DMTestSettings sharedInstance] objectForKey:@"kUseOwnServer" withPluginIdentifier:[DRTestSettingsPlugin new].uniqueID] boolValue];
//		[sharedInstance queryPrograms];
		[sharedInstance queryPrograms9outof10];
    });
    return sharedInstance;
}



- (void)refreshMainData:(RefreshCompletionHandler)refreshCompletionHandler
{
	// TODO: Implement refresh of main data (all programs)
	refreshCompletionHandler(YES);
	
	[[DataHandler sharedInstance] saveContext];
}



- (void)queryPrograms
{
	NSString *query =  @"http://www.dr.dk/mu/view/bundles-with-public-asset?BundleType=Series&ChannelType=TV&DrChannel=True";
	query = [self addSort:@"Title" urlString:query];
	
//	NSUInteger batchSize = 20;
//	NSUInteger totalSize = 1000;
//	for (int i = 0; i<totalSize/batchSize; i++)
//	{
//		NSString *batchQuery = [self addLimit:batchSize urlString:query];
//		batchQuery = [self addLimit:i*batchSize urlString:batchQuery];
//		
//		DLog(@"Request %@",batchQuery);
//		[self.afHttpSessionManager GET:batchQuery parameters:nil success:^(NSURLSessionDataTask *task, id responseObject)
//		 {
//			 DLog(@"Received %@",query);
//			 [self validateProgramsData:responseObject];
//		 } failure:^(NSURLSessionDataTask *task, NSError *error) {
//			 DLog(@"ERROR: %@",error);
//		 }];
//	}

	query = [self addLimit:100 urlString:query];
	
	DLog(@"Request %@",query);
	[self.afHttpSessionManager GET:query parameters:nil success:^(NSURLSessionDataTask *task, id responseObject)
	 {
		 DLog(@"Received %@",query);
		 [self validateProgramsData:responseObject];
	 } failure:^(NSURLSessionDataTask *task, NSError *error) {
		 DLog(@"ERROR: %@",error);
	 }];
	
//	NSArray *titles = @[@"Broen II",@"Absurdistan",@"Rejseholdet",@"Hammerslag",@"Bonderøven",@"På skinner",@"Price*",@"Sporløs",@"Kontant"];
//	for (NSString *title in titles)
//	{
//		NSString *query1 = [self addTitle:title urlString:query];
//		
//		DLog(@"Reqest %@",query1);
//		[self.afHttpSessionManager GET:query1 parameters:nil success:^(NSURLSessionDataTask *task, id responseObject)
//		 {
//			 DLog(@"Received %@",query1);
//			 [self validateProgramsData:responseObject];
//		 } failure:^(NSURLSessionDataTask *task, NSError *error) {
//			 DLog(@"ERROR: %@",error);
//		 }];
//	}
}


- (void)queryPrograms9outof10
{
	if (self.useOwnServer)
	{
		NSString *query = @"http://apps.simonpaarlberg.com/doktor_tv/test1.json";
		[self.afHttpSessionManager GET:query parameters:nil success:^(NSURLSessionDataTask *task, id responseObject)
		 {
			 DLog(@"Received %@",query);
			 [self validateProgramsData:responseObject];
		 } failure:^(NSURLSessionDataTask *task, NSError *error) {
			 DLog(@"ERROR: %@",error);
		 }];
		return;
	}
	
	NSArray *titles = @[@"Abba",@"Rejseholdet",@"Hammerslag",@"Bonderøven",@"På skinner",@"Price*",@"Sporløs",@"Kontant"];
	[self queryProgramsWithTitles:titles];
}
- (void)queryPrograms1outof10
{
	if (self.useOwnServer)
	{
		NSString *query = @"http://apps.simonpaarlberg.com/doktor_tv/test2.json";
		[self.afHttpSessionManager GET:query parameters:nil success:^(NSURLSessionDataTask *task, id responseObject)
		 {
			 DLog(@"Received %@",query);
			 [self validateProgramsData:responseObject];
		 } failure:^(NSURLSessionDataTask *task, NSError *error) {
			 DLog(@"ERROR: %@",error);
		 }];
		return;
	}
	
	NSArray *titles = @[@"Absurdistan",@"Arvingerne"];
	[self queryProgramsWithTitles:titles];
}
- (void)queryProgramsWithTitles:(NSArray *)titles
{
	NSString *query =  @"http://www.dr.dk/mu/view/bundles-with-public-asset?BundleType=Series&ChannelType=TV&DrChannel=True";
	
	for (NSString *title in titles)
	{
		NSString *query1 = [self addTitle:title urlString:query];
		
		DLog(@"Reqest %@",query1);
		[self.afHttpSessionManager GET:query1 parameters:nil success:^(NSURLSessionDataTask *task, id responseObject)
		 {
			 DLog(@"Received %@",query1);
			 [self validateProgramsData:responseObject];
		 } failure:^(NSURLSessionDataTask *task, NSError *error) {
			 DLog(@"ERROR: %@",error);
		 }];
	}
}


- (NSString *)addLimit:(NSUInteger)limit urlString:(NSString *)urlString
{
	return [urlString stringByAppendingFormat:@"&limit=$eq(%@)",@(limit).stringValue];
}
- (NSString *)addOffset:(NSUInteger)offset urlString:(NSString *)urlString
{
	return [urlString stringByAppendingFormat:@"&offset=$eq(%@)",@(offset).stringValue];
}
- (NSString *)addTitle:(NSString *)title urlString:(NSString *)urlString
{
	NSString *_urlString = [urlString stringByAppendingFormat:@"&Title=$like(\"%@\")",title];
	NSString *escapedUrlString =[_urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	return escapedUrlString;
}

- (NSString *)addSort:(NSString *)key urlString:(NSString *)urlString
{
	NSString *_urlString = [urlString stringByAppendingFormat:@"&Title=$orderby(\"%@\")",key];
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

#define kOWNUri @"ImageUri"

- (void)validateProgramsData:(NSDictionary *)programsDictionary
{
	if (self.useOwnServer)
	{
		DLog(@"%@",programsDictionary);
		
		NSArray *localPrograms = [[DataHandler sharedInstance] programs];
		
		for (NSDictionary *dict in programsDictionary)
		{
			NSString *drID = dict[kDRUrn];
			
			NSArray *existingLocalPrograms = [localPrograms filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"drID = %@",drID]];
			
			Program *program;
			if (existingLocalPrograms.count)
			{
				// TODO: Update?
				program = (Program *)existingLocalPrograms.firstObject;
				
				DLog(@"Program already exists %@",program.title);
			}
			else
			{
				// Create new program
				program = [[DataHandler sharedInstance] newProgram];
				program.drID = drID;
				program.title = dict[kDRTitle];
				program.slug = dict[kDRSlug];
				
				NSString *imageUrlString = dict[kOWNUri];
				// Set max size
				imageUrlString = [imageUrlString stringByAppendingString:@"?width=200&height=200"];
				if (![imageUrlString isEqualToString:program.imageUrl])
				{
					DLog(@"New image url %@ for program %@",imageUrlString,program.title);
					program.imageUrl = imageUrlString;
					NSString *fileName = imageUrlString.lastPathComponent;
					fileName = [fileName stringByAppendingPathExtension:@"jpg"];
					program.image = fileName;
				}
				else
					DLog(@"Non-changed image url %@ for program %@",imageUrlString,program.title);
				
				DLog(@"New program %@",program.title);
			}
			
			
			
		}
		[[DataHandler sharedInstance] saveContext];
		
		return;
	}
	
	
	NSArray *data = programsDictionary[kDRData];
	
	NSArray *localPrograms = [[DataHandler sharedInstance] programs];
	
	for (NSDictionary *dict in data)
	{
		NSString *drID = dict[kDRUrn];
		
		NSArray *existingLocalPrograms = [localPrograms filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"drID = %@",drID]];
		
		NSDictionary *programCardDict = dict[kDRProgramCard];
		NSArray *assets = programCardDict[kDRAssets];
		
		Program *program;
		if (existingLocalPrograms.count)
		{
			// TODO: Update?
			program = (Program *)existingLocalPrograms.firstObject;
			
			DLog(@"Program already exists %@",program.title);
		}
		else
		{
			// Create new program
			program = [[DataHandler sharedInstance] newProgram];
			program.drID = drID;
			program.title = dict[kDRTitle];
			program.slug = dict[kDRSlug];
			
			DLog(@"New program %@",program.title);
		}
		
		
		if (assets.count) {
			NSArray *imageAsset = [assets filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K = %@",kDRKind,@"Image"]];
			if (imageAsset.count)
			{
				DLog(@"Image asset exists for program %@",program.title);
				
				NSDictionary *imageDict = imageAsset.firstObject;
				NSString *imageUrlString = imageDict[kDRUri];
				// Set max size
				imageUrlString = [imageUrlString stringByAppendingString:@"?width=200&height=200"];
				if (![imageUrlString isEqualToString:program.imageUrl])
				{
					DLog(@"New image url %@ for program %@",imageUrlString,program.title);
					program.imageUrl = imageUrlString;
					NSString *fileName = imageUrlString.lastPathComponent;
					fileName = [fileName stringByAppendingPathExtension:@"jpg"];
					program.image = fileName;
				}
				else
					DLog(@"Non-changed image url %@ for program %@",imageUrlString,program.title);
			}
		}
	}
	[[DataHandler sharedInstance] saveContext];
	
	return;
}


- (void)validateImageForProgram:(Program *)program
{
	NSString *imageUrlString = program.imageUrl;
	if (imageUrlString)
	{
		NSString *fileName = imageUrlString;
		
		BOOL noImageFileExists = ![UIImage imageWithContentsOfFile:[DataHandler pathForFile:fileName persistent:NO]];
		if (noImageFileExists)
		{
			DLog(@"Image not available (local) for program %@",program.title);
			
			imageUrlString = [imageUrlString stringByAppendingString:@"?width=200&height=200"];
			[self download:imageUrlString toFileName:fileName forObject:program key:@"image" persistent:NO block:0];
		}
		else
			DLog(@"Image exists (local) for program %@",program.title);
	}
}




- (void)download:(NSString *)urlString toFileName:(NSString *)filename forObject:(NSManagedObject *)object key:(NSString *)key persistent:(BOOL)persistent block:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progressBlock
{
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
	AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	
	if (progressBlock) {
		[operation setDownloadProgressBlock:progressBlock];
	}
	
	NSString *path = [DataHandler pathForFile:filename persistent:persistent];
	operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
	
	DLog(@"Begins download of %@ to %@",urlString,filename);
	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
	{
		DLog(@"Successfully downloaded file to %@", path);
		[object setValue:filename forKey:key];
		[[DataHandler sharedInstance] saveContext];
	}
									 failure:^(AFHTTPRequestOperation *operation, NSError *error)
	{
		DLog(@"Error: %@", error);
	}];
	
	[operation start];
}




- (void)validateEpisodesForProgram:(Program *)program
{
	NSString *query = [NSString stringWithFormat:@"http://www.dr.dk/mu/programcard?Relations.Slug=%@",program.slug];
	query = [self addLimit:100 urlString:query];

	DLog(@"Begin request for episode for program %@ with slug %@",program.title,program.slug);
	[self.afHttpSessionManager GET:query parameters:nil success:^(NSURLSessionDataTask *task, id responseObject)
	 {
		 DLog(@"Received for episode for program %@",program.title);
		 [self validateEpisodeData:responseObject forProgram:program];
	 }
						   failure:^(NSURLSessionDataTask *task, NSError *error)
	{
		 DLog(@"ERROR: %@",error);
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
	
	DLog(@"Episodes count: %lu for program %@",(unsigned long)data.count,program.title);
	
	int i = 0;
	for (NSDictionary *episodeData in data)
	{
		DLog(@"%d",i);
		
		NSString *drID = episodeData[kDRUrn];
		NSArray *existingLocalEpisodes = [season.episodes.array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"drID = %@",drID]];
		
		Episode *episode;
		if (existingLocalEpisodes.count)
		{
			// TODO: Update?
			episode = (Episode *)existingLocalEpisodes.firstObject;
			DLog(@"Episode already exists for episode %@ in program %@",episode.title,((Program *)episode.season.program).title);
		}
		else
		{
			episode = [[DataHandler sharedInstance] newEpisode];
			episode.season = season;
			episode.number = @(++i);
			episode.drID = drID;
			
			episode.slug = episodeData[kDRSlug];
			episode.title = episodeData[kDRTitle];
			episode.subtitle = episodeData[kDRSubtitle];
			episode.desc = episodeData[kDRDescription];
			
			DLog(@"New episode %@ in program %@",program.title,((Program *)episode.season.program).title);
		}
		
		NSArray *assets = episodeData[kDRAssets];
		if (assets.count) {
			NSArray *imageAsset = [assets filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K = %@",kDRKind,@"Image"]];
			
			if (imageAsset.count) {
				NSDictionary *imageDict = imageAsset.firstObject;
				NSString *imageUrlString = imageDict[kDRUri];
				// Set max size
				imageUrlString = [imageUrlString stringByAppendingString:@"?width=200&height=200"];
				if (![imageUrlString isEqualToString:episode.imageUrl])
				{
					episode.imageUrl = imageUrlString;
					NSString *fileName = imageUrlString.lastPathComponent;
					fileName = [fileName stringByAppendingPathExtension:@"jpg"];
					episode.image = fileName;
					DLog(@"Image link (remote) updated for episode %@ in program %@",episode.title,((Program *)episode.season.program).title);
				}
				else
					DLog(@"Image link (remote) not updated for episode %@ in program %@",episode.title,((Program *)episode.season.program).title);
			}
			else
				DLog(@"Image link (remote) not available for episode %@ in program %@",episode.title,((Program *)episode.season.program).title);
			
			
			NSArray *videoAsset = [assets filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K = %@",kDRKind,@"VideoResource"]];
			if (videoAsset.count) // && !episode.uri)
			{
				DLog(@"Video link (remote) available for episode %@ in program %@",episode.title,((Program *)episode.season.program).title);
				
				NSDictionary *videoDict = videoAsset.firstObject;
				
				episode.duration = @([videoDict[kDRDurationInMilliseconds] integerValue]);
				episode.uri = videoDict[kDRUri];
				episode.dkOnly = @([videoDict[kDRRestrictedToDenmark] boolValue]);
				
				NSString *fileName = [NSString stringWithFormat:@"EpisodeVideo__%@__%@.mp4",program.drID,episode.drID];
				episode.video = fileName;
			}
			else
				DLog(@"Video link (remote) not available for episode %@ in program %@",episode.title,((Program *)episode.season.program).title);
		}
		else
			DLog(@"No assets available for episode %@ in program %@",episode.title,((Program *)episode.season.program).title);
	}
	[[DataHandler sharedInstance] saveContext];
}



#define kDRLinks @"Links"
#define kDRTarget @"Target"
#define kDRBitrate @"Bitrate"
- (void)getVideoLinkForEpisode:(Episode *)episode completion:(void (^)(NSString *))completion
{
	NSString *query = episode.uri;
	DLog(@"\nURI: \n %@ \n\n",query);
	DLog(@"runVideo w/ uri %@ for episode %@ in program %@",query,episode.title,((Program *)episode.season.program).title);
	[self.afHttpSessionManager GET:query parameters:nil success:^(NSURLSessionDataTask *task, id responseObject)
	 {
		 NSDictionary *dict = responseObject;
		 NSArray *links = dict[kDRLinks];
		 
		 NSString *urlString;
		 for (NSDictionary *link in links)
		 {
			 if ([link[kDRTarget] isEqualToString:@"Streaming"] && [link[kDRBitrate] integerValue] < 1200)
			 {
				 urlString = link[kDRUri];
				 break;
			 }
		 }
		 if (urlString)
		 {
			 urlString = [urlString stringByReplacingOccurrencesOfString:@"rtmp://vod.dr.dk/cms/mp4:CMS" withString:@"http://vodfiles.dr.dk/CMS"];
			 DLog(@"runVideo found video uri %@ for episode %@ in program %@",urlString,episode.title,((Program *)episode.season.program).title);
			 completion(urlString);
		 }
	 } failure:^(NSURLSessionDataTask *task, NSError *error) {
		 DLog(@"ERROR: %@",error);
	 }];
}



@end
