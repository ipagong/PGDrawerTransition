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
@property (nonatomic, strong) UIButton *innerButton; //for accessibiilty.

@property (nonatomic, readonly) BOOL isPresentedDrawer;

@property (nonatomic, assign) BOOL isAnimated;
@property (nonatomic, assign) BOOL hasInteraction;

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
        
        self.dismissDuration = .3;
        self.presentDuration = .3;
        
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
            
            self.hasInteraction = YES;
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
            
            if (self.hasInteraction == YES) {
                if (velocity.x < 0) {
                    [self finishInteractiveTransition];
                    self.currentViewController = self.targetViewController;
                } else {
                    [self cancelInteractiveTransition];
                    self.currentViewController = self.drawerViewController;
                }
            } else {
                self.isAnimated = NO;
            }
            
            self.hasInteraction = NO;
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
            self.hasInteraction = YES;
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
            
            if (self.hasInteraction == YES) {
                if (velocity.x > 0) {
                    [self finishInteractiveTransition];
                    self.currentViewController = self.drawerViewController;
                } else {
                    [self cancelInteractiveTransition];
                    self.currentViewController = self.targetViewController;
                }
            } else {
                self.isAnimated = NO;
            }
            
            self.hasInteraction = NO;
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
    
    if(toVC == self.drawerViewController){
        [self presentAnimationWithFromViewController:fromVC toViewController:toVC container:container context:transitionContext];
    } else {
        [self dismissAnimationWithFromViewController:fromVC toViewController:toVC container:container context:transitionContext];
    }
    
}

- (void)presentAnimationWithFromViewController:(UIViewController *)fromVC
                              toViewController:(UIViewController *)toVC
                                     container:(UIView *)container
                                       context:(id<UIViewControllerContextTransitioning>)transitionContext
{
    [container addSubview:toVC.view];
    
    CGRect sourceRect = CGRectMake(0, 0, CGRectGetWidth(fromVC.view.window.frame), CGRectGetHeight(fromVC.view.window.frame));
    sourceRect.size.width = (self.drawerWidth == NSNotFound ? sourceRect.size.width * 0.8 : self.drawerWidth);
    
    container.frame = fromVC.view.frame;
    
    CGRect toVCRect = sourceRect;
    toVCRect.origin.x = -toVCRect.size.width;
    toVCRect.origin.y = 0;
    toVC.view.frame = toVCRect;
    
    [self addDismissViewWithTargetViewController:fromVC drawerViewController:toVC containerView:container];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                     animations:^{
                         [self.dismissBG setAlpha:self.dismissViewAlpha];
                         CGRect toVCRect = toVC.view.frame;
                         toVCRect.origin.x = 0;
                         toVC.view.frame = toVCRect;
                         
                     } completion:^(BOOL finished) {
                         
                         BOOL isCanceled = [transitionContext transitionWasCancelled];
                         
                         self.isAnimated = NO;
                         
                         toVC.modalPresentationStyle = [self drawerPresentationStyle];;
                         if (isCanceled == YES) {
                             self.currentViewController = self.targetViewController;
                             [transitionContext completeTransition:NO];
                             [self removeDismissView];
                         } else {
                             self.currentViewController = self.drawerViewController;
                             [transitionContext completeTransition:YES];
                             if (self.presentBlock) {
                                 self.presentBlock();
                             }
                         }
                     }];
}

- (void)dismissAnimationWithFromViewController:(UIViewController *)fromVC
                              toViewController:(UIViewController *)toVC
                                     container:(UIView *)container
                                       context:(id<UIViewControllerContextTransitioning>)transitionContext
{
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
                             if (self.dismissBlock) {
                                 self.dismissBlock();
                             }
                         }
                     }];
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

- (UIView *)innerButton
{
    if (_innerButton == nil) {
        _innerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_innerButton setBackgroundColor:[UIColor clearColor]];
        [_innerButton addTarget:self action:@selector(onClickDismissView:) forControlEvents:UIControlEventTouchUpInside];
        [_innerButton setFrame:CGRectMake(0, 0,
                                          [self.targetViewController.view window].frame.size.width,
                                          [self.targetViewController.view window].frame.size.height)];
    }
    return _innerButton;
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
    [self.innerButton setFrame:CGRectMake(CGRectGetWidth(drawerViewController.view.frame), 0,
                                          CGRectGetWidth(targetViewController.view.bounds) - CGRectGetWidth(drawerViewController.view.frame),
                                          CGRectGetHeight(targetViewController.view.bounds))];
    
    [containerView addSubview:self.dismissBG];
    [containerView addSubview:self.dismissButton];
    
    [targetViewController.view addSubview:self.innerButton];
    [containerView bringSubviewToFront:drawerViewController.view];
}

- (void)removeDismissView
{
    if (self.dismissButton.superview) {
        [self.dismissButton removeFromSuperview];
        [self.dismissBG     removeFromSuperview];
        [self.innerButton   removeFromSuperview];
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
    
    [self.targetViewController presentViewController:self.drawerViewController animated:animated completion:^{
        if (completion) {
            completion();
        }
    }];
    
    self.currentViewController = self.drawerViewController;
}

- (void)dismissDrawerViewControllerWithAnimated:(BOOL)animated completion:(void (^)(void))completion
{
    if ([self canDismiss] == NO) return;
    
    if (self.isAnimated == YES) return;
    
    if (self.enableDismiss == NO) return;
    
    if (self.isPresentedDrawer == NO) return;
    
    if (self.targetViewController == nil || self.drawerViewController == nil) return;
    
    if (self.percentComplete != 0) return;
    
    self.drawerViewController.modalPresentationStyle = [self drawerPresentationStyle];
    self.drawerViewController.transitioningDelegate  = self;
    
    self.isAnimated = YES;
    
    [self.drawerViewController dismissViewControllerAnimated:animated completion:^{
        if (completion) {
            completion();
        }
    }];
    
    self.currentViewController = self.targetViewController;
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
    if (self.hasInteraction == YES) return self;
    return nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator
{
    if (self.hasInteraction == YES) return self;
    return nil;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer
{
    CGPoint velocity = [panGestureRecognizer velocityInView:self.drawerViewController.view];
    return fabs(velocity.x) > fabs(velocity.y);
}

@end
