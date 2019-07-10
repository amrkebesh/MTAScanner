//
//  MenuViewController.h
//  MTA Scanner
//
//  Created by Wazir Rafeek on 8/7/17.
//  Copyright © 2017 Wazir Rafeek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface MenuViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate,UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) NSMutableArray *passes;

@end
