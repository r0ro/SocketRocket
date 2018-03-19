//
//  ViewController.m
//  TestUpload
//
//  Created by Romain Fliedel on 19/03/2018.
//

#import "ViewController.h"

#define WS_URL @"ws://192.168.7.42:8888/"
#define TEST_BUF_SIZE (1024*1024)

#if TARGET_IPHONE_SIMULATOR
#error This test app must be run on device
#endif

@interface ViewController ()

@end

@implementation ViewController

-(void) viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"init websocket: %@", WS_URL);
    [_statusLbl setText:@"IDLE"];
    [_uploadBtn setEnabled: NO];
    __ws = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:WS_URL]];
    /*
       comment the following line to got back to previous behaviour and
       make the app crash
     */
    [__ws setMaxTxQueueSize: 1024*1024*4];
    [__ws setDelegate:self];
    [__ws open];
}

-(void) doUpload
{
    size_t queued = 0;
    NSError *err;
    /* gen some payload data */
    char *buf = malloc(TEST_BUF_SIZE);
    if (!buf) {
        NSLog(@"malloc failed");
        return;
    }
    
    NSData *payload = [NSData dataWithBytesNoCopy: buf length:TEST_BUF_SIZE freeWhenDone: YES];
    
    NSLog(@"Start upload thread");
    
    /* send as much data as we can */
    while (true)
    {
        if ([[NSThread currentThread] isCancelled]) {
            NSLog(@"thread cancelled");
            break;
        }
        
        /* prevent duplicate page */
        if (SecRandomCopyBytes(kSecRandomDefault, TEST_BUF_SIZE, buf) != errSecSuccess)
            NSLog(@"failed to generate random bytes");

        if (![__ws sendDataNoCopy:payload error:&err]) {
            NSLog(@"failed to send data: %@", err);
            break;
        }
        
        queued += TEST_BUF_SIZE;
        dispatch_async(dispatch_get_main_queue(), ^{
            [_queuedLbl setText: [NSString stringWithFormat:@"%zd MB", queued / 1024 / 1024]];
        });
    }
    
    NSLog(@"doUpload DONE");
}

-(IBAction) startUpload:(id) sender
{
    if (__uploadThread) {
        [__uploadThread cancel];
    }
    [_uploadBtn setEnabled: NO];
    [_statusLbl setText:@"UPLOADING"];
    __uploadThread = [[NSThread alloc] initWithTarget:self selector:@selector(doUpload) object:nil];
    [__uploadThread start];
}


#pragma mark - SRWebSocketDelegate

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    NSLog(@"webSocket - didReceiveMessage : %@", message);
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"webSocket - webSocketDidOpen : %@", [[webSocket url] absoluteString]);
    [_statusLbl setText:@"CONNECTED"];
    [_uploadBtn setEnabled: YES];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"webSocket - didFailWithError : %@", [error description]);
    [_statusLbl setText:@"ERROR"];
    [_uploadBtn setEnabled: NO];
    
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"WS Error" message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
    [vc addAction: [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [vc dismissViewControllerAnimated:NO completion:nil];
    }]];
    [self presentViewController: vc animated:NO completion:nil];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSLog(@"webSocket - didCloseWithCode : %@, clean: %d", reason, wasClean);
    [_statusLbl setText:@"CLOSED"];
    [_uploadBtn setEnabled: NO];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload {
    NSLog(@"webSocket - didReceivePong : %@", pongPayload);
}

@end
