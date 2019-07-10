//
//  HomeScreenViewController.m
//  MTA Scanner
//
//  Created by Wazir Rafeek on 8/16/17.
//  Copyright © 2017 Wazir Rafeek. All rights reserved.
//

#import "HomeScreenViewController.h"

@interface HomeScreenViewController ()

@end

@implementation HomeScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSURL *url = [NSURL URLWithString:@"https://emdmoodle.transit.nyct.com/"];
    NSMutableURLRequest *request = [NSMutableURLRequest
                                    requestWithURL:url
                                    cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                    timeoutInterval:3.0];
    
    //create the Method "GET" or "POST"
    [request setHTTPMethod:@"GET"];
    NSLog(@"HERE");
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSLog(@"TEST");
        if(httpResponse.statusCode == 200)
        {
            NSLog(@"OK");
        }
        else
        {
            NSLog(@"NAH");
        }
    }];
    [dataTask resume];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
