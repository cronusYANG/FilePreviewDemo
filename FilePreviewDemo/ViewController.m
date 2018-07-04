//
//  ViewController.m
//  FilePreviewDemo
//
//  Created by poplar on 2018/7/3.
//  Copyright © 2018年 poplar. All rights reserved.
//

#import "ViewController.h"
#import <QuickLook/QuickLook.h>
#import "DownloadFile.h"
#import <MBProgressHUD/MBProgressHUD.h>

#define WIDTH CGRectGetWidth([UIScreen mainScreen].bounds)
#define HEIGHT CGRectGetHeight([UIScreen mainScreen].bounds)
#define Dic_Path [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define TempName @"noName"

@interface ViewController ()<QLPreviewControllerDelegate,QLPreviewControllerDataSource,DowloadStateDelegate>
@property(strong,nonatomic) MBProgressHUD *hud;
@property(strong,nonatomic) NSURLSessionDownloadTask *task;
@property(strong,nonatomic) UITextView *textView;
@property(strong,nonatomic) NSString *fileName;
@end

@implementation ViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.hud hideAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [DownloadFile sharedInstance].delegate = self;
    
    [self sandboxPath];
    
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(25, 85, WIDTH-50, 100)];
    [self.textView setBackgroundColor:[UIColor whiteColor]];
    self.textView.font = [UIFont systemFontOfSize:15];
    self.textView.text = @"https://avatars0.githubusercontent.com/u/23354224?s=460&v=4";
    [self.view addSubview:self.textView];
 
    UIButton *btn = [[UIButton alloc] init];
    btn.frame = CGRectMake(100, 200, 80, 44);
    btn.center = CGPointMake(self.view.bounds.size.width/2, self.textView.bounds.size.height+125);
    [btn setTitle:@"在线预览" forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor blackColor]];
    [btn setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside ];
    
}

-(void)btnClick{

    NSString *path = [NSString stringWithFormat:@"%@/%@",Dic_Path,TempName];
    NSURL *url;
    if (self.textView.text.length) {
        url = [NSURL URLWithString:self.textView.text];
        self.task = [[DownloadFile sharedInstance] downloadFileWithURL:url filePath:path];
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.hud.mode = MBProgressHUDModeAnnularDeterminate;
        self.hud.label.text = @"Loading...";
        self.hud.progressObject = self.task.progress;
    }
    
}

-(void)downloadResult:(NSURLResponse *)response error:(NSError *)error{
 
    if (!error) {
        [self.hud hideAnimated:YES];
        
        //*********获取到文件拓展名后复制文件以重命名并删除原有文件
        NSString *name = [NSString stringWithFormat:@"%06d", arc4random() % 100000];
        NSString *ext = [[response.MIMEType componentsSeparatedByString:@"/"] lastObject];
        self.fileName = [NSString stringWithFormat:@"%@.%@",name,ext];
        NSFileManager *fileManage = [NSFileManager defaultManager];
        NSString *filePath = [NSString stringWithFormat:@"%@/%@",Dic_Path,TempName];
        NSString *toFilePath = [NSString stringWithFormat:@"%@/%@",Dic_Path,self.fileName];
        if (![fileManage fileExistsAtPath:toFilePath]) {
            BOOL isSuccess = [fileManage copyItemAtPath:filePath toPath:toFilePath error:nil];
//            NSLog(@"%@",isSuccess ? @"拷贝成功" : @"拷贝失败");
            if (isSuccess) {
                 [fileManage removeItemAtPath:filePath error:nil];
            }
        }
        //**********
        
        [self preview];
    }else{

        self.hud.mode = MBProgressHUDModeText;
        self.hud.label.text = [error localizedDescription];
        [self.hud hideAnimated:YES afterDelay:1.5];
    }
}

-(void)preview{
    QLPreviewController *qlController = [[QLPreviewController alloc]init];
    qlController.delegate = self;
    qlController.dataSource = self;
    qlController.hidesBottomBarWhenPushed = YES;
    qlController.currentPreviewItemIndex = 1;
    [self presentViewController:qlController animated:YES completion:nil];
}

-(void)sandboxPath{//沙盒路径
    NSString *path = NSHomeDirectory();
    NSLog(@"--------NSHomeDirectory: %@",path);
}

-(NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller{
    return 1;
}

-(id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index{
    
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path_document = [documentDirectory stringByAppendingPathComponent:self.fileName];
    
    if (path_document) {
        NSURL *url = [NSURL fileURLWithPath:path_document];
        return url;
    }else{
        return nil;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
