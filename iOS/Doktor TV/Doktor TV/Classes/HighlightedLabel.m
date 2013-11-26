//
//  HighlightedLabel.m
//  Doktor TV
//
//  Created by Tobias DM on 18/11/13.
//  Copyright (c) 2013 developmunk. All rights reserved.
//

#import "HighlightedLabel.h"

@implementation HighlightedLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setText:(NSString *)text
{
	[super setText:text];
	
	[self updateHighlight];
}

- (void)setHighlightBackgroundColor:(UIColor *)highlightBackgroundColor
{
	if (highlightBackgroundColor != _highlightBackgroundColor)
	{
		_highlightBackgroundColor = highlightBackgroundColor;
		[self updateHighlight];
	}
}

- (void)updateHighlight
{
	if (self.attributedText.length && _highlightBackgroundColor)
	{
		NSMutableAttributedString *attrText = self.attributedText.mutableCopy;
		NSRange range = NSMakeRange(0, attrText.length);
		[attrText addAttribute:NSBackgroundColorAttributeName value:self.highlightBackgroundColor range:range];
		self.attributedText = attrText;
	}	
}

@end
