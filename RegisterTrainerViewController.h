//
//  TrainerInfoViewController.h
//  MTA Scanner
//
//  Created by Wazir Rafeek on 8/16/17.
//  Copyright © 2017 Wazir Rafeek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "KeyboardViewController.h"
#import "KeyboardButton.h"

@interface RegisterTrainerViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate,UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) NSMutableArray *passes;
@property (strong, nonatomic) IBOutlet UITextField *numberPad;
@end
