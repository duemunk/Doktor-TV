//
//  UIViewController+Containment.m
//  Doktor TV
//
//  Created by Tobias DM on 16/11/13.
//  Copyright (c) 2013 developmunk. All rights reserved.
//

#import "UIViewController+Containment.h"

@implementation UIViewController (Containment)

- (void)addViewController:(UIViewController *)viewController
{
	[self addChildViewController:viewController];
	[self.view addSubview:viewController.view];
	[viewController didMoveToParentViewController:self];
}

- (void)removeViewController:(UIViewController *)viewController
{
	[viewController willMoveToParentViewController:nil];
	[viewController.view removeFromSuperview];
	[viewController removeFromParentViewController];
}

@end
