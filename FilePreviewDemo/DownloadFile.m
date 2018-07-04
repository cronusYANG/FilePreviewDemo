//
//  DownloadFile.m
//  FilePreviewDemo
//
//  Created by poplar on 2018/7/3.
//  Copyright © 2018年 poplar. All rights reserved.
//

#import "DownloadFile.h"
#import "AppDelegate.h"
#import <AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface DownloadFile()<DowloadStateDelegate>

@end

@implementation DownloadFile

+ (instancetype)sharedInstance
{
    static DownloadFile *down = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        down = [[DownloadFile alloc] init];
    });
    return down;
}

- (NSURLSessionDownloadTask *)downloadFileWithURL:(NSURL *)url filePath:(NSString *)path{
  
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request
                                            progress:nil
                                         destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                                             return [NSURL fileURLWithPath:path];
                                         }
                                   completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                                       
                                       if (self.delegate) {
                                           [self.delegate downloadResult:response error:error];
                                       }
                                       
                                       if (error) {
                                           NSLog(@"-----------%@",error);
                                       }
                                       
                                   }];
    
    [task resume];
    
    return task;
  
}

-(void)downloadResult:(NSURLResponse *)response error:(NSError *)error{
    
}


@end
