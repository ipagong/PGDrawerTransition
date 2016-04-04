//
//  PGDrawerTransition.h
//  PGDrawerTransition
//
//  Created by suwan on 2016. 3. 23..
//  Copyright © 2016년 suwan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^PGDrawerInteractionBlock)(void);

@interface PGDrawerTransition : UIPercentDrivenInteractiveTransition
<UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate>

@property (nonatomic, copy) PGDrawerInteractionBlock presentBlock;
@property (nonatomic, copy) PGDrawerInteractionBlock dismissBlock;

- (instancetype)initWithTargetViewController:(UIViewController *)targetViewController drawerViewController:(UIViewController *)drawerViewController;

- (void)presentDrawerViewController;
- (void)dismissDrawerViewController;

@property (nonatomic, assign) BOOL hasDismissView;
@property (nonatomic, assign) CGFloat dismissViewAlpha;
@property (nonatomic, assign) CGFloat drawerWidth;

@property (nonatomic, assign) NSTimeInterval presentDuration;
@property (nonatomic, assign) NSTimeInterval dismissDuration;

@end