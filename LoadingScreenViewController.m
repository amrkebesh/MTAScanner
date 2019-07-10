//
//  LoadingScreenViewController.m
//  MTA Scanner
//
//  Created by Wazir Rafeek on 8/7/17.
//  Copyright © 2017 Wazir Rafeek. All rights reserved.
//

#import "LoadingScreenViewController.h"

@interface LoadingScreenViewController ()

@end

@implementation LoadingScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self performSelector:@selector(transition) withObject:nil afterDelay:2];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)transition {
    [self performSegueWithIdentifier:@"PresentMenu" sender:self];
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
