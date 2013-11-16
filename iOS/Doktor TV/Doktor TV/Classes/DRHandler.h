//
//  DRHandler.h
//  Doktor TV
//
//  Created by Tobias DM on 16/11/13.
//  Copyright (c) 2013 developmunk. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AFNetworking.h"

@interface DRHandler : NSObject

@property (nonatomic, strong) AFHTTPSessionManager *afHttpSessionManager;

+ (DRHandler *)sharedInstance;

@end
