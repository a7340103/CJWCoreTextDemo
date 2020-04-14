//
//  SecViewController.m
//  CJWCoreTextDemo
//
//  Created by Jiawei Dong on 2020/4/12.
//  Copyright © 2020 djw.cc. All rights reserved.
//

#import "SecViewController.h"

@interface SecViewController ()

@end

@implementation SecViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    UIButton *but = [UIButton buttonWithType:UIButtonTypeSystem];
    but.frame = CGRectMake(100, 100, 100, 100);

    [but setTitle:@"go back" forState:UIControlStateNormal];
    [but setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [but addTarget:self action:@selector(go2) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:but];
    
        NSString *itemImg = @"";
    //    if (config && [[config objectForKey:NSStringFromClass([viewController class])] ? : @"" isEqualToString:@"0"]) {
//            itemImg = @"back_black";
    //    }else{
            itemImg = @"white_black";
    //    }
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:itemImg] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(popself)];
        self.navigationItem.leftBarButtonItem = backItem;
    [self configNavigationBarHome:@"navgationbar_background_test"];

}

- (void)go2{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//       [self configNavigationBarHome:@"navgationbar_background_test"];
//    [self configNavigationBarHome:@"navgationbar_background"];

}

- (void)popself {
    [self.view endEditing:YES];
    [self go2];
//    [self popViewControllerAnimated:YES];
}


- (void)configNavigationBarHome:(NSString *)imgName{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:imgName] forBarMetrics:UIBarMetricsDefault];
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
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
