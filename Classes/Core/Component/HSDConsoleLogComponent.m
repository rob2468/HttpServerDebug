//
//  HSDConsoleLogComponent.m
//  HttpServerDebug
//
//  Created by chenjun on 2018/4/10.
//  Copyright © 2018年 chenjun. All rights reserved.
//
//  produce and consume logs with producer and consumer model

#import "HSDConsoleLogComponent.h"

@interface HSDConsoleLogComponent ()

@property (nonatomic, strong) NSThread *readStdErrThread;               // thread for read stderr
@property (nonatomic, strong) NSMutableArray<NSString *> *consoleLogs;  // "products"

@end

@implementation HSDConsoleLogComponent

- (instancetype)init {
    self = [super init];
    if (self) {
        self.consoleLogs = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    // remove notification observer
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // reset STDERR_FILENO
    if (stdErrFd != -1) {
        dup2(stdErrFd, STDERR_FILENO);
        stdErrFd = -1;
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
    [[notification object] performSelector:@selector(readInBackgroundAndNotify) onThread:self.readStdErrThread withObject:nil waitUntilDone:YES];
}


#pragma mark - state

- (BOOL)isRedirected {
    return YES;
}

#pragma mark -

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
    @synchronized (self) {
        [self.consoleLogs removeAllObjects];
    }

    // remove observer
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleReadCompletionNotification object:nil];
    
    // release thread
    self.readStdErrThread = nil;
    
    // reset STDERR_FILENO
    if (stdErrFd != -1) {
        dup2(stdErrFd, STDERR_FILENO);
        stdErrFd = -1;
    }
}

@end
