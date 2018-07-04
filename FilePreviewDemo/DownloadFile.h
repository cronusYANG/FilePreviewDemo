//
//  DownloadFile.h
//  FilePreviewDemo
//
//  Created by poplar on 2018/7/3.
//  Copyright © 2018年 poplar. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DowloadStateDelegate<NSObject>
- (void)downloadResult:(NSURLResponse *)response error:(NSError *)error;
@end

@interface DownloadFile : NSObject
@property(strong,nonatomic) id<DowloadStateDelegate> delegate;
+ (instancetype)sharedInstance;
- (NSURLSessionDownloadTask *)downloadFileWithURL:(NSURL *)url filePath:(NSString *)path;

@end
