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
		self.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
		
		[self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[self setTitleColor:[UIColor colorWithWhite:1.0f alpha:0.5] forState:UIControlStateDisabled];
		
		[self setTitleEdgeInsets:UIEdgeInsetsMake(40.0f, 20.0f, 40.0f, 20.0f)];
		self.titleLabel.font = [UIFont preferredCustomFontForTextStyle:UIFontTextStyleSubheadline];
    }
    return self;
}


- (void)setTitle:(NSString *)title
{
	if (title != _title) {
		_title = title;
		
		[self setTitle:_title forState:UIControlStateNormal];
		[self sizeToFit];
	}
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
