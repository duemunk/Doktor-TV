//
//  Button.m
//  Doktor TV
//
//  Created by Tobias DM on 17/11/13.
//  Copyright (c) 2013 developmunk. All rights reserved.
//

#import "Button.h"

@implementation Button

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.backgroundColor = [self.tintColor colorWithAlphaComponent:alphaOverlay];
		
		[self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[self setTitleColor:[UIColor colorWithWhite:1.0f alpha:0.5] forState:UIControlStateDisabled];
		
		self.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f);
		self.titleLabel.font = [UIFont preferredCustomFontForTextStyle:UIFontTextStyleSubheadline];
		
		self.layer.cornerRadius = 2.0f;
    }
    return self;
}

- (void)tintColorDidChange
{
	self.backgroundColor = [self.tintColor colorWithAlphaComponent:alphaOverlay];
}

- (void)setTitle:(NSString *)title
{
	if (title != _title) {
		_title = title;
		
		[self setTitle:_title forState:UIControlStateNormal];
		[self sizeToFit];
	}
}


- (CGSize)intrinsicContentSize
{
    CGSize s = [super intrinsicContentSize];
	
    return CGSizeMake(s.width + self.titleEdgeInsets.left + self.titleEdgeInsets.right,
                      s.height + self.titleEdgeInsets.top + self.titleEdgeInsets.bottom);
	
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
