//
//  ViewController.m
//  js-OC交互
//
//  Created by a on 17/3/24.
//  Copyright © 2017年 a. All rights reserved.
//


#define SCREENW [UIScreen mainScreen].bounds.size.width
#define SCREENH [UIScreen mainScreen].bounds.size.height

#import "ViewController.h"
#import <WebKit/WebKit.h>

@interface ViewController ()<WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler>

@property(nonatomic,strong)WKWebView *webView;
@property (strong, nonatomic)WKWebViewConfiguration *configuration;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    [self initWKWebView];

}

//初始化页面
- (void)initWKWebView
{
    //进行配置控制器
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    //实例化对象
    configuration.userContentController = [WKUserContentController new];

    //调用JS方法
    [configuration.userContentController addScriptMessageHandler:self name:@"removeNavigationBar"];//移除导航栏
    [configuration.userContentController addScriptMessageHandler:self name:@"AddNavigationBar"];//添加导航栏
    self.configuration = configuration;

    WKPreferences *preferences = [WKPreferences new];
    preferences.javaScriptCanOpenWindowsAutomatically = YES;
    preferences.minimumFontSize = 40.0;
    configuration.preferences = preferences;

    self.automaticallyAdjustsScrollViewInsets = NO;
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 64, SCREENW, SCREENH-64) configuration:configuration];

    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"js-oc" ofType:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    [self.webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:filePath]];

    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    [self.view addSubview:self.webView];

}

#pragma mark - WKNavigationDelegate
//准备加载页面
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    NSLog(@"webView provision to load!");
}

//已开始加载页面，可以在这一步向view中添加一个过渡动画
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    NSLog(@"webView did start to load!");
}

//页面加载完成时调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    NSLog(@"webView did finish!");
}

//页面准备加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"webView did fail provision!");
}

//页面加载过程中失败
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"webView did fail navigation!");
}

// 接收到服务器跳转请求之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation
{
    NSLog(@"webView did receive service redirect for provision!");
}

// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSLog(@"webView decide policy for navigation action!");

    NSLog(@"%@",navigationAction.request.URL.absoluteString);
    NSLog(@"%ld",(long)navigationAction.navigationType);
    //允许跳转
    decisionHandler(WKNavigationActionPolicyAllow);
    //不允许跳转
    //decisionHandler(WKNavigationActionPolicyCancel);
}

// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    NSLog(@"webView decide policy for navigation response!");

    NSLog(@"%@",navigationResponse.response.URL.absoluteString);
    //允许跳转
    decisionHandler(WKNavigationResponsePolicyAllow);
    //不允许跳转
//    decisionHandler(WKNavigationResponsePolicyCancel);
}

#pragma mark - WKUIDelegate
//当把JS返回给控制器,然后弹窗就是这样设计的
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];

    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    //    message.body  --  Allowed types are NSNumber, NSString, NSDate, NSArray,NSDictionary, and NSNull.
    NSLog(@"body:%@",message.body);
    if ([message.name isEqualToString:@"AddNavigationBar"]) {
        NSLog(@"Add NavigationBar");

        [self alertWithTitle:nil message:@"Add NavigationBar"];

        [self addNavigationBar];

    } else if ([message.name isEqualToString:@"removeNavigationBar"]) {
        NSLog(@"remove NavigationBar");
        [self alertWithTitle:nil message:@"remove NavigationBar"];

        [self removeNavigationBar];

    }

}

- (void)addNavigationBar
{
//    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController setNavigationBarHidden:NO];

    self.webView.frame = CGRectMake(0, 64, SCREENW, SCREENH-64);
}

- (void)removeNavigationBar
{
//    self.navigationController.navigationBar.hidden = YES;
    [self.navigationController setNavigationBarHidden:YES];

    self.webView.frame = CGRectMake(0, 0, SCREENW, SCREENH);

}

- (void)alertWithTitle:(NSString *)title message:(NSString *)messageStr
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title ? title :@"原生弹窗" message:messageStr preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"sure" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
