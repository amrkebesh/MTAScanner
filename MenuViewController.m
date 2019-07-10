//
//  MenuViewController.m
//  MTA Scanner
//
//  Created by Wazir Rafeek on 8/7/17.
//  Copyright © 2017 Wazir Rafeek. All rights reserved.
//

#import "MenuViewController.h"
#import "CourseInfoViewController.h"

@interface MenuViewController ()
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
@property SystemSoundID authSoundID;

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addBorders];
    [self formatNumpad];
    [self prepareCamera];
    
    //_passes=[[NSMutableArray alloc] init];
    
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
    
}


-(void)addBorders
{
    _previewView.layer.borderColor = [UIColor whiteColor].CGColor;
    _previewView.layer.borderWidth = 3.0f;
    
    _scannerView.layer.borderColor = [UIColor greenColor].CGColor;
    _scannerView.layer.borderWidth = 3.0f;
}

-(void)formatNumpad
{
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:_numberPad action:@selector(resignFirstResponder)];
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar.items = [NSArray arrayWithObject:barButton];
    
    _numberPad.inputAccessoryView = toolbar;
    
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
    [_previewView.layer addSublayer:_prevLayer];
    
    [_session startRunning];

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
            passNumber =[detectionString substringWithRange:NSMakeRange(4, 6)];
            _label.text =nil;
            [self playAuthSound];
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
    if ([self checkDuplicates:passNumber]){
        [_passes addObject:passNumber];
        _label.text=[NSString stringWithFormat:@"Pass Number: %@",passNumber];
    }
    else{
        _label.text=@"Already Scanned!";
    }
    [self performSelector: @selector(sessionStart:) withObject:nil afterDelay:1];
    
    //[self presentViewController:alert animated:YES completion:nil];
    
}

-(void)sessionStart: (id)sender
{
    [_session startRunning];
    _label.text=@"Scanning...";
}

-(BOOL)checkDuplicates:(NSString *)newPass
{
    for (NSString *pass in _passes) {
        if (pass == newPass){
            return NO;
        }
        else{
            return YES;
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

-(void)dbQuery
{
    /* Create your request string with parameter name as defined in PHP file
    NSString *myRequestString = [NSString stringWithFormat:@"title=%@&description=%@&city=%@",eventTitle.text,eventDescription.text,eventCity.text];
    
    // Create Data from request
    NSData *myRequestData = [NSData dataWithBytes: [myRequestString UTF8String] length: [myRequestString length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString: @"http://www.youardomain.com/phpfilename.php"]];
    // set Request Type
    [request setHTTPMethod: @"POST"];
    // Set content-type
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    // Set Request Body
    [request setHTTPBody: myRequestData];
    // Now send a request and get Response
    NSData *returnData = [NSURLConnection sendSynchronousRequest: request returningResponse: nil error: nil];
    // Log Response
    NSString *response = [[NSString alloc] initWithBytes:[returnData bytes] length:[returnData length] encoding:NSUTF8StringEncoding];
    NSLog(@"%@",response);
     */
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



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
