//
//  CollectionHeaderView.m
//  Doktor TV
//
//  Created by Tobias DM on 26/11/13.
//  Copyright (c) 2013 developmunk. All rights reserved.
//

#import "CollectionHeaderView.h"



@interface CollectionHeaderView ()

@property (nonatomic,strong) UILabel *titleLabel;

@end



@implementation CollectionHeaderView



- (void)setTitle:(NSString *)title
{
	if (title != _title)
	{
		_title = title;
		
		self.titleLabel.text = _title;
		[self.titleLabel sizeToFit];
	}
}

- (UILabel *)titleLabel
{
	if (!_titleLabel) {
		_titleLabel = [UILabel new];
		[self addSubview:_titleLabel];
		[_titleLabel keepCentered];
		_titleLabel.keepInsets.min = KeepRequired(0.0f);
		self.titleLabel.font = [[UIFont preferredCustomFontForTextStyle:UIFontTextStyleHeadline] fontWithSize:30.0f];
		self.titleLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:alphaOverlay];
	}
	return _titleLabel;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	if (_titleLabel) // Update max width for label. Autolayout doesn't do this.
		self.titleLabel.preferredMaxLayoutWidth = self.bounds.size.width;
}


@end
