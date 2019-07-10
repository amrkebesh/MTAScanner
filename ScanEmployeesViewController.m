//
//  ScanEmployeesViewController.m
//  MTA Scanner
//
//  Created by Wazir Rafeek on 8/22/17.
//  Copyright © 2017 Wazir Rafeek. All rights reserved.
//

#import "ScanEmployeesViewController.h"

@interface ScanEmployeesViewController ()
@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *prevLayer;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIButton *backButton;
@property (strong, nonatomic) IBOutlet UILabel *label;
@property (strong, nonatomic) IBOutlet UIView *previewView;
@property (strong, nonatomic) IBOutlet UITextField *numberPad;
@property (strong, nonatomic) IBOutlet UIView *scannerView;
@property (strong, nonatomic) IBOutlet UIButton *enterBtn;
@property (strong, nonatomic) IBOutlet UIImageView *scanLine;
@property (strong, nonatomic) UIViewController *loading;
@property SystemSoundID authSoundID;
@end

@implementation ScanEmployeesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self formatNumpad];
    [self prepareCamera];
    [self addBorders];
    [self addKeyboard];
    
    
    
    _passes = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter]   addObserver:self
                                               selector:@selector(scanLineAnimation)
                                                   name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]   removeObserver:self
                                                      name:UIApplicationWillResignActiveNotification
                                                    object:nil];
    
    
}


-(void)scanLineAnimation
{
    _scanLine.frame=CGRectMake(-32.0f, 0.0f, 32.0f, _scannerView.frame.size.height);
    [UIView setAnimationsEnabled:YES];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView animateWithDuration:3.0f
                          delay:0.0f
                        options: UIViewAnimationOptionRepeat | UIViewAnimationCurveLinear
                     animations: ^{_scanLine.frame = CGRectOffset(_scanLine.frame, 400, 0);}
                     completion:NULL];
    
}
-(void)viewDidAppear:(BOOL)animated
{
    [self scanLineAnimation];
    [_session startRunning];

    
}

-(void)viewDidDisappear:(BOOL)animated
{
    [_session stopRunning];
}

-(void)addKeyboard
{
    KeyboardViewController *keyboard =[self.storyboard instantiateViewControllerWithIdentifier:@"Keyboard"];
    keyboard.numberPad=_numberPad;
    [_numberPad setInputView: keyboard.view];
    
    for(UIButton *button in [keyboard.view subviews]) {
        if([button isKindOfClass:[KeyboardButton class]]) {
            KeyboardButton *key = (KeyboardButton *)button;
            key.numberPad=_numberPad;
            [key addTarget:key action:@selector(typing) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
}

-(void)typing
{
    //Function for custom keyboard
}

-(void)addBorders
{
    //_previewView.layer.borderColor = [UIColor blackColor].CGColor;
    //_previewView.layer.borderWidth = 5.0f;
    
    _scannerView.layer.borderColor = [UIColor greenColor].CGColor;
    _scannerView.layer.borderWidth = 3.0f;
}

-(void)formatNumpad
{
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:_numberPad action:@selector(resignFirstResponder)];
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar.items = [NSArray arrayWithObject:barButton];
    
    //_numberPad.inputAccessoryView = toolbar;
    
}

-(void)prepareCamera
{
    _session = [[AVCaptureSession alloc] init];
    AVCaptureDevice* device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    
    AVCaptureDeviceInput* input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (input) {
        [_session addInput:input];
    } else {
        NSLog(@"Error: %@", error);
    }
    
    AVCaptureMetadataOutput* output = [[AVCaptureMetadataOutput alloc] init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [_session addOutput:output];
    
    output.metadataObjectTypes = [output availableMetadataObjectTypes];
    
    _prevLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
    _prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _prevLayer.frame = _previewView.layer.bounds;
    
    [_session startRunning];
    
    [_previewView.layer addSublayer:_prevLayer];
    [_previewView addSubview:_scannerView];
    
    
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    
    CGRect highlightViewRect = CGRectZero;
    AVMetadataMachineReadableCodeObject *barCodeObject;
    NSString *detectionString = nil;
    NSString *passNumber = nil;
    NSArray *barCodeTypes = @[AVMetadataObjectTypeCode39Code];
    
    for (AVMetadataObject *metadata in metadataObjects) {
        for (NSString *type in barCodeTypes) {
            if ([metadata.type isEqualToString:type])
            {
                barCodeObject = (AVMetadataMachineReadableCodeObject *)[_prevLayer transformedMetadataObjectForMetadataObject:(AVMetadataMachineReadableCodeObject *)metadata];
                highlightViewRect = barCodeObject.bounds;
                detectionString = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
                break;
            }
        }
        
                if (detectionString != nil && detectionString.length==17)
        {
            passNumber = [self formatPassNumber:detectionString];
            _label.text =nil;
            [self displayScannedAlert:passNumber];
            //[_session stopRunning];
            break;
        }
    }
    
}
- (IBAction)enterClicked:(id)sender {
    if ([_numberPad.text length]==6){
        [_session stopRunning];
        [self displayScannedAlert:_numberPad.text];
    }
    else{
        [self showErrorMessage];
    }
    
}

-(NSString *)formatPassNumber:(NSString *)pass
{
    if ([[pass substringWithRange:NSMakeRange(0, 4)] isEqualToString:@"0000"]){
        return [pass substringWithRange:NSMakeRange(4, 6)];
    }
    else{
        return [NSString stringWithFormat:@"M%@",[pass substringWithRange:NSMakeRange(5, 5)]];
    }
}



-(void)showErrorMessage
{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Error"
                                  message:@"The number you entered is invalid."
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

- (void) displayScannedAlert:(NSString*)passNumber
{
    /* UIAlertController * alert=   [UIAlertController
     alertControllerWithTitle:@"ID Entered"
     message:[NSString stringWithFormat:@"%@%@", @"Pass Number: ", passNumber]
     preferredStyle:UIAlertControllerStyleAlert];
     
     UIAlertAction* ok = [UIAlertAction
     actionWithTitle:@"OK"
     style:UIAlertActionStyleDefault
     handler:^(UIAlertAction * action)
     {
     [_session startRunning];
     _label.text =@"Scanning...";
     _numberPad.text=nil;
     if ([self checkDuplicates:passNumber]){
     [_passes addObject:passNumber];
     
     }
     [alert dismissViewControllerAnimated:YES completion:nil];
     }];
     UIAlertAction* cancel = [UIAlertAction
     actionWithTitle:@"Cancel"
     style:UIAlertActionStyleDefault
     handler:^(UIAlertAction * action)
     {
     [_session startRunning];
     _label.text =@"Scanning...";
     [alert dismissViewControllerAnimated:YES completion:nil];
     }];
     
     
     [alert addAction:ok];
     [alert addAction:cancel];
     */
    
    
    
    [_session stopRunning];
    [_numberPad resignFirstResponder];
    _numberPad.text=nil;
    /*if ([self checkDuplicates:passNumber]){
     [self dbQuery:passNumber];
     [_label setText:[NSString stringWithFormat:@"Pass Number: %@",passNumber]];
     }
     else{
     _label.text=@"Already Entered!";
     }
     */
    [self playAuthSound];
    [self dbQuery:passNumber];
    [self performSelector: @selector(sessionStart:) withObject:nil afterDelay:1];
    
    //[self presentViewController:alert animated:YES completion:nil];
    
}
-(void)dbQuery:(NSString *)pass
{
    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://emdmoodle.transit.nyct.com/my/appScripts/getEmployee.php"]];
    
    NSString *userUpdate = [NSString stringWithFormat:@"pass=%@",pass];
    
    //create the Method "GET" or "POST"
    [urlRequest setHTTPMethod:@"POST"];
    
    //Convert the String to Data
    NSData *data1 = [userUpdate dataUsingEncoding:NSUTF8StringEncoding];
    
    //Apply the data to the body
    [urlRequest setHTTPBody:data1];
    
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if(httpResponse.statusCode == 200)
        {
            NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if(![responseString isEqualToString:@""])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([self checkDuplicates:responseString]){
                        [_label setText:[NSString stringWithFormat:@"%@",responseString]];
                        NSArray *namePassPair = [[NSArray alloc] initWithObjects:pass,responseString, nil];
                        [_passes addObject:namePassPair];
                    }
                    
                    else{
                        [_label setText:@"Already Scanned!"];
                    }
                });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_label setText:@"Pass Number not Found!"];
                });
            }
        }
        else
        {
            NSLog(@"Error");
        }
    }];
    [dataTask resume];
    
}


-(NSString *)addTrainer:(NSString *)trainer
{
    [_passes addObject:trainer];
    return trainer;
}

-(void)sessionStart: (id)sender
{
    [_session startRunning];
    _label.text=@"Scanning...";
}

-(BOOL)checkDuplicates:(NSString *)newPass
{
    for (NSArray *pass in _passes) {
        if ([pass[1] isEqualToString:newPass]){
            return NO;
        }
        
    }
    return YES;
    
}
- (IBAction)showList:(id)sender {
    [_session stopRunning];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 50.0f, self.view.bounds.size.width, self.view.bounds.size.height-100) style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.backgroundColor=[UIColor blackColor];
    _tableView.allowsSelection=NO;
    
    
    _backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_backButton   addTarget:self
                      action:@selector(dismissTable:)
            forControlEvents:UIControlEventTouchUpInside];
    _backButton.frame = CGRectMake(self.view.bounds.size.width-100, self.view.bounds.size.height-50, 100.0f, 50.0f);
    _backButton.titleLabel.font=[UIFont fontWithName:@"HelveticaNeue-Bold" size:22];
    _backButton.backgroundColor=[UIColor blackColor];
    [_backButton setTitle:@"Done" forState:UIControlStateNormal];
    
    
    [self.view addSubview:_tableView];
    [self.view addSubview:_backButton];
    
    
}
-(IBAction)dismissTable:(id)sender
{
    [_session startRunning];
    [_tableView removeFromSuperview];
    [_backButton removeFromSuperview];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _passes.count;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_numberPad resignFirstResponder];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
    }
    cell.textLabel.text =  [_passes objectAtIndex:indexPath.row];
    cell.textLabel.textColor=[UIColor whiteColor];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
    cell.backgroundColor=[UIColor blackColor];
    
    UIButton *removeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [removeButton   addTarget:self
                       action:@selector(removePass:)
             forControlEvents:UIControlEventTouchUpInside];
    removeButton.frame = CGRectMake(cell.frame.size.width, 0.0f, 100.0f, cell.frame.size.height);
    removeButton.backgroundColor=[UIColor blackColor];
    removeButton.titleLabel.font=[UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
    [removeButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [removeButton setTitle:@"Remove" forState:UIControlStateNormal];
    [cell addSubview:removeButton];
    
    return cell;
}

-(IBAction)removePass:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:_tableView];
    NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:buttonPosition];
    [_passes removeObjectAtIndex:indexPath.row];
    [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
}

- (IBAction)backBtn:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^(void){
        //CourseInfoViewController *courseInfo = [self presentingViewController];
        //courseInfo.passes = _passes;
    }];
    
    
    
}


- (void)playAuthSound {
    if (_authSoundID == 0) {
        NSURL *soundURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"authSound"
                                                                   withExtension:@"wav"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL,
                                         &_authSoundID);
    }
    AudioServicesPlaySystemSound(_authSoundID);
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancel:(id)sender {
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Warning"
                                  message:@"You will lose any data you have entered so far. Do you still wish to cancel the current entry?"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yes = [UIAlertAction
                          actionWithTitle:@"Yes"
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * action)
                          {
                              [self dismissViewControllerAnimated:YES completion:nil];
                          }];
    
    UIAlertAction* no = [UIAlertAction
                         actionWithTitle:@"No"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                         }];
    
    [alert addAction:yes];
    [alert addAction:no];
    [_numberPad resignFirstResponder];
    [self presentViewController:alert animated:YES completion:nil];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PresentScans"]){
        EditScansViewController *editVC = [segue destinationViewController];
        editVC.scans = _passes;
    }
    
    if ([segue.identifier isEqualToString:@"Uploading"]){
         _loading = [segue destinationViewController];
    }

}
- (IBAction)backButton:(id)sender {
    [self.tabBarController setSelectedIndex:1];
}

- (IBAction)finishButton:(id)sender {
    if ([_passes count]!=0){
        [self finishAction];
    }
    else{
        UIAlertController * alert=    [UIAlertController
                                       alertControllerWithTitle:@"Error"
                                       message:@"Please scan at least one employee."
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
    
}

-(void)finishAction
{
    [_numberPad resignFirstResponder];
    NSString *trainers = [[NSString alloc] init];
    for (NSArray *trainer in _selectedTrainers){
        trainers = [trainers stringByAppendingString:[NSString stringWithFormat:@"%@ (%@)\n", trainer[1], trainer[0]]];
    }
    NSString *summary = [NSString stringWithFormat: @"Course: \n%@ \n\n"
                         "Trainers: \n%@\n"
                         "Facility: \n%@ \n"
                         "Start Date: \n%@ \n\n"
                         "End Date: \n%@ \n\n"
                         "Start Time: \n%@ \n\n"
                         "End Time: \n%@ \n\n"
                         "*To review the employees who will be checked-in to this class, press 'Cancel' and then 'View Scanned Employees'",
                         [_info objectForKey:@"course"],
                         trainers,
                         [_info objectForKey:@"facility"],
                         [_info objectForKey:@"startDate"],
                         [_info objectForKey:@"endDate"],
                         [_info objectForKey:@"startTime"],
                         [_info objectForKey:@"endTime"]
                         ];
    UIAlertController * alert=    [UIAlertController
                                   alertControllerWithTitle:@"Review"
                                   message:summary
                                   preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* cancel = [UIAlertAction
                         actionWithTitle:@"Cancel"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             [_session startRunning];
                         }];

    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"Submit"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [self dbQuery];
                             [alert dismissViewControllerAnimated:YES completion:nil];
                         }];
    
    [alert addAction:cancel];
    [alert addAction:ok];
    
    [_session stopRunning];
    [self presentViewController:alert animated:YES completion:nil];
    

}

-(void)dbQuery
{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [self performSegueWithIdentifier:@"Uploading" sender:self];
    NSMutableURLRequest *urlRequest =[NSMutableURLRequest
                                      requestWithURL:[NSURL URLWithString:@"https://emdmoodle.transit.nyct.com/my/appScripts/uploadInfo.php"]
                                      cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                      timeoutInterval:5.0];
    

    
   
    NSMutableArray *employeePasses = [[NSMutableArray alloc] init];
    for (NSArray *pass in _passes) {
        [employeePasses addObject:pass[0]];
    }
    NSData *employeeData = [NSJSONSerialization dataWithJSONObject:employeePasses options:NSJSONWritingPrettyPrinted error:nil];
    NSString *employeeString = [[NSString alloc] initWithData:employeeData encoding:NSUTF8StringEncoding];
    
    
    NSMutableArray *trainerNames = [[NSMutableArray alloc] init];
    for (NSArray *pass in _selectedTrainers) {
        [trainerNames addObject:pass[1]];
    }
    NSData *trainerData = [NSJSONSerialization dataWithJSONObject:trainerNames options:NSJSONWritingPrettyPrinted error:nil];
    NSString *trainerString = [[NSString alloc] initWithData:trainerData encoding:NSUTF8StringEncoding];
    
    
    NSString *uploadInfo = [NSString stringWithFormat: @"course=%@&startDate=%@&endDate=%@&employees=%@&trainers=%@",
                            [_info objectForKey:@"course"],
                            [_info objectForKey:@"startDate"],
                            [_info objectForKey:@"endDate"],
                            employeeString,
                            trainerString
                            ];
    
    //create the Method "GET" or "POST"
    [urlRequest setHTTPMethod:@"POST"];
    
    //Convert the String to Data
    NSData *data1 = [uploadInfo dataUsingEncoding:NSUTF8StringEncoding];
    
    //Apply the data to the body
    [urlRequest setHTTPBody:data1];
    
    __block NSString *responseString;
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if(httpResponse.statusCode == 200)
        {
           
            responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if (![responseString isEqualToString:@""]){
                UIAlertController * alert=    [UIAlertController
                                               alertControllerWithTitle:@"Error"
                                               message:@"A group with this name already exists. Please contact us."
                                               preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* ok = [UIAlertAction
                                     actionWithTitle:@"OK"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                         [_session startRunning];
                                     }];
                
                [alert addAction:ok];
                [_loading dismissViewControllerAnimated:YES completion:^{
                    [self presentViewController:alert animated:YES completion:^{
                        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                    }];
                }];
                
            }
            else{
                UIAlertController * alert=    [UIAlertController
                                               alertControllerWithTitle:@"Success!"
                                               message:@"You information has been successfully uploaded."
                                               preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* ok = [UIAlertAction
                                     actionWithTitle:@"OK"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                         [self dismissViewControllerAnimated:YES completion:nil];
                                         [_session startRunning];
                                     }];
                
                [alert addAction:ok];
                [_loading dismissViewControllerAnimated:YES completion:^{
                    [self presentViewController:alert animated:YES completion:^{
                        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                    }];
                }];
            }
        
        }
        else
        {
            UIAlertController * alert=    [UIAlertController
                                           alertControllerWithTitle:@"Connection Error"
                                           message:@"You have lost connection to our servers. Please attempt to submit once you have reestablished a connection."
                                           preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                    [_session startRunning];
                                 }];
            
            [alert addAction:ok];
            [_loading dismissViewControllerAnimated:YES completion:^{
                [self presentViewController:alert animated:YES completion:^{
                    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                }];
            }];

        }
    }];
    [dataTask resume];
    
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
