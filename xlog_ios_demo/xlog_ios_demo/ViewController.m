//
//  ViewController.m
//  xlog_ios_demo
//
//  Created by 逸风 on 2022/3/5.
//

#import "ViewController.h"
#import "JRXlogManager.h"
#import "AppDelegate.h"
#import <SSZipArchive/SSZipArchive.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)uoloadLog:(id)sender {
    [SVProgressHUD show];
    NSString *tmpPath = NSTemporaryDirectory();
    NSString *tmpLogPath = getXlogPath(XlogDirName);
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"MM-dd_HH-mm";
    NSString *zipPath = [tmpPath stringByAppendingPathComponent:[NSString stringWithFormat:@"logs_%@.zip", [formatter stringFromDate:NSDate.date]]];
    BOOL result = [SSZipArchive createZipFileAtPath:zipPath withContentsOfDirectory:tmpLogPath];
    if(result) {
        NSURL *url = [NSURL fileURLWithPath:zipPath];
        [self showsUIActivityVControllerWithUrlrs:@[url]];
    } else {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:@"Zip file fail"];
    }
}

- (void)showsUIActivityVControllerWithUrlrs:(NSArray<NSURL *> *)urls {
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:urls applicationActivities:nil];
    NSArray *excludedActivities = @[UIActivityTypeAirDrop,
                                    UIActivityTypePostToWeibo,
                                    UIActivityTypeMessage, UIActivityTypeMail,
                                    UIActivityTypePrint, UIActivityTypeCopyToPasteboard,
                                    UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,
                                    UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,
                                    UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo,
    ];
    controller.excludedActivityTypes = excludedActivities;
    
    if ([(NSString *)[UIDevice currentDevice].model hasPrefix:@"iPad"]) {
        controller.popoverPresentationController.sourceView = self.view;
        controller.popoverPresentationController.sourceRect = CGRectMake([UIScreen mainScreen].bounds.size.width * 0.5, [UIScreen mainScreen].bounds.size.height, 10, 10);
    }
    [self presentViewController:controller animated:YES completion:^{
        [SVProgressHUD dismiss];
    }];
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
