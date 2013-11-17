//
//  UIFont+CustomFont.m
//  3D Dermatomes
//
//  Created by Tobias DM on 23/10/13.
//  Copyright (c) 2013 developmunk. All rights reserved.
//

#import "UIFont+CustomFont.h"

NSString *const FontNameHeadline = @"Avenir-Heavy"; // GillSans-Bold, Futura-CondensedMedium, Avenir-Heavy;
NSString *const FontNameBody = @"Avenir-Roman"; // GillSans, Futura-Medium, Avenir-Roman;

@implementation UIFont (CustomFont)

+ (UIFont *)preferredCustomFontForTextStyle:(NSString *)textStyle
{
	// Get system default
	UIFont *systemSuggestedFont = [UIFont preferredFontForTextStyle:textStyle];
	CGFloat systemSuggestedFontSize = systemSuggestedFont.pointSize;
	
	
	NSString *fontName;
	if ([textStyle isEqualToString:UIFontTextStyleHeadline] ||
		[textStyle isEqualToString:UIFontTextStyleSubheadline])
	{
		fontName = FontNameHeadline;
	} else {
		fontName = FontNameBody;
	}

	UIFont *font = [UIFont fontWithName:fontName
								   size:systemSuggestedFontSize];
	
	return font;
}




@end
