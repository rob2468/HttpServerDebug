//
//  HSDConsoleLogComponent.m
//  HttpServerDebug
//
//  Created by chenjun on 2018/4/10.
//  Copyright © 2018年 chenjun. All rights reserved.
//
//  produce and consume logs with producer and consumer model

#import "HSDConsoleLogComponent.h"

static int kStdErrIllegalFd = -1;     // stderr illegal file descriptor value

@interface HSDConsoleLogComponent ()

@property (nonatomic, assign) int stdErrFd;                       // saved origin stderr
@property (nonatomic, strong) NSMutableArray<NSString *> *consoleLogs;  // "products"

@end

@implementation HSDConsoleLogComponent

- (instancetype)init {
    self = [super init];
    if (self) {
        self.stdErrFd = kStdErrIllegalFd;
        self.consoleLogs = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    // remove notification observer
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    // reset STDERR_FILENO
    if (self.stdErrFd != kStdErrIllegalFd) {
        dup2(self.stdErrFd, STDERR_FILENO);
        self.stdErrFd = kStdErrIllegalFd;
    }
}

- (NSArray<NSString *> *)consumeLogs {
    NSArray *logs;
    @synchronized (self) {
        // consume
        logs = [self.consoleLogs copy];
        [self.consoleLogs removeAllObjects];
    }
    return logs;
}

- (void)redirectReadCompletionNotificationReceived:(NSNotification *)notification {
    // parse data
    NSData *data = [[notification userInfo] objectForKey:NSFileHandleNotificationDataItem];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    @synchronized (self) {
        // produce
        if (str.length > 0) {
            [self.consoleLogs addObject:str];
        }
    }

    // read
    [[notification object] performSelectorOnMainThread:@selector(readInBackgroundAndNotifyForModes:) withObject:@[NSRunLoopCommonModes] waitUntilDone:NO modes:@[NSRunLoopCommonModes]];
}

#pragma mark - state

- (BOOL)isRedirected {
    BOOL isRedirected;
    if (self.stdErrFd == kStdErrIllegalFd) {
        isRedirected = NO;
    } else {
        isRedirected = YES;
    }
    return isRedirected;
}

#pragma mark -

- (void)redirectStandardErrorOutput {
    // save origin STDERR_FILENO with a new file descriptor
    self.stdErrFd = dup(STDERR_FILENO);

    // redirect standard error output
    NSPipe *stdErrPipe = [NSPipe pipe];
    NSFileHandle *writingHandle= [stdErrPipe fileHandleForWriting];
    int writingHandleFd = [writingHandle fileDescriptor];
    NSFileHandle *readingHandle = [stdErrPipe fileHandleForReading];
    dup2(writingHandleFd, STDERR_FILENO);

    // add notification observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redirectReadCompletionNotificationReceived:) name:NSFileHandleReadCompletionNotification object:readingHandle];

    // read
    [readingHandle performSelectorOnMainThread:@selector(readInBackgroundAndNotifyForModes:) withObject:@[NSRunLoopCommonModes] waitUntilDone:NO modes:@[NSRunLoopCommonModes]];
}

-(void)recoverStandardErrorOutput {
    @synchronized (self) {
        [self.consoleLogs removeAllObjects];
    }

    // remove observer
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleReadCompletionNotification object:nil];

    // reset STDERR_FILENO
    if (self.stdErrFd != kStdErrIllegalFd) {
        dup2(self.stdErrFd, STDERR_FILENO);
        self.stdErrFd = kStdErrIllegalFd;
    }
}

@end
