//
//  ProgramCollectionCell.h
//  Doktor TV
//
//  Created by Tobias DM on 16/11/13.
//  Copyright (c) 2013 developmunk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Program.h"

#import "ZoomCollectionViewCell.h"

@interface ProgramCollectionViewCell : ZoomCollectionViewCell

@property (nonatomic, strong) Program *program;

@end
