//
//  OfflineModeViewController.m
//  MTA Scanner
//
//  Created by Wazir Rafeek on 8/30/17.
//  Copyright © 2017 Wazir Rafeek. All rights reserved.
//

#import "OfflineModeViewController.h"

@interface OfflineModeViewController ()
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

@implementation OfflineModeViewController

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

-(void)viewDidAppear:(BOOL)animated{
    
    [self scanLineAnimation];
    [_session startRunning];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)doneButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
    [_session stopRunning];
    [_numberPad resignFirstResponder];
    _numberPad.text=nil;
    if ([self checkDuplicates:passNumber]){
     [_label setText:[NSString stringWithFormat:@"Pass Number: %@",passNumber]];
        [_passes addObject:passNumber];
     }
     else{
     _label.text=@"Already Entered!";
     }
    [self playAuthSound];
    
    [self performSelector: @selector(sessionStart:) withObject:nil afterDelay:1];
    
    
    
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
    for (NSString *pass in _passes) {
        if ([pass isEqualToString:newPass]){
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
    if ([segue.identifier isEqualToString:@"OfflinePresentScans"]){
        EditScansViewController *editVC = [segue destinationViewController];
        editVC.scans = _passes;
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
    /*
    [_numberPad resignFirstResponder];
        UIAlertController * alert=    [UIAlertController
                                   alertControllerWithTitle:@"Review"
                                   message:@"Review"
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
    
    */
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
