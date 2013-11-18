//
//  Episode.h
//  Doktor TV
//
//  Created by Tobias DM on 18/11/13.
//  Copyright (c) 2013 developmunk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Season;

@interface Episode : NSManagedObject

@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSNumber * dkOnly;
@property (nonatomic, retain) NSString * drID;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) NSString * slug;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * uri;
@property (nonatomic, retain) NSString * video;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) Season *season;

@end
