//
//  PGDrawerTransition.m
//  PGDrawerTransition
//
//  Created by suwan on 2016. 3. 23..
//  Copyright © 2016년 suwan. All rights reserved.
//

#import "PGDrawerTransition.h"

@interface PGDrawerTransition () <UIGestureRecognizerDelegate>

@property (nonatomic, weak) UIViewController *currentViewController;

@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *mainViewGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *drawerViewGesture;

@property (nonatomic, strong) UIView *dismissBG;
@property (nonatomic, strong) UIButton *dismissButton;

@property (nonatomic, strong) UIImageView *capturedFromView;

@property (nonatomic, readonly) BOOL isPresentedDrawer;

@property (nonatomic, assign) BOOL isAnimated;

@end

@implementation PGDrawerTransition

- (instancetype)initWithTargetViewController:(UIViewController *)targetViewController drawerViewController:(UIViewController *)drawerViewController
{
    self = [super init];
    if (self) {
        self.targetViewController  = targetViewController;
        self.drawerViewController  = drawerViewController;
        self.currentViewController = targetViewController;
        
        self.drawerWidth = NSNotFound;
        self.dismissViewAlpha = 0.6;
        self.hasDismissView = YES;
        
        self.enablePresent  = YES;
        self.enableDismiss  = YES;
        
        self.useCapturedFromView = NO;
        
        self.dismissDuration = .4;
        self.presentDuration = .6;
        
        [self setupGesture];
    }
    return self;
}

- (void)setupGesture
{
    self.mainViewGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(mainViewGestureHandler:)];
    self.mainViewGesture.edges = UIRectEdgeLeft;
    
    self.drawerViewGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(drawerViewGestureHandler:)];
    self.drawerViewGesture.delegate = self;
    
    [self.targetViewController.view addGestureRecognizer:self.mainViewGesture];
    
    [self.drawerViewController.view addGestureRecognizer:self.drawerViewGesture];
}

#pragma mark - UIViewControllerAnimatedTransitioning -

- (void)drawerViewGestureHandler:(UIScreenEdgePanGestureRecognizer*)recognizer
{
    if (self.isAnimated == YES) return;
    
    if ([self canDismiss] == NO) return;
    
    if (self.enableDismiss == NO) return;
    
    if (self.isPresentedDrawer == NO) return;
    
    static CGPoint gLocation;
    static CGFloat gContainerWidth;
    
    CGPoint location = [recognizer locationInView:[self.drawerViewController.view window]];
    CGPoint velocity = [recognizer velocityInView:[self.drawerViewController.view window]];
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            gContainerWidth = CGRectGetWidth(self.drawerViewController.view.bounds);
            gLocation = [recognizer locationInView:[self.drawerViewController.view window]];
            
            [self dismissDrawer];
        }
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            CGFloat distance = MAX(0, gLocation.x - location.x);
            CGFloat animationRatio = distance/gContainerWidth;
            [self updateInteractiveTransition:animationRatio];
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        {
            self.isAnimated = YES;
            
            if (velocity.x < 0) {
                [self finishInteractiveTransition];
                self.currentViewController = self.targetViewController;
            } else {
                [self cancelInteractiveTransition];
                self.currentViewController = self.drawerViewController;
            }
        }
            break;
            
        default:
            break;
    }
}


- (void)mainViewGestureHandler:(UIPanGestureRecognizer*)recognizer
{
    if (self.isAnimated == YES) return;
    
    if ([self canPresent] == NO) return;
    
    if (self.enablePresent == NO) return;
    
    if (self.isPresentedDrawer == YES) return;
    
    CGPoint location = [recognizer locationInView:[self.targetViewController.view window]];
    CGPoint velocity = [recognizer velocityInView:[self.targetViewController.view window]];
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            [self presentDrawer];
        }
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            CGFloat animationRatio = location.x / CGRectGetWidth([self.targetViewController.view window].bounds);
            [self updateInteractiveTransition:animationRatio];
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        {
            self.isAnimated = YES;
            
            if (velocity.x > 0) {
                [self finishInteractiveTransition];
                self.currentViewController = self.drawerViewController;
            } else {
                [self cancelInteractiveTransition];
                self.currentViewController = self.targetViewController;
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)onClickDismissView:(id)sender
{
    if (self.hasDismissView == NO) return;
    if (self.isPresentedDrawer == NO) return;
    
    [self dismissDrawerViewController];
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    if (self.isPresentedDrawer == YES) {
        return self.dismissDuration;
    } else {
        return self.presentDuration;
    }
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *container = [transitionContext containerView];
    CGRect fromVCRect = fromVC.view.frame;
    
    if(toVC == self.drawerViewController){
        
        [container addSubview:toVC.view];
        
        CGRect sourceRect = CGRectMake(0, 0, CGRectGetWidth(fromVC.view.window.frame), CGRectGetHeight(fromVC.view.window.frame));
        sourceRect.size.width = (self.drawerWidth == NSNotFound ? sourceRect.size.width * 0.8 : self.drawerWidth);
        
        container.frame = fromVC.view.frame;
        
        CGRect toVCRect = sourceRect;
        toVCRect.origin.x = -toVCRect.size.width;
        toVCRect.origin.y = 0;
        toVC.view.frame = toVCRect;
        
        [self addDismissViewWithTargetViewController:fromVC drawerViewController:toVC containerView:container];
        [self addCapturedViewWithTargetViewController:fromVC drawerViewController:toVC containerView:container];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                         animations:^{
                             [self.dismissBG setAlpha:self.dismissViewAlpha];
                             CGRect toVCRect = toVC.view.frame;
                             toVCRect.origin.x = 0;
                             toVC.view.frame = toVCRect;
                             
                         } completion:^(BOOL finished) {
                             
                             [self useCapturedViewInstedOfTargetViewController:fromVC];
                             
                             BOOL isCanceled = [transitionContext transitionWasCancelled];
                             
                             self.isAnimated = NO;
                             
                             toVC.modalPresentationStyle = [self drawerPresentationStyle];;
                             if (isCanceled == YES) {
                                 self.currentViewController = self.targetViewController;
                                 [transitionContext completeTransition:NO];
                                 [self removeDismissView];
                                 [self removeCapturedFromView];
                             } else {
                                 self.currentViewController = self.drawerViewController;
                                 [transitionContext completeTransition:YES];
                                 if (self.presentBlock) {
                                     self.presentBlock();
                                 }
                             }
                         }];
    }
    else
    {
        
        fromVC.view.frame = fromVCRect;
        [self.dismissBG setAlpha:self.dismissViewAlpha];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             
                             CGRect fromVCRect = fromVC.view.frame;
                             fromVCRect.origin.x = -fromVCRect.size.width;
                             fromVC.view.frame = fromVCRect;
                             [self.dismissBG setAlpha:0];
                             
                         } completion:^(BOOL finished) {
                             
                             [container bringSubviewToFront:toVC.view];
                             
                             BOOL isCanceled = [transitionContext transitionWasCancelled];
                             toVC.modalPresentationStyle = [self drawerPresentationStyle];
                             
                             self.isAnimated = NO;
                             
                             if (isCanceled == YES) {
                                 self.currentViewController = self.drawerViewController;
                                 [transitionContext completeTransition:NO];
                                 [self addDismissViewWithTargetViewController:toVC drawerViewController:fromVC containerView:container];
                             } else {
                                 self.currentViewController = self.targetViewController;
                                 [transitionContext completeTransition:YES];
                                 [self removeDismissView];
                                 [self removeCapturedFromView];
                                 if (self.dismissBlock) {
                                     self.dismissBlock();
                                 }
                             }
                         }];
    }
    
}

- (UIButton *)dismissButton
{
    if (_dismissButton == nil) {
        _dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_dismissButton setBackgroundColor:[UIColor clearColor]];
        [_dismissButton addTarget:self action:@selector(onClickDismissView:) forControlEvents:UIControlEventTouchUpInside];
        [_dismissButton setFrame:CGRectMake(0, 0,
                                            [self.targetViewController.view window].frame.size.width,
                                            [self.targetViewController.view window].frame.size.height)];
    }
    return _dismissButton;
}

- (UIView *)dismissBG
{
    if (_dismissBG == nil) {
        _dismissBG = [[UIView alloc] initWithFrame:CGRectZero];
        [_dismissBG setBackgroundColor:[UIColor blackColor]];
        [_dismissBG setAlpha:0];
    }
    return _dismissBG;
}


- (void)addDismissViewWithTargetViewController:(UIViewController *)targetViewController drawerViewController:(UIViewController *)drawerViewController containerView:(UIView *)containerView
{
    if (self.hasDismissView == NO) return;
    
    if (self.targetViewController == nil) return;
    
    if (self.dismissButton.superview) return;
    
    [self.dismissButton removeFromSuperview];
    [self.dismissBG     removeFromSuperview];
    
    [self.dismissButton setFrame:CGRectMake(0, 0,
                                            targetViewController.view.frame.size.width,
                                            targetViewController.view.frame.size.height)];
    [self.dismissBG setFrame:self.dismissButton.frame];
    
    [containerView addSubview:self.dismissBG];
    [containerView addSubview:self.dismissButton];
    
    [containerView bringSubviewToFront:drawerViewController.view];
}

- (void)removeDismissView
{
    if (self.dismissButton.superview) {
        [self.dismissButton removeFromSuperview];
        [self.dismissBG     removeFromSuperview];
    }
}

- (void)addCapturedViewWithTargetViewController:(UIViewController *)targetViewController drawerViewController:(UIViewController *)drawerViewController containerView:(UIView *)containerView
{
    if (self.useCapturedFromView == NO) return;
    if (self.capturedFromView) return;
    
    self.capturedFromView = [[UIImageView alloc] initWithImage:[self imageWithView:targetViewController.view]];
    [self.capturedFromView setFrame:CGRectMake(0, 0,
                                               targetViewController.view.frame.size.width,
                                               targetViewController.view.frame.size.height)];
    
    [containerView addSubview:self.capturedFromView];
    [containerView sendSubviewToBack:self.capturedFromView];
    [containerView bringSubviewToFront:drawerViewController.view];
    
    targetViewController.view.hidden = YES;
}

- (void)useCapturedViewInstedOfTargetViewController:(UIViewController *)targetViewController
{
    if (self.useCapturedFromView == YES) {
        targetViewController.view.hidden = NO;
        [targetViewController.view removeFromSuperview];
    }
}

- (void)removeCapturedFromView
{
    if (self.capturedFromView) {
        [self.capturedFromView removeFromSuperview];
        self.capturedFromView = nil;
    }
}

- (BOOL)isPresentedDrawer
{
    if (self.currentViewController == nil) {
        return NO;
    }
    
    if (self.currentViewController == self.targetViewController) {
        return NO;
    }
    
    return YES;
}

- (UIModalPresentationStyle)drawerPresentationStyle
{
    return UIModalPresentationCustom;
}

- (BOOL)canPresent
{
    if (self.drawerDelegate && [self.drawerDelegate respondsToSelector:@selector(canPresentWithDrawerTransition:)] == YES) {
        return [self.drawerDelegate canPresentWithDrawerTransition:self];
    }
    return YES;
}

- (BOOL)canDismiss
{
    if (self.drawerDelegate && [self.drawerDelegate respondsToSelector:@selector(canDismissWithDrawerTransition:)] == YES) {
        return [self.drawerDelegate canDismissWithDrawerTransition:self];
    }
    return YES;
}

#pragma mark - private methods

- (void)presentDrawer
{
    if ([self canPresent] == NO) return;
    
    if (self.enablePresent == NO) return;
    
    if (self.targetViewController == nil || self.drawerViewController == nil) return;
    
    if (self.percentComplete != 0) return;
    
    self.drawerViewController.modalPresentationStyle = [self drawerPresentationStyle];
    self.drawerViewController.transitioningDelegate  = self;
    
    [self.targetViewController presentViewController:self.drawerViewController animated:YES completion:nil];
}

- (void)dismissDrawer
{
    if ([self canDismiss] == NO) return;
    
    if (self.enableDismiss == NO) return;
    
    if (self.targetViewController == nil || self.drawerViewController == nil) return;
    
    if (self.percentComplete != 0) return;
    
    [self.drawerViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)presentDrawerViewController
{
    [self presentDrawerViewControllerWithAnimated:YES completion:nil];
}

- (void)dismissDrawerViewController
{
    [self dismissDrawerViewControllerWithAnimated:YES completion:nil];
}

- (void)presentDrawerViewControllerWithAnimated:(BOOL)animated completion:(void (^)(void))completion
{
    if ([self canPresent] == NO) return;
    
    if (self.isAnimated == YES) return;
    
    if (self.enablePresent == NO) return;
    
    if (self.isPresentedDrawer == YES) return;
    
    if (self.targetViewController == nil || self.drawerViewController == nil) return;
    
    if (self.percentComplete != 0) return;
    
    self.isAnimated = YES;
    
    self.drawerViewController.modalPresentationStyle = [self drawerPresentationStyle];
    self.drawerViewController.transitioningDelegate  = self;
    
    [self.targetViewController presentViewController:self.drawerViewController animated:YES completion:^{
        if (completion) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                completion();
            });
        }
    }];
    
    self.currentViewController = self.drawerViewController;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self finishInteractiveTransition];
    });
}

- (void)dismissDrawerViewControllerWithAnimated:(BOOL)animated completion:(void (^)(void))completion
{
    if ([self canDismiss] == NO) return;
    
    if (self.isAnimated == YES) return;
    
    if (self.enableDismiss == NO) return;
    
    if (self.isPresentedDrawer == NO) return;
    
    if (self.targetViewController == nil || self.drawerViewController == nil) return;
    
    if (self.percentComplete != 0) return;
    
    self.isAnimated = YES;
    
    [self.drawerViewController dismissViewControllerAnimated:YES completion:^{
        if (completion) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                completion();
            });
        }
    }];
    
    self.currentViewController = self.targetViewController;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self finishInteractiveTransition];
    });
}

#pragma mark - UIVieControllerTransitioningDelegate -

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                   presentingController:(UIViewController *)presenting
                                                                       sourceController:(UIViewController *)source
{
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return self;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator
{
    return self;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator
{
    return self;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer
{
    CGPoint velocity = [panGestureRecognizer velocityInView:self.drawerViewController.view];
    return fabs(velocity.x) > fabs(velocity.y);
}

#pragma mark - utils methods

- (UIImage *)imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, 0, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}


@end