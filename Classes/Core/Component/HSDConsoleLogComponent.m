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

@end

@implementation HSDConsoleLogComponent

- (instancetype)init {
    self = [super init];
    if (self) {
        self.stdErrFd = kStdErrIllegalFd;
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

- (void)redirectReadCompletionNotificationReceived:(NSNotification *)notification {
    // parse data
    NSData *data = [[notification userInfo] objectForKey:NSFileHandleNotificationDataItem];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    if (self.readCompletionBlock) {
        self.readCompletionBlock(str);
    }

    // read
    [[notification object] performSelectorOnMainThread:@selector(readInBackgroundAndNotifyForModes:) withObject:@[NSRunLoopCommonModes] waitUntilDone:NO modes:@[NSRunLoopCommonModes]];
}

#pragma mark - state

- (BOOL)isRedirected {
    return self.stdErrFd != kStdErrIllegalFd;
}

#pragma mark -

- (void)redirectStandardErrorOutput {
    if ([self isRedirected]) {
        return;
    }

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
    if (![self isRedirected]) {
        return;
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
