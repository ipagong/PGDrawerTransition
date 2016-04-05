//
//  PGDrawerTransition.m
//  PGDrawerTransition
//
//  Created by suwan on 2016. 3. 23..
//  Copyright © 2016년 suwan. All rights reserved.
//

#import "PGDrawerTransition.h"

@interface PGDrawerTransition () <UIGestureRecognizerDelegate>

@property (nonatomic, weak) UIViewController *targetViewController;
@property (nonatomic, weak) UIViewController *drawerViewController;

@property (nonatomic, weak) UIViewController *currentViewController;

@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *mainViewGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *drawerViewGesture;
@property (nonatomic, strong) UIButton *dismissButton;

@property (nonatomic, readonly) BOOL isPresentedDrawer;

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
    CGRect sourceRect = [transitionContext initialFrameForViewController:fromVC];
    UIView *container = [transitionContext containerView];
    
    if(self.isPresentedDrawer == NO){
        
        [container addSubview:toVC.view];
        
        sourceRect.size.width = (self.drawerWidth == NSNotFound ? sourceRect.size.width * 0.8 : self.drawerWidth);
        
        container.frame = sourceRect;
        
        CGRect toVCRect = sourceRect;
        toVCRect.origin.x = -toVCRect.size.width;
        toVCRect.origin.y = 0;
        toVC.view.frame = toVCRect;
        
        [self addDismissView];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                         animations:^{
                             [self.dismissButton setAlpha:self.dismissViewAlpha];
                             CGRect toVCRect = toVC.view.frame;
                             toVCRect.origin.x = 0;
                             toVC.view.frame = toVCRect;
                             
                         } completion:^(BOOL finished) {
                             
                             BOOL isCanceled = [transitionContext transitionWasCancelled];
                             
                             toVC.modalPresentationStyle = UIModalPresentationCustom;
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
    
    else{
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                         animations:^{
                             
                             CGRect fromVCRect = fromVC.view.frame;
                             fromVCRect.origin.x = -fromVCRect.size.width;
                             fromVC.view.frame = fromVCRect;
                             [container bringSubviewToFront:toVC.view];
                             [self.dismissButton setAlpha:0];
                             
                         } completion:^(BOOL finished) {
                             
                             BOOL isCanceled = [transitionContext transitionWasCancelled];
                             toVC.modalPresentationStyle = UIModalPresentationCustom;

                             if (isCanceled == YES) {
                                 self.currentViewController = self.drawerViewController;
                                 [transitionContext completeTransition:NO];
                                 [self addDismissView];
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

}

- (void)addDismissView
{
    if (self.hasDismissView == NO) return;
    
    if (self.targetViewController == nil) return;
    
    if (self.dismissButton) return;

    self.dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.dismissButton setBackgroundColor:[UIColor blackColor]];
    [self.dismissButton setAlpha:0];
    [self.dismissButton addTarget:self action:@selector(onClickDismissView:) forControlEvents:UIControlEventTouchUpInside];
    [self.dismissButton setFrame:CGRectMake(0, 0,
                                            [self.targetViewController.view window].frame.size.width,
                                            [self.targetViewController.view window].frame.size.height)];
    
    if (self.targetViewController.navigationController) {
        [self.targetViewController.navigationController.view addSubview:self.dismissButton];
    } else {
        [self.targetViewController.view addSubview:self.dismissButton];
    }
}

- (void)removeDismissView {
    if (self.dismissButton) {
        [self.dismissButton removeFromSuperview];
        self.dismissButton = nil;
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


#pragma mark - private methods

- (void)presentDrawer
{
    if (self.targetViewController && self.drawerViewController) {
        self.drawerViewController.modalPresentationStyle = UIModalPresentationCustom;
        self.drawerViewController.transitioningDelegate  = self;
        
        [self.targetViewController presentViewController:self.drawerViewController animated:YES completion:nil];
    }
}

- (void)dismissDrawer
{
    if (self.targetViewController && self.drawerViewController) {
        
        [self.drawerViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)presentDrawerViewController
{
    if (self.targetViewController && self.drawerViewController) {
        self.drawerViewController.modalPresentationStyle = UIModalPresentationCustom;
        self.drawerViewController.transitioningDelegate  = self;
        
        [self.targetViewController presentViewController:self.drawerViewController animated:YES completion:nil];
        [self finishInteractiveTransition];
    }
}

- (void)dismissDrawerViewController
{
    if (self.targetViewController && self.drawerViewController) {
        
        [self.drawerViewController dismissViewControllerAnimated:YES completion:nil];
        [self finishInteractiveTransition];
    }
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

@end
