//
//  ZoomCollectionViewFlowLayout.m
//  Doktor TV
//
//  Created by Tobias DM on 17/11/13.
//  Copyright (c) 2013 developmunk. All rights reserved.
//

#import "ZoomCollectionViewFlowLayout.h"

@implementation ZoomCollectionViewFlowLayout

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
	return YES;
}

@end
