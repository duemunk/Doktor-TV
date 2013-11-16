//
//  UIViewController+Containment.h
//  Doktor TV
//
//  Created by Tobias DM on 16/11/13.
//  Copyright (c) 2013 developmunk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Containment)

- (void)addViewController:(UIViewController *)viewController;
- (void)removeViewController:(UIViewController *)viewController;

@end
