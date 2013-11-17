//
//  ProgramCollectionViewController.h
//  Doktor TV
//
//  Created by Tobias DM on 16/11/13.
//  Copyright (c) 2013 developmunk. All rights reserved.
//

#import "ZoomCollectionViewController.h"
#import "Program.h"
#import	"Season.h"

@interface ProgramCollectionViewController : ZoomCollectionViewController

@property (nonatomic, strong) Program *program;

@end
