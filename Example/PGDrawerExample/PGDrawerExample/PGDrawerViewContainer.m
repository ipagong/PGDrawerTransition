//
//  PGDrawerViewContainer.m
//  PGDrawerExample
//
//  Created by suwan on 2016. 3. 22..
//  Copyright © 2016년 suwan. All rights reserved.
//

#import "PGDrawerViewContainer.h"

@interface PGDrawerViewContainer () <PGDrawerTransitionDelegate>

@property (nonatomic, strong) UIViewController *mainViewController;
@property (nonatomic, strong) UIViewController *drawerViewController;

@property (nonatomic, strong) UIViewController *currentViewController;

@end

@implementation PGDrawerViewContainer

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (instancetype)initWithMainViewController:(UIViewController *)mainViewController
                      drawerViewController:(UIViewController *)drawerViewController
{
    self = [super init];
    if (self) {
        
        [self setupDefaultTransitioning];
        
        self.mainViewController   = mainViewController;
        self.drawerViewController = drawerViewController;
        
//        [self setupDrawerView];
        [self setupMainView];
        
    }
    return self;
}

- (void)setupDefaultTransitioning
{
    self.drawerTransitioning = [[PGDrawerTransition alloc] init];
    self.drawerTransitioning.delegate = self;
    self.modalTransitionStyle = UIModalPresentationCustom;

    __weak typeof(self)weakSelf = self;
    
    self.drawerTransitioning.presentBlock = ^{
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf setupMainView];
    };
    
    self.drawerTransitioning.dismissBlock = ^{
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf setupDrawerView];
    };
}

- (void)openDrawerWithAnimated:(BOOL)animated
{
    if (self.currentViewController == self.drawerViewController) return;
    
    [self presentViewController:self.drawerViewController animated:YES completion:nil];
}

- (void)closeDrawerWithAnimated:(BOOL)animated
{
    if (self.currentViewController == self.mainViewController) return;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setupMainView
{
    //view setting for container.
    [self removeChildViewControllerFromContainer:self.mainViewController];

    [self addChildViewController:self.mainViewController];
    [self.view addSubview:self.mainViewController.view];
    
    self.mainViewController.view.frame = [self frameForMainViewController];
    [self.mainViewController didMoveToParentViewController:self];
}

- (void)setupDrawerView
{
    //view setting for container.
    [self removeChildViewControllerFromContainer:self.drawerViewController];
    
    [self addChildViewController:self.drawerViewController];
    [self.view addSubview:self.drawerViewController.view];
    
    self.drawerViewController.view.frame = [self frameForDrawerViewController];
    [self.drawerViewController didMoveToParentViewController:self];
}

- (CGRect)frameForMainViewController
{
    return self.view.frame;
}

- (CGRect)frameForDrawerViewController
{
    CGRect frame = self.view.frame;
    
    frame.size.width *= 0.7;
    
    return frame;
}

- (void)removeChildViewControllerFromContainer:(UIViewController *)childViewController {
    if(childViewController == nil) return;
    
    [childViewController willMoveToParentViewController:nil];
    [childViewController.view removeFromSuperview];
    [childViewController removeFromParentViewController];
}

- (void)setCurrentViewController:(UIViewController *)currentViewController
{
    [self setCurrentViewController:currentViewController animated:NO];
}

- (void)setCurrentViewController:(UIViewController *)currentViewController animated:(BOOL)animated
{
}

#pragma mark - PGDrawerInteractionTranstionDelegate

- (UIViewController *)viewControllerWithDrawerTransitionType:(PGDrawerTransitionType)transitionViewType
{
    switch (transitionViewType) {
        case PGDrawerTransitionTypeMain:   // main
            return self.mainViewController;
        case PGDrawerTransitionTypeDrawer: // drawer
            return self.drawerViewController;
        case PGDrawerTransitionTypeTarget: // container.
            return self;
        default:
            return self.mainViewController;
    }
}

- (void)drawerTransitionWithCurrentViewController:(UIViewController *)currentViewController
{
    self.currentViewController = currentViewController;
}

#pragma mark - override uiviewcontroller methods

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion
{
    [super presentViewController:viewControllerToPresent animated:flag completion:^{
        [self closeDrawerWithAnimated:NO];
        if (completion) completion();
    }];
}

@end
