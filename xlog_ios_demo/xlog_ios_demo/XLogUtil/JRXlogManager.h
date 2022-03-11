//
//  JRXlogManager.h
//  xlog_ios_demo
//
//  Created by 逸风 on 2022/3/5.
//

#import <Foundation/Foundation.h>

extern NSString * const XlogDirName;

static inline NSString* getXlogPath(NSString *pathName) {
    NSString* logPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:pathName];
    return logPath;
}

typedef NS_ENUM(NSInteger, XLoggerType) {
    XLoggerTypeDebug,
    XLoggerTypeInfo,
    XLoggerTypeWarning,
    XLoggerTypeError
};

@interface JRXlogManager : NSObject

+ (instancetype)shared;

- (void)initXlog:(const char *)prefixName pathName:(NSString *)pathName;

/** 关闭Xlog */
- (void)closeXlog;

- (void)log:(XLoggerType)level tag:(const char *)tag content:(NSString *)content;

- (void)infoLogWithTag:(const char *)tag Content:(NSString *)content;

- (void)debugLogWithTag:(const char *)tag Content:(NSString *)content;

- (void)errorLogWithTag:(const char *)tag Content:(NSString *)content;

- (void)warningLogWithTag:(const char *)tag Content:(NSString *)content;

@end
