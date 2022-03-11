//
//  JRXlogManager.m
//  xlog_ios_demo
//
//  Created by 逸风 on 2022/3/5.
//

#import "JRXlogManager.h"
#import "LogUtil.h"

#import <mars/xlog/appender.h>
#import <mars/xlog/xlogger.h>
#import <sys/xattr.h>

NSString * const XlogDirName = @"/testXlog";

@implementation JRXlogManager

static JRXlogManager *shareInstance = nil;
+ (JRXlogManager *)shared {
    if (!shareInstance) shareInstance = [[self allocWithZone:NULL] init];
    return shareInstance;
}

- (void)initXlog:(const char *)prefixName pathName:(NSString *)pathName {
    NSString* logPath = getXlogPath(pathName);
    
    // set do not backup for logpath
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    setxattr([logPath UTF8String], attrName, &attrValue, sizeof(attrValue), 0, 0);
    
    // init xlog
#if DEBUG
    xlogger_SetLevel(kLevelDebug);
    mars::xlog::appender_set_console_log(true);
#else
    xlogger_SetLevel(kLevelInfo);
    appender_set_console_log(false);
#endif
    mars::xlog::XLogConfig config;
    config.mode_ = mars::xlog::kAppenderAsync;
    config.logdir_ = [logPath UTF8String];
    config.nameprefix_ = prefixName;
    config.compress_mode_ = mars::xlog::kZlib;
    config.compress_level_ = 0;
    config.cachedir_ = "";
    config.cache_days_ = 0;
    //    config.pub_key_ = "";
        config.pub_key_ = "572d1e2710ae5fbca54c76a382fdd44050b3a675cb2bf39feebe85ef63d947aff0fa4943f1112e8b6af34bebebbaefa1a0aae055d9259b89a1858f7cc9af9df1";
    
//    PRIV_KEY = "145aa7717bf9745b91e9569b80bbf1eedaa6cc6cd0e26317d810e35710f44cf8"
//    PUB_KEY = "572d1e2710ae5fbca54c76a382fdd44050b3a675cb2bf39feebe85ef63d947aff0fa4943f1112e8b6af34bebebbaefa1a0aae055d9259b89a1858f7cc9af9df1"
    appender_open(config);
}

// 关闭Xlog
- (void)closeXlog {
    mars::xlog::appender_close();
}


- (void)debugLogWithTag:(const char *)tag Content:(NSString *)content{
    [self log:XLoggerTypeDebug tag:tag content:content];
}

- (void)infoLogWithTag:(const char *)tag Content:(NSString *)content{
    
    [self log:XLoggerTypeInfo tag:tag content:content];
}

- (void)errorLogWithTag:(const char *)tag Content:(NSString *)content{
    
    [self log:XLoggerTypeError tag:tag content:content];
}

- (void)warningLogWithTag:(const char *)tag Content:(NSString *)content{
    
    [self log:XLoggerTypeWarning tag:tag content:content];
}

- (void)log:(XLoggerType)level tag:(const char *)tag content:(NSString *)content{
    
    switch (level) {
        case XLoggerTypeDebug:
            LOG_DEBUG(tag, content);
            break;
        case XLoggerTypeInfo:
            LOG_INFO(tag, content);
            break;
        case XLoggerTypeWarning:
            LOG_WARNING(tag, content);
            break;
        case XLoggerTypeError:
            LOG_ERROR(tag, content);
            break;
        default:
            break;
    }
    
}

@end
