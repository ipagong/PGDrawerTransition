//
//  ExamCenterViewController.m
//  PGDrawerExample
//
//  Created by suwan on 2016. 3. 29..
//  Copyright © 2016년 suwan. All rights reserved.
//

#import "ExamCenterViewController.h"

@interface ExamCenterViewController ()

@end

@implementation ExamCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor redColor]];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{        
//        UIViewController *vc = [[UIViewController alloc] init];
//        [vc.view setBackgroundColor:[UIColor darkGrayColor]];
//        [self.navigationController presentViewController:vc animated:YES completion:nil];
//    });
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
