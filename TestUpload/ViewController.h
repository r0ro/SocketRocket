//
//  ViewController.h
//  TestUpload
//
//  Created by Romain Fliedel on 19/03/2018.
//

#import <UIKit/UIKit.h>
#import <SocketRocket/SocketRocket.h>

@interface ViewController : UIViewController <SRWebSocketDelegate>
{
@private
    SRWebSocket *__ws;
    NSThread *__uploadThread;
}

@property(nonatomic, assign) IBOutlet UIButton *uploadBtn;
@property(nonatomic, assign) IBOutlet UILabel *statusLbl;
@property(nonatomic, assign) IBOutlet UILabel *queuedLbl;

-(IBAction) startUpload:(id) sender;

@end

