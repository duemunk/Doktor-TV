//
//  Episode.h
//  Doktor TV
//
//  Created by Tobias DM on 16/11/13.
//  Copyright (c) 2013 developmunk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Season;

@interface Episode : NSManagedObject

@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) Season *season;

@end
