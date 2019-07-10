//
//  HomeMenuViewController.m
//  MTA Scanner
//
//  Created by Wazir Rafeek on 8/30/17.
//  Copyright © 2017 Wazir Rafeek. All rights reserved.
//

#import "HomeMenuViewController.h"

@interface HomeMenuViewController ()
@property (strong,nonatomic)UIViewController *loading;
@end

@implementation HomeMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)nextButton:(id)sender {
    [self performSegueWithIdentifier:@"Loading" sender:self];
    NSURL *url = [NSURL URLWithString:@"https://emdmoodle.transit.nyct.com/"];
    NSMutableURLRequest *request = [NSMutableURLRequest
                                    requestWithURL:url
                                    cachePolicy:NSURLRequestUseProtocolCachePolicy
                                    timeoutInterval:5.0];
    
    //create the Method "GET" or "POST"
    [request setHTTPMethod:@"GET"];
  
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if(httpResponse.statusCode == 200)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_loading dismissViewControllerAnimated:YES completion:^{
                    [self performSegueWithIdentifier:@"OnlineMode" sender:self];
                }];
                
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_loading dismissViewControllerAnimated:YES completion:^{
                    [self showAlert];
                }];
            });
        }
    }];
    [dataTask resume];

}

-(void)showAlert{
    
    
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Offline Mode Enabled"
                                  message:@"You are currently unable to access our servers. You may scan employee passes and store them for uploading at a later time once you have reestablished a connection."
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             [self performSegueWithIdentifier:@"OfflineMode" sender:self];
                         }];
    
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];

}
- (IBAction)presentRegister:(id)sender {
    [self performSegueWithIdentifier:@"Loading" sender:self];
    NSURL *url = [NSURL URLWithString:@"https://emdmoodle.transit.nyct.com/"];
    NSMutableURLRequest *request = [NSMutableURLRequest
                                    requestWithURL:url
                                    cachePolicy:NSURLRequestUseProtocolCachePolicy
                                    timeoutInterval:5.0];
    
    //create the Method "GET" or "POST"
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if(httpResponse.statusCode == 200)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_loading dismissViewControllerAnimated:YES completion:^{
                    [self performSegueWithIdentifier:@"PresentRegister" sender:self];
                }];
                
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_loading dismissViewControllerAnimated:YES completion:^{
                    [self offlineAlert];
                }];
            });
        }
    }];
    [dataTask resume];

}

-(void)offlineAlert{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"You are Offline"
                                  message:@"This option is disabled because you are currently unable to access our servers. Please try again at a later time when you have reestablished a connection."
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                         }];
    
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"Loading"]){
        _loading = segue.destinationViewController;
    }
}
- (IBAction)contactUs:(id)sender {
    [self sendEmail];
}

- (void)sendEmail {
    // Email Subject
    NSString *emailTitle = @"EMD Scanner Inquiry";
    // Email Content
    NSString *messageBody = @"";
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"Cesar.AlmanzaSandoval@nyct.com"];
    
    [UINavigationBar appearance].barTintColor = [UIColor colorWithRed:37.0f/255.0f green:39.0f/255.0f blue:70.0f/255.0f alpha:1];
    [UINavigationBar appearance].tintColor = [UIColor whiteColor];
    [UINavigationBar appearance].translucent=NO;
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    [[mc navigationBar]setTintColor:[UIColor whiteColor]];
    [[mc navigationBar]
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
    
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return YES;
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection
{
    return YES;
}
OSStatus SSLSetEnableCertVerify(SSLContextRef context, Boolean enableVerify);
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
