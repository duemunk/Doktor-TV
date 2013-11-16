//
//  ProgramCollectionCell.h
//  Doktor TV
//
//  Created by Tobias DM on 16/11/13.
//  Copyright (c) 2013 developmunk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Program.h"

#import "CollectionViewCell.h"

@interface ProgramCollectionViewCell : CollectionViewCell

@property (nonatomic, strong) Program *program;
@property (nonatomic, assign) BOOL showContent;

@end
