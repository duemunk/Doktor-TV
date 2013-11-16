//
//  ProgramCollectionCell.m
//  Doktor TV
//
//  Created by Tobias DM on 16/11/13.
//  Copyright (c) 2013 developmunk. All rights reserved.
//

#import "ProgramCollectionCell.h"

@implementation ProgramCollectionCell
{
	UILabel *titleLabel;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.backgroundColor = [UIColor iOS7blueGradientStartColor];
    }
    return self;
}


- (void)setTitle:(NSString *)title
{
	if (![title isEqualToString:_title]) {
		_title = title;
		
		if (!titleLabel) {
			titleLabel = [UILabel new];
			[self addSubview:titleLabel];
			[titleLabel keepCentered];
			titleLabel.textColor = [UIColor whiteColor];
		}
		titleLabel.text = _title;
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
