//
//  ExamCenterViewController.m
//  PGDrawerExample
//
//  Created by suwan on 2016. 3. 29..
//  Copyright © 2016년 suwan. All rights reserved.
//

#import "ExamCenterViewController.h"

#import "PGDrawerTransition.h"

#import "ExamDrawerViewController.h"

@interface ExamCenterViewController ()
@property (nonatomic, strong) PGDrawerTransition *drawerTransition;
@property (nonatomic, strong) ExamDrawerViewController *drawerViewController;
@property (nonatomic, strong) UIButton *button;
@end

@implementation ExamCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor redColor]];
    
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.button setBackgroundColor:[UIColor redColor]];
    [self.button addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.button];
    
    self.drawerViewController = [[ExamDrawerViewController alloc] init];
    
    self.drawerTransition = [[PGDrawerTransition alloc] initWithTargetViewController:self
                                                                drawerViewController:self.drawerViewController];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithTitle:@"메뉴"
                                                             style:UIBarButtonItemStyleDone
                                                            target:self
                                                            action:@selector(open)];
    
    self.navigationItem.leftBarButtonItem = left;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self.button setFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
}

- (void)click
{
    if ([self.button.backgroundColor isEqual:[UIColor redColor]] == YES) {
        [self.button setBackgroundColor:[UIColor blueColor]];
    } else {
        [self.button setBackgroundColor:[UIColor redColor]];
    }
}

- (void)open
{
    [self.drawerTransition presentDrawerViewController];
}

@end
