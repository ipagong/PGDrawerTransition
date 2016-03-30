//
//  PGDrawerViewContainer.h
//  PGDrawerExample
//
//  Created by suwan on 2016. 3. 22..
//  Copyright © 2016년 suwan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PGDrawerTransition.h"

typedef void(^PGDrawerCompletedBlock)(void);

@interface PGDrawerViewContainer : UIViewController

@property (nonatomic, readonly) UIViewController *mainViewController;
@property (nonatomic, readonly) UIViewController *drawerViewController;

@property (nonatomic, readonly) UIViewController *currentViewController;

@property (nonatomic, strong) PGDrawerTransition *drawerTransitioning;

- (instancetype)initWithMainViewController:(UIViewController *)mainViewController
                      drawerViewController:(UIViewController *)drawerViewController;

- (void)openDrawerWithAnimated:(BOOL)animated;
- (void)closeDrawerWithAnimated:(BOOL)animated;

@property (nonatomic, copy) PGDrawerCompletedBlock openBlock;
@property (nonatomic, copy) PGDrawerCompletedBlock closeBlock;

@end
