//
//  SNSAuthorizeWebView.h
//  SNSHub
//
//  Created by William on 12-10-29.
//  Copyright (c) 2012年 上海兕维信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class SNSAuthorizeWebView;

@protocol SNSAuthorizeWebViewDelegate <NSObject>

- (void)authorizeWebView:(SNSAuthorizeWebView *)webView didReceiveAuthorizeInfo:(id)authorizeInfo;

@end

@interface SNSAuthorizeWebView : UIView <UIWebViewDelegate> 
{
    UIView *panelView;
    UIView *containerView;
    UIActivityIndicatorView *indicatorView;
	UIWebView *webView;
    
    UIInterfaceOrientation previousOrientation;
    
    id<SNSAuthorizeWebViewDelegate> delegate;
}

@property (nonatomic, assign) id<SNSAuthorizeWebViewDelegate> delegate;

- (void)loadRequestWithURL:(NSURL *)url;
- (void)show:(BOOL)animated;
- (void)hide:(BOOL)animated;

@end