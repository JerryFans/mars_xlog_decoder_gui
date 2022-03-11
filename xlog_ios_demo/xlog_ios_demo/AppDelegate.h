//
//  AppDelegate.h
//  xlog_ios_demo
//
//  Created by 逸风 on 2022/3/5.
//

#import <UIKit/UIKit.h>

#define JRDebugMessage  [[NSString stringWithFormat:@"func = %s, line = %d", __FUNCTION__, __LINE__] UTF8String]

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (nonatomic, strong) UIWindow *window;
@end

