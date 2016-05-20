//
//  PGDrawerTransition.h
//  PGDrawerTransition
//
//  Created by suwan on 2016. 3. 23..
//  Copyright © 2016년 suwan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^PGDrawerInteractionBlock)(void);

@class PGDrawerTransition;

@protocol PGDrawerTransitionDelegate <NSObject>

@optional
- (BOOL)canPresentWithDrawerTransition:(PGDrawerTransition *)transition;
- (BOOL)canDismissWithDrawerTransition:(PGDrawerTransition *)transition;

@end

@interface PGDrawerTransition : UIPercentDrivenInteractiveTransition
<UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate>

@property (nonatomic, copy) PGDrawerInteractionBlock presentBlock;
@property (nonatomic, copy) PGDrawerInteractionBlock dismissBlock;

- (instancetype)initWithTargetViewController:(UIViewController *)targetViewController drawerViewController:(UIViewController *)drawerViewController;

- (void)presentDrawerViewController;
- (void)dismissDrawerViewController;
- (void)presentDrawerViewControllerWithAnimated:(BOOL)animated completion:(void (^)(void))completion;
- (void)dismissDrawerViewControllerWithAnimated:(BOOL)animated completion:(void (^)(void))completion;

@property (nonatomic, assign) BOOL enablePresent;
@property (nonatomic, assign) BOOL enableDismiss;

@property (nonatomic, assign) BOOL useCapturedFromView;

@property (nonatomic, assign) BOOL hasDismissView;
@property (nonatomic, assign) CGFloat dismissViewAlpha;
@property (nonatomic, assign) CGFloat drawerWidth;

@property (nonatomic, assign) NSTimeInterval presentDuration;
@property (nonatomic, assign) NSTimeInterval dismissDuration;

@property (nonatomic, weak) UIViewController *targetViewController;
@property (nonatomic, weak) UIViewController *drawerViewController;

@property (nonatomic, weak) id <PGDrawerTransitionDelegate> drawerDelegate;


@end
