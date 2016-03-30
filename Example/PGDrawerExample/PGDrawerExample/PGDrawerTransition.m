//
//  DrawerInteractiveTransition.m
//  PGDrawerExample
//
//  Created by suwan on 2016. 3. 23..
//  Copyright © 2016년 suwan. All rights reserved.
//

#import "PGDrawerTransition.h"

@interface PGDrawerTransition ()

@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *mainViewGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *drawerViewGesture;

@property (nonatomic, weak) UIViewController *mainViewController;
@property (nonatomic, weak) UIViewController *drawerViewController;
@property (nonatomic, weak) UIViewController *targetViewController;

@property (nonatomic, weak) UIViewController *currentViewController;


@end

@implementation PGDrawerTransition

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupData];
    }
    return self;
}

- (void)setupData
{
    self.mainViewGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(mainViewGestureHandler:)];
    self.mainViewGesture.edges = UIRectEdgeLeft;
    
    self.drawerViewGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(drawerViewGestureHandler:)];
    
    [self setupViewController];

}

- (void)setupViewController
{
    if (self.delegate == nil || [self.delegate respondsToSelector:@selector(viewControllerWithDrawerTransitionType:)] == NO) return;
    
    UIViewController *mainVc   = [self.delegate viewControllerWithDrawerTransitionType:PGDrawerTransitionTypeMain];
    UIViewController *drawerVc = [self.delegate viewControllerWithDrawerTransitionType:PGDrawerTransitionTypeDrawer];
    UIViewController *targetVc = [self.delegate viewControllerWithDrawerTransitionType:PGDrawerTransitionTypeTarget];
    
    if (mainVc && mainVc != self.mainViewController) {
        self.mainViewController = mainVc;
        [self.mainViewController.view addGestureRecognizer:self.mainViewGesture];
    }
    
    if (drawerVc && drawerVc != self.mainViewController) {
        self.drawerViewController = drawerVc;
        [self.drawerViewController.view addGestureRecognizer:self.drawerViewGesture];
    }
    
    if (targetVc && targetVc != self.targetViewController) {
        self.targetViewController = targetVc;
    }
}

#pragma mark - UIViewControllerAnimatedTransitioning -

- (void)mainViewGestureHandler:(UIPanGestureRecognizer*)recognizer
{
    CGPoint location = [recognizer locationInView:[self.drawerViewController.view window]];
    CGPoint velocity = [recognizer velocityInView:[self.drawerViewController.view window]];

    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            [self dismissDrawerViewController];
        }
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        {
            
        }
            break;
            
        default:
            break;
    }
}

- (void)drawerViewGestureHandler:(UIScreenEdgePanGestureRecognizer*)recognizer{
    
    CGPoint location = [recognizer locationInView:[self.mainViewController.view window]];
    CGPoint velocity = [recognizer velocityInView:[self.mainViewController.view window]];
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            [self presentDrawerViewController];
        }
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            CGFloat animationRatio = location.x / CGRectGetWidth([self.mainViewController.view window].bounds);
            NSLog(@"animationRatio : %f", location.x);
            [self updateInteractiveTransition:animationRatio];
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        {
            if (velocity.x > 0) {
                [self finishInteractiveTransition];
            } else {
                [self cancelInteractiveTransition];
            }
        }
            break;
            
        default:
            break;
    }
}

//Define the transition duration
-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return 1.0;
}


//Define the transition
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
//    //STEP 1
//    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
//    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
//    CGRect sourceRect = [transitionContext initialFrameForViewController:fromVC];
//    
//    /*STEP 2:   Draw different transitions depending on the view to show
//     for sake of clarity this code is divided in two different blocks
//     */
//    
//    //STEP 2A: From the First View(INITIAL) -> to the Second View(MODAL)
//    if(self.transitionTo == MODAL){
//        
//        //1.Settings for the fromVC ............................
//        CGAffineTransform rotation;
//        rotation = CGAffineTransformMakeRotation(M_PI);
//        fromVC.view.frame = sourceRect;
//        fromVC.view.layer.anchorPoint = CGPointMake(0.5, 0.0);
//        fromVC.view.layer.position = CGPointMake(160.0, 0);
//        
//        //2.Insert the toVC view...........................
//        UIView *container = [transitionContext containerView];
//        [container insertSubview:toVC.view belowSubview:fromVC.view];
//        CGPoint final_toVC_Center = toVC.view.center;
//        
//        [container addSubview:fromVC.view];
//        
//        toVC.view.center = CGPointMake(-sourceRect.size.width, sourceRect.size.height);
//        toVC.view.transform = CGAffineTransformMakeRotation(M_PI/2);
//        
//        //3.Perform the animation...............................
//        [UIView animateWithDuration:1.0
//                         animations:^{
//                             
//                             //Setup the final parameters of the 2 views
//                             //the animation interpolates from the current parameters
//                             //to the next values.
//                             fromVC.view.transform = rotation;
//                             toVC.view.center = final_toVC_Center;
//                             toVC.view.transform = CGAffineTransformMakeRotation(0);
//                         } completion:^(BOOL finished) {
//                             
//                             //When the animation is completed call completeTransition
//                             [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
//                             
//                         }];
//    }
//    
//    //STEP 2B: From the Second view(MODAL) -> to the First View(INITIAL)
//    else{
//        
//        //Settings for the fromVC ............................
//        CGAffineTransform rotation;
//        rotation = CGAffineTransformMakeRotation(M_PI);
//        UIView *container = [transitionContext containerView];
//        fromVC.view.frame = sourceRect;
//        fromVC.view.layer.anchorPoint = CGPointMake(0.5, 0.0);
//        fromVC.view.layer.position = CGPointMake(160.0, 0);
//        
//        //Insert the toVC view view...........................
//        [container insertSubview:toVC.view belowSubview:fromVC.view];
//        toVC.view.layer.anchorPoint = CGPointMake(0.5, 0.0);
//        toVC.view.layer.position = CGPointMake(160.0, 0);
//        toVC.view.transform = CGAffineTransformMakeRotation(-M_PI);
//        
//        //Perform the animation...............................
//        [UIView animateWithDuration:1.0
//                              delay:0.0
//             usingSpringWithDamping:0.8
//              initialSpringVelocity:6.0
//                            options:UIViewAnimationOptionCurveEaseIn
//         
//                         animations:^{
//                             
//                             //Setup the final parameters of the 2 views
//                             //the animation interpolates from the current parameters
//                             //to the next values.
//                             fromVC.view.center = CGPointMake(fromVC.view.center.x - 320, fromVC.view.center.y);
//                             toVC.view.transform = CGAffineTransformMakeRotation(-0);
//                             
//                         } completion:^(BOOL finished) {
//                             
//                             //When the animation is completed call completeTransition
//                             [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
//                             
//                             // release the modal controller
////                             self.modalController = nil;
//                             
//                         }];
//    }
//    
    
}


#pragma mark - private methods

- (void)setCurrentViewController:(UIViewController *)currentViewController
{
    if (_currentViewController != currentViewController) {
        
        _currentViewController = currentViewController;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(drawerTransitionWithCurrentViewController:)] == YES) {
            [self.delegate drawerTransitionWithCurrentViewController:self.currentViewController];
        }
    }
}

- (void)presentDrawerViewController
{
    if (self.currentViewController == self.drawerViewController) return;
    
    if (self.targetViewController && self.mainViewController && self.drawerViewController) {

        [self.targetViewController presentViewController:self.drawerViewController animated:YES completion:^{
            self.currentViewController = self.drawerViewController;
        }];
    }
}

- (void)dismissDrawerViewController
{
    if (self.currentViewController == self.drawerViewController) return;
    
    if (self.targetViewController && self.mainViewController && self.drawerViewController) {
        
        [self.targetViewController dismissViewControllerAnimated:YES completion:^{
            self.currentViewController = self.mainViewController;
        }];
    }
}



#pragma mark - UIVieControllerTransitioningDelegate -

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                   presentingController:(UIViewController *)presenting
                                                                       sourceController:(UIViewController *)source
{
    self.transitionType = PGDrawerTransitionTypeDrawer;
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    self.transitionType = PGDrawerTransitionTypeMain;
    return self;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator
{
    return self;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator{
    return nil;
}



@end
