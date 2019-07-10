//
//  CourseInfoViewController.m
//  MTA Scanner
//
//  Created by Wazir Rafeek on 8/15/17.
//  Copyright © 2017 Wazir Rafeek. All rights reserved.
//

#import "CourseInfoViewController.h"
#import "MenuViewController.h"

@interface CourseInfoViewController ()
@property (strong, nonatomic) IBOutlet UIDatePicker *startdate;
@property (strong, nonatomic) IBOutlet UIDatePicker *endDate;
@property (strong, nonatomic) IBOutlet UIDatePicker *startTime;
@property (strong, nonatomic) IBOutlet UIDatePicker *endTime;
@property (strong, nonatomic) IBOutlet UISearchBar *courseBar;
@property (strong, nonatomic) IBOutlet UISearchBar *facilityBar;

@end

@implementation CourseInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setPickerColors];
    _passes=[[NSMutableArray alloc] init];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self populateCourseName];
    [self populateFacilityName];
}

-(void)populateCourseName
{
    if (_course!=nil){
        [_courseBar setText:_course];
    }
}

-(void)populateFacilityName
{
    if (_facility!=nil){
        [_facilityBar setText:_facility];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setPickerColors {
    _startdate.backgroundColor = [UIColor clearColor];
    _endDate.backgroundColor = [UIColor clearColor];
    _startTime.backgroundColor = [UIColor clearColor];
    _endTime.backgroundColor = [UIColor clearColor];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString: @"toScanner"]){
        MenuViewController *scanner = segue.destinationViewController;
        scanner.passes = _passes;
    }
    
    if ([segue.identifier isEqualToString: @"OpenCourseList"]){
        CourseListViewController *courseList = segue.destinationViewController;
        courseList.courseInfo = self;
    }
    
    if ([segue.identifier isEqualToString: @"OpenFacilityList"]){
        CourseListViewController *courseList = segue.destinationViewController;
        courseList.courseInfo = self;
    }

    
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
    [self presentViewController:alert animated:YES completion:nil];

}
- (IBAction)nextButton:(id)sender {
    if ([self validate]){
        [self.tabBarController setSelectedIndex:1];
    }
}

-(BOOL)validate
{
    //Course Selected?
    if (_courseBar.text.length==0){
        [self validateError:@"Please select a course before continuing."];
        return NO;
    }
    
    //Facility Selected?
    if (_facilityBar.text.length==0){
        [self validateError:@"Please select a facility before continuing."];
        return NO;
    }
    
    //Valid Dates?
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger comps = (NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear);
    
    NSDateComponents *date1Components = [calendar components:comps
                                                    fromDate: [_startdate date]];
    NSDateComponents *date2Components = [calendar components:comps
                                                    fromDate: [_endDate date]];
    
    NSDate *date1 = [calendar dateFromComponents:date1Components];
    NSDate *date2 = [calendar dateFromComponents:date2Components];
    
    
    if ([date1 compare:date2]==NSOrderedDescending){
        [self validateError:@"Your start date is later than your end date."];
        return NO;
    }
    
    //Valid Times?
    if ([[_endTime date] timeIntervalSinceDate:[_startTime date]]<=1799){
        [self validateError:@"Your start time is the same as or later than your end time."];
        return NO;
    }
    
    [self passInformation];
    return YES;
}

-(void)passInformation
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd/yyyy"];
    
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"hh:mm a"];
    
    id objects[] = {_course, _facility, [dateFormat stringFromDate:[_startdate date]], [dateFormat stringFromDate:[_endDate date]], [timeFormat stringFromDate:[_startTime date]], [timeFormat stringFromDate:[_endTime date]]};
    id keys[]={@"course", @"facility", @"startDate", @"endDate", @"startTime", @"endTime"};
    NSUInteger count = sizeof(objects) / sizeof(id);
    
    _courseInfo = [NSDictionary dictionaryWithObjects:objects
                                              forKeys:keys
                                                count:count];
    ScanEmployeesViewController *scanVC = (ScanEmployeesViewController *) [self.tabBarController viewControllers][2];
    //[scanVC.info setValuesForKeysWithDictionary:_courseInfo];
    scanVC.info = [NSMutableDictionary dictionaryWithDictionary:_courseInfo];

}

-(void)validateError:(NSString *)errorMsg
{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Error"
                                  message:errorMsg
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
