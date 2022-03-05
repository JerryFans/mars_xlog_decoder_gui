//
//  ViewController.m
//  xlog_ios_demo
//
//  Created by 逸风 on 2022/3/5.
//

#import "ViewController.h"
#import "JRXlogManager.h"
#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)warningClick:(id)sender {
    [[JRXlogManager shared] warningLogWithTag:JRDebugMessage Content:@"test warning log message"];
}

- (IBAction)debugClick:(id)sender {
    [[JRXlogManager shared] debugLogWithTag:JRDebugMessage Content:@"test debug log message"];
}

- (IBAction)infoLogClick:(id)sender {
    [[JRXlogManager shared] infoLogWithTag:JRDebugMessage Content:@"test info log message"];
}

- (IBAction)errorClick:(id)sender {
    [[JRXlogManager shared] errorLogWithTag:JRDebugMessage Content:@"test error log message"];
}


@end
