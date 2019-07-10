//
//  CourseInfoViewController.h
//  MTA Scanner
//
//  Created by Wazir Rafeek on 8/15/17.
//  Copyright © 2017 Wazir Rafeek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CourseListViewController.h"
#import "ScanEmployeesViewController.h"

@interface CourseInfoViewController : UIViewController

@property (strong, nonatomic) NSMutableArray *passes;
@property NSString *course;
@property NSString *facility;
@property NSDictionary *courseInfo;
@end
