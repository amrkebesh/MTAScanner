//
//  FacilityListViewController.h
//  MTA Scanner
//
//  Created by Wazir Rafeek on 8/22/17.
//  Copyright © 2017 Wazir Rafeek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CourseInfoViewController.h"
@interface FacilityListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) UIViewController* courseInfo;
@end
