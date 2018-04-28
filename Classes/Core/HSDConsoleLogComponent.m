//
//  HSDConsoleLogComponent.m
//  HttpServerDebug
//
//  Created by chenjun on 2018/4/10.
//  Copyright © 2018年 chenjun. All rights reserved.
//

#import "HSDConsoleLogComponent.h"

@interface HSDConsoleLogComponent ()

@property (nonatomic, strong) NSThread *readStdErrThread;   // thread for read stderr

@end

@implementation HSDConsoleLogComponent

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)dealloc {
    // remove notification observer
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // reset STDERR_FILENO
    if (stdErrFd != -1) {
        dup2(stdErrFd, STDERR_FILENO);
    }
}

static int stdErrFd = -1;     // saved origin stderr
- (void)redirectStandardErrorOutput {
    // save origin STDERR_FILENO with a new file descriptor
    stdErrFd = dup(STDERR_FILENO);
    
    // redirect standard error output
    NSPipe *stdErrPipe = [NSPipe pipe];
    NSFileHandle *writingHandle= [stdErrPipe fileHandleForWriting];
    int writingHandleFd = [writingHandle fileDescriptor];
    NSFileHandle *readingHandle = [stdErrPipe fileHandleForReading];
    dup2(writingHandleFd, STDERR_FILENO);
    
    // create a new thread with an active run loop
    self.readStdErrThread = [[NSThread alloc] initWithTarget:self selector:@selector(readStdErrThreadEntryPoint:) object:nil];
    [self.readStdErrThread start];
    
    // add notification observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redirectReadCompletionNotificationReceived:) name:NSFileHandleReadCompletionNotification object:readingHandle];
    
    // read
    [readingHandle performSelector:@selector(readInBackgroundAndNotify) onThread:self.readStdErrThread withObject:nil waitUntilDone:YES];
}

- (void)readStdErrThreadEntryPoint:(id)obj {
    [[NSThread currentThread] setName:@"hsd_read_stderr"];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
    [runLoop run];
}

-(void)recoverStandardErrorOutput {
    // remove observer
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleReadCompletionNotification object:nil];
    
    // release thread
    self.readStdErrThread = nil;
    
    // reset STDERR_FILENO
    if (stdErrFd != -1) {
        dup2(stdErrFd, STDERR_FILENO);
    }
}

- (void)redirectReadCompletionNotificationReceived:(NSNotification *)notification {
    // parse data
    NSData *data = [[notification userInfo] objectForKey:NSFileHandleNotificationDataItem];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    // call back
    if (self.readCompletionBlock) {
        self.readCompletionBlock(str);
    }
    
    // read
    [[notification object] performSelector:@selector(readInBackgroundAndNotify) onThread:self.readStdErrThread withObject:nil waitUntilDone:YES];
}

@end
