//
//  OfflineModeViewController.h
//  MTA Scanner
//
//  Created by Wazir Rafeek on 8/30/17.
//  Copyright © 2017 Wazir Rafeek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "KeyboardViewController.h"
#import "KeyboardButton.h"
#import "EditScansViewController.h"

@interface OfflineModeViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate,UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) NSMutableArray *passes;

@end
