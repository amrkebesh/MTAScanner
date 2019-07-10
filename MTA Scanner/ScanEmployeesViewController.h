//
//  ScanEmployeesViewController.h
//  MTA Scanner
//
//  Created by Wazir Rafeek on 8/22/17.
//  Copyright © 2017 Wazir Rafeek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "KeyboardViewController.h"
#import "KeyboardButton.h"
#import "EditScansViewController.h"
@interface ScanEmployeesViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate,UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) NSMutableArray *passes;
@property NSMutableDictionary *info;
@property NSArray *selectedTrainers;


@end
