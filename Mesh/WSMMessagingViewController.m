//
//  WSMMessagingViewController.m
//  Mesh
//
//  Created by Cristian Monterroza on 8/23/14.
//  Copyright (c) 2014 wrkstrm. All rights reserved.
//

#import <SOMessaging/SOMessage.h>
#import <LayerKit/LayerKit.h>
#import "WSMMessagingViewController.h"
#import "ContentManager.h"
#import "Message.h"

@interface WSMMessagingViewController () <LYRMessageControllerDelegate>

@property (strong, nonatomic) NSMutableArray *dataSource;
@property (strong, nonatomic) UIImage *myImage;
@property (strong, nonatomic) UIImage *partnerImage;

@property (nonatomic, strong) LYRMessageController *messageController;

@end

@implementation WSMMessagingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"View Did Loads!");
    
    //ReactiveCocoa
    [WSMLayerManager.sharedInstance.messageBodySubject subscribeNext:^(NSArray *newMessages) {
        NSLog(@"New Messages: %@", newMessages);
        for (LYRMessage *layerMessage in newMessages) {
            NSLog(@"Message: %@", layerMessage);
            SOMessage *soMessage = [SOMessage new];
            
            NSString *senderAddress = layerMessage.sender.userIdentifier;
            NSLog(@"SenderAddress: %@", senderAddress);
            NSLog(@"Current User Address: %@", self.currentUser.address);
            
            soMessage.fromMe = [self.currentUser.uupc isEqualToString:senderAddress];
            
            if (layerMessage.bodies.count == 0) {
                NSLog(@"I don't know.");
                soMessage.text = @"I don't know.";
            } else {
                LYRMessageBody *firstBody = layerMessage.bodies[0];
                soMessage.text = [firstBody stringRepresentation];
            }
            soMessage.type = SOMessageTypeText;
            soMessage.date = layerMessage.date;
            NSLog(@"SOMesssage: %@", soMessage);
            [self.dataSource addObject:soMessage];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self refreshMessages];
        });
    }];
    
    //UI
    NSData *meContent, *recipientContent;
    meContent = [[self.currentUser attachmentNamed:@"avatar"] content];
    recipientContent = [[self.recipient attachmentNamed:@"avatar"] content];
    
    self.myImage = [UIImage imageWithData:meContent];
    self.partnerImage = [UIImage imageWithData:recipientContent];
}

- (void) setConversationIdentifier:(NSString *)conversationIdentifier {
    if (conversationIdentifier) {
        _conversationIdentifier = conversationIdentifier;
        
        //LYR
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY self.conversations.identifier == %@",
                                  _conversationIdentifier];
        NSSortDescriptor *sortDescriptions = [NSSortDescriptor sortDescriptorWithKey:@"dateSender" ascending:YES];
        
        _messageController = [LYRMessageController.alloc initWithClient:[LYRClient sharedClient]
                                                              predicate:predicate
                                                        sortDescriptors:@[sortDescriptions]
                                                             fetchLimit:0
                                                            fetchOffset:0
                                                     sectionNameKeyPath:nil];
        
        NSLog(@"Message controller: %@",_messageController);
        _messageController.delegate = self;
        
        
        [self.messageController performUpdateWithCompletion:^(NSError *error) {
            if (error) {
                NSLog(@"Error: %@", error);
            } else {
                [self loadMessages];
                [self refreshMessages];
            }
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"Bad stuff");
}

- (void)loadMessages {
    NSMutableArray *allMessages = @[].mutableCopy;
    
    NSLog(@"Sections Count: %lu", (unsigned long)self.messageController.numberOfSections);
    for (NSUInteger section = 0; section < self.messageController.numberOfSections; section++) {
        LYRMessageSectionInfo *sectionInfo = [self.messageController sectionAtIndex:section];
        NSLog(@"Section: %@", sectionInfo);
        NSLog(@"Section Rows: %lu", (unsigned long)sectionInfo.numberOfMessages);
        
        for (NSUInteger row = 0; row < sectionInfo.numberOfMessages; row++) {
            LYRMessage *layerMessage = [sectionInfo messageAtIndex:row];
            NSLog(@"Message: %@", layerMessage);
            SOMessage *message = [SOMessage new];
    
            NSString *senderAddress = layerMessage.sender.userIdentifier;
            NSLog(@"SenderAddress: %@", senderAddress);
            NSLog(@"Current User Address: %@", self.currentUser.address);
            
            message.fromMe = [self.currentUser.uupc isEqualToString:senderAddress];
            
            if (layerMessage.bodies.count == 0) {
//                dispatch_semaphore_t putSemaphore = dispatch_semaphore_create(0);
//                [[LYRClient sharedClient] fetchMessageBodiesForMessages:@[layerMessage] progress:^(float percent) {
//                    NSLog(@"Percent: %f", percent);
//                } completion:^(NSError *error) {
//                    if (error) {
//                        NSLog(@"Error: %@", error);
//                    } else {
//                        NSLog(@"Nice!");
//                    }
//                    dispatch_semaphore_signal(putSemaphore);
//                }];
//                dispatch_semaphore_wait(putSemaphore, DISPATCH_TIME_FOREVER);
            }
            if (layerMessage.bodies.count == 0) {
                NSLog(@"I don't know.");
                message.text = @"I don't know.";
            } else {
                LYRMessageBody *firstBody = layerMessage.bodies[0];
                message.text = [firstBody stringRepresentation];
            }
            message.type = SOMessageTypeText;
            message.date = layerMessage.date;
            NSLog(@"SOMesssage: %@", message);
            [allMessages addObject:message];
        }
    }
    
    self.dataSource = allMessages;
}

- (WSMUser *)currentUser {
    return [[WSMUserManager sharedInstance] currentUser];
}


#pragma mark - SOMessaging data source
- (NSMutableArray *)messages {
    return self.dataSource;
}



- (NSTimeInterval)intervalForMessagesGrouping {
    return 2 * 24 * 3600; // Return 0 for disableing grouping
}

- (void)configureMessageCell:(SOMessageCell *)cell forMessageAtIndex:(NSInteger)index {
    Message *message = self.dataSource[(NSUInteger)index];
    
    // Adjusting content for 3pt. (In this demo the width of bubble's tail is 3pt)
    if (!message.fromMe) {
        cell.contentInsets = UIEdgeInsetsMake(0, 3.0f, 0, 0); //Move content for 3 pt. to right
        cell.textView.textColor = [UIColor blackColor];
    } else {
        cell.contentInsets = UIEdgeInsetsMake(0, 0, 0, 3.0f); //Move content for 3 pt. to left
        cell.textView.textColor = [UIColor blackColor];
    }
    
    cell.userImageView.layer.cornerRadius = self.userImageSize.width/2;
    
    // Fix user image position on top or bottom.
    cell.userImageView.autoresizingMask = message.fromMe ? UIViewAutoresizingFlexibleTopMargin : UIViewAutoresizingFlexibleBottomMargin;
    
    // Setting user images
    cell.userImage = message.fromMe ? self.myImage : self.partnerImage;
}

- (CGFloat)messageMaxWidth {
    return 140;
}

- (CGSize)userImageSize {
    return CGSizeMake(40, 40);
}

- (CGFloat)messageMinHeight {
    return 0;
}

#pragma mark - SOMessaging delegate
- (void)didSelectMedia:(NSData *)media inMessageCell:(SOMessageCell *)cell {
    [super didSelectMedia:media inMessageCell:cell];
}

- (void)messageInputView:(SOMessageInputView *)inputView didSendMessage:(NSString *)message {
    if (![[message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]) {
        return;
    }
    
    LYRClient *client = [LYRClient sharedClient];
    LYRAddress *address = [LYRAddress addressWithString:self.recipient.document[@"address"]];
    LYRMessage *outgoingMessage = [[LYRMessage alloc] initWithClient:client];
    
    NSError *error;
    
    [outgoingMessage addMessageBody:[LYRMessageBody bodyWithText:message] error:&error];
    [outgoingMessage addRecipient:address error:&error];
    
    [client sendMessage:outgoingMessage completion:^(NSError *error2) {
        if(error2) {
            NSLog(@"Error: %@", error2);
        } else {
            NSLog(@"Conversations: %@", outgoingMessage.conversations);
            LYRConversation *conversation = outgoingMessage.conversations[0];
            self.conversationIdentifier = conversation.identifier;
            
            NSLog(@"Success sending message!");
            Message *msg = [[Message alloc] init];
            msg.text = message;
            msg.fromMe = YES;
            [self sendMessage:msg];
        }
    }];
}

- (void)messageInputViewDidSelectMediaButton:(SOMessageInputView *)inputView {
    // Take a photo/video or choose from gallery
}

@end
