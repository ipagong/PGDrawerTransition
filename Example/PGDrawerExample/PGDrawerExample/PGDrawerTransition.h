//
//  DrawerInteractiveTransition.h
//  PGDrawerExample
//
//  Created by suwan on 2016. 3. 23..
//  Copyright © 2016년 suwan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^PGDrawerInteractionBlock)(void);

typedef NS_ENUM(NSInteger, PGDrawerTransitionType) {
    
    PGDrawerTransitionTypeMain,
    PGDrawerTransitionTypeDrawer,
    
    PGDrawerTransitionTypeTarget,
};

@protocol PGDrawerTransitionDelegate <NSObject>

- (UIViewController *)viewControllerWithDrawerTransitionType:(PGDrawerTransitionType)transitionViewType;
- (void)drawerTransitionWithCurrentViewController:(UIViewController *)currentViewController;

@end

@interface PGDrawerTransition : UIPercentDrivenInteractiveTransition
<UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate>

@property (nonatomic, assign) PGDrawerTransitionType transitionType;

@property (nonatomic, weak) id <PGDrawerTransitionDelegate> delegate;

@property (nonatomic, copy) PGDrawerInteractionBlock presentBlock;
@property (nonatomic, copy) PGDrawerInteractionBlock dismissBlock;

@end
