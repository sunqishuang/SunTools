//
//  BDPayManager.m
//  BDBase
//
//  Created by apple on 16/4/19.
//  Copyright © 2016年 bodong. All rights reserved.
//

#import "BDPayManager.h"
/**   支付宝相关   */
#import "Order.h"
#import "DataSigner.h"
#import <AlipaySDK/AlipaySDK.h>
#import "APAuthV2Info.h"
/**   微信相关     */

#import "payRequsestHandler.h"

#import "Base64.h"

@interface BDPayManager ()
/**  支付宝支付结果的回调的回调            */
@property (nonatomic, copy) BDAliPayPayResylt alipayPayResylt;

@property (nonatomic, copy) weixinPayFailure weixinPayFailureBlock;

@property (nonatomic, copy) weixinPaySucceed weixinPaySucceedBlock;

@end


@implementation BDPayManager

+(instancetype)sharedBDPayManager {
    static dispatch_once_t onceToken;
    static BDPayManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[BDPayManager alloc] init];
    });
    return instance;
}

/**   ************************************************************************************      */
/**   ************************************************************************************      */
/**   ************************************************************************************      */

#pragma mark ==== 支付宝支付  前端签名加密方式 支付


#pragma mark   ==============点击订单模拟支付行为==============
//
//选中商品调用支付宝极简支付
//
- (void)BD_Alipay
{
    //重要说明
    //这里只是为了方便直接向商户展示支付宝的整个支付流程；所以Demo中加签过程直接放在客户端完成；
    //真实App里，privateKey等数据严禁放在客户端，加签过程务必要放在服务端完成；
    //防止商户私密数据泄露，造成不必要的资金损失，及面临各种安全风险；
    /*============================================================================*/
    /*=======================需要填写商户app申请的===================================*/
    /*============================================================================*/
    NSString *appID = @"2016102602338081";
    /*============================================================================*/
    /*============================================================================*/
    /*============================================================================*/
    
    //partner和seller获取失败,提示
    if ([appID length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"缺少appId"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    Order* order = [Order new];
    
    // NOTE: app_id设置
    order.app_id = _requstData[@"app_id"];
    
    // NOTE: 支付接口名称
    order.method = _requstData[@"method"];
    
    // NOTE: 参数编码格式
    order.charset = _requstData[@"charset"];
    
    // NOTE: 当前时间点
//    NSDateFormatter* formatter = [NSDateFormatter new];
//    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    order.timestamp = _requstData[@"timestamp"];
    
    // NOTE: 支付版本
    order.version = _requstData[@"version"];
    
    // NOTE: sign_type设置
    order.sign_type = _requstData[@"sign_type"];
    
    order.notify_url = _requstData[@"notify_url"];
    
    // NOTE: 商品数据
    order.biz_content = [BizContent new];
    
    NSDictionary *bizDic = _requstData[@"biz_content"];
    order.biz_content.body = bizDic[@"body"];
    order.biz_content.subject = bizDic[@"subject"];
    order.biz_content.out_trade_no = bizDic[@"out_trade_no"]; //订单ID（由商家自行制定）
    order.biz_content.timeout_express = bizDic[@"timeout_express"]; //超时时间设置
    order.biz_content.total_amount = bizDic[@"total_amount"];; //商品价格
    
    order.biz_content.seller_id = @"2088521040952642";
    
    

    
    //将商品信息拼接成字符串
    NSString *orderInfo = [order orderInfoEncoded:NO];
    NSString *orderInfoEncoded = [order orderInfoEncoded:YES];
    NSLog(@"orderSpec = %@",orderInfo);
    
    // NOTE: 获取私钥并将商户信息签名，外部商户的加签过程请务必放在服务端，防止公私钥数据泄露；
    //       需要遵循RSA签名规范，并将签名字符串base64编码和UrlEncode
//    id<DataSigner> signer = CreateRSADataSigner(key);
//    NSString *signedString = [signer signString:orderInfo];
    
    

    // NOTE: 如果加签成功，则继续执行支付
    if (_privateKey != nil) {
//        LMLog(@"_peivateKey === %@",_privateKey);
        //应用注册scheme,在AliSDKDemo-Info.plist定义URL types
        NSString *appScheme = @"ALIPAY2016102602338081";

        NSString *orderString = [NSString stringWithFormat:@"%@&sign=%@",
                                 orderInfoEncoded,_privateKey];
        
//        LMLog(@"orderString ==== %@",orderString);
        

        
//        // NOTE: 调用支付结果开始支付
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSString *status = [NSString stringWithFormat:@"%@",resultDic[@"resultStatus"]];
            
//            LMLog(@".........resultDic ==== %@",resultDic);
            if ([status isEqualToString:@"9000"]) {
                _alipayPayResylt(BDAlipaySucceed);
                
            }
            
            if ([status isEqualToString:@"8000"]) {
                _alipayPayResylt(BDAlipayBeingProcessed);
            }
            
            if ([status isEqualToString:@"4000"]) {
                _alipayPayResylt(BDAlipayFailed);
            }
            
            if ([status isEqualToString:@"6001"]) {
                _alipayPayResylt(BDAlipayUserCancel);
            }
            
            if ([status isEqualToString:@""]) {
                _alipayPayResylt(BDAlipayNetworkConnectionError);
            }

        }];
        
        MJWeakSelf
        self.alipayBlock = ^(NSString *status){
            
//              LMLog(@".........status ==== %@",status);
            
            
            if ([status isEqualToString:@"9000"]) {
                weakSelf.alipayPayResylt(BDAlipaySucceed);
                
            }
            
            if ([status isEqualToString:@"8000"]) {
                weakSelf.alipayPayResylt(BDAlipayBeingProcessed);
            }
            
            if ([status isEqualToString:@"4000"]) {
                weakSelf.alipayPayResylt(BDAlipayFailed);
            }
            
            if ([status isEqualToString:@"6001"]) {
                weakSelf.alipayPayResylt(BDAlipayUserCancel);
            }
            
            if ([status isEqualToString:@""]) {
                weakSelf.alipayPayResylt(BDAlipayNetworkConnectionError);
            }
        };
        
    }
}



- (NSString*)urlEncodedString:(NSString *)string
{
    NSString * encodedString = (__bridge_transfer  NSString*) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)string, NULL, (__bridge CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8 );
    
    return encodedString;
}


-(NSString*)encodeString:(NSString*)unencodedString{
    
    // CharactersToBeEscaped = @":/?&=;+!@#$()~',*";
    // CharactersToLeaveUnescaped = @"[].";
    
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)unencodedString,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8));
    
    return encodedString;
}

//URLDEcode
-(NSString *)decodeString:(NSString*)encodedString

{
    //NSString *decodedString = [encodedString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding ];
    
    NSString *decodedString  = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                                                                     (__bridge CFStringRef)encodedString,
                                                                                                                     CFSTR(""),
                                                                                                                     CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    return decodedString;
}



/**   ************************************************************************************      */
/**   ************************************************************************************      */
/**   ************************************************************************************      */


#pragma mark =====  后台做处理的支付宝支付方式
- (void)BOD_Alipay_PayInfo{
    NSString *appScheme = @"ALIPAY2088121743675150";
    [[AlipaySDK defaultService] payOrder:self.payInfo fromScheme:appScheme callback:^(NSDictionary *resultDic) {
        
        NSString *status = [NSString stringWithFormat:@"%@",resultDic[@"resultStatus"]];
        if ([status isEqualToString:@"9000"]) {  //    9000	订单支付成功
            _alipayPayResylt(BDAlipaySucceed);
        }
        
        if ([status isEqualToString:@"8000"]) {  //    8000	正在处理中
            _alipayPayResylt(BDAlipayBeingProcessed);
        }
        
        if ([status isEqualToString:@"4000"]) {  //    4000	订单支付失败
            _alipayPayResylt(BDAlipayFailed);
        }
        
        if ([status isEqualToString:@"6001"]) { //    6001	用户中途取消
            _alipayPayResylt(BDAlipayUserCancel);
        }
        
        if ([status isEqualToString:@""]) {   //    6002	网络连接出错
            _alipayPayResylt(BDAlipayNetworkConnectionError);
        }
    }];
    
    
}

/**   ************************************************************************************      */
/**   ************************************************************************************      */
/**   ************************************************************************************      */
#pragma mark =======  支付宝支付结果

- (void)BDAliPayPayResult:(BDAliPayPayResylt)aliPayPayResult{
    _alipayPayResylt = aliPayPayResult;
}

/**   ************************************************************************************      */
/**   ************************************************************************************      */
/**   ************************************************************************************      */

#pragma mark ******   微信支付  前端签名加密
-(void)BD_WXPay_Pay{
    //本实例只是演示签名过程， 请将该过程在商户服务器上实现
    
    //创建支付签名对象
    payRequsestHandler *WeiXinPay = [payRequsestHandler alloc];
    /**  商品名称 */
    WeiXinPay.order_name = self.BDShop_Title;
    /**  价格单位为分*/
    CGFloat WeiXin_Price = self.BDShop_order_Price * 100;
    WeiXinPay.order_price = [NSString stringWithFormat:@"%0.0f",WeiXin_Price];
   
    /** 微信订单号*/
    WeiXinPay.order_no = self.BDShop_order_No;
    /** 回调 URL */
    WeiXinPay.notify_URL = self.BDWeiXinPaynotifyURL;
    //初始化支付签名对象
    [WeiXinPay init:APP_ID mch_id:MCH_ID];
    [WeiXinPay setKey:PARTNER_ID];
    
    
    
    
    //获取到实际调起微信支付的参数后，在app端调起支付- ( NSMutableDictionary *)BDWeiXinSendPay
    NSMutableDictionary *dict = [WeiXinPay BDWeiXinSendPay];
    
    if(dict == nil){
        
    }else{
        NSMutableString *stamp  = [dict objectForKey:@"timestamp"];
        
        //调起微信支付
        PayReq* req             = [[PayReq alloc] init];
        req.openID              = [dict objectForKey:@"appid"];
        req.partnerId            = [dict objectForKey:@"partnerid"];
        req.prepayId            = [dict objectForKey:@"prepayid"];
        req.nonceStr            = [dict objectForKey:@"noncestr"];
        req.timeStamp           = stamp.intValue;
        req.package             = [dict objectForKey:@"package"];
        req.sign                = [dict objectForKey:@"sign"];
        
        [WXApi sendReq:req];
    }
}

/**   ************************************************************************************      */
/**   ************************************************************************************      */
/**   ************************************************************************************      */
-(void)BOD_WXPay_PayInfo{
    
    
    if (self.payInfoDict) {
        NSMutableString *stamp  = [self.payInfoDict objectForKey:@"timestamp"];
        
        //调起微信支付
        PayReq* req             = [[PayReq alloc] init];
        req.openID              = [self.payInfoDict objectForKey:@"appid"];
        req.partnerId            = [self.payInfoDict objectForKey:@"partnerid"];
        req.prepayId            = [self.payInfoDict objectForKey:@"prepayid"];
        req.nonceStr            = [self.payInfoDict objectForKey:@"noncestr"];
        req.timeStamp           = stamp.intValue;
        req.package             = [self.payInfoDict objectForKey:@"package"];
        req.sign                = [self.payInfoDict objectForKey:@"sign"];

        
        [WXApi sendReq:req];
    }
    else{
//        [LMUntil showErrorHUDViewAtView:APP_WINDOW WithTitle:@"支付信息获取失败"];

        
    }

    
}



/**   ************************************************************************************      */
/**   ************************************************************************************      */
/**   ************************************************************************************      */


#pragma mark - WXApiDelegate
- (void)onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        if (_delegate
            && [_delegate respondsToSelector:@selector(managerDidRecvMessageResponse:)]) {
            SendMessageToWXResp *messageResp = (SendMessageToWXResp *)resp;
            [_delegate managerDidRecvMessageResponse:messageResp];
        }
    } else if ([resp isKindOfClass:[SendAuthResp class]]) {
        if (_delegate
            && [_delegate respondsToSelector:@selector(managerDidRecvAuthResponse:)]) {
            SendAuthResp *authResp = (SendAuthResp *)resp;
            [_delegate managerDidRecvAuthResponse:authResp];
        }
    } else if ([resp isKindOfClass:[AddCardToWXCardPackageResp class]]) {
        if (_delegate
            && [_delegate respondsToSelector:@selector(managerDidRecvAddCardResponse:)]) {
            AddCardToWXCardPackageResp *addCardResp = (AddCardToWXCardPackageResp *)resp;
            [_delegate managerDidRecvAddCardResponse:addCardResp];
        }
        
    }else if([resp isKindOfClass:[PayResp class]]){
        //支付返回结果，实际支付结果需要去微信服务器端查询
//        BDLog(@"=================");
        
        NSString *strMsg,*strTitle = [NSString stringWithFormat:@"支付结果"];
        
//        BDLog(@"%d",resp.errCode);
        
        if (resp.errCode == WXSuccess) {
            if (_weixinPaySucceedBlock) {
                _weixinPaySucceedBlock(resp.errCode);
            }
        }else{
            
            if (_weixinPayFailureBlock) {
                _weixinPayFailureBlock(resp.errCode);
            }
            
        }
    }
}

- (void)onReq:(BaseReq *)req {
    if ([req isKindOfClass:[GetMessageFromWXReq class]]) {
        if (_delegate
            && [_delegate respondsToSelector:@selector(managerDidRecvGetMessageReq:)]) {
            GetMessageFromWXReq *getMessageReq = (GetMessageFromWXReq *)req;
            [_delegate managerDidRecvGetMessageReq:getMessageReq];
        }
    } else if ([req isKindOfClass:[ShowMessageFromWXReq class]]) {
        if (_delegate
            && [_delegate respondsToSelector:@selector(managerDidRecvShowMessageReq:)]) {
            ShowMessageFromWXReq *showMessageReq = (ShowMessageFromWXReq *)req;
            [_delegate managerDidRecvShowMessageReq:showMessageReq];
        }
    } else if ([req isKindOfClass:[LaunchFromWXReq class]]) {
        if (_delegate
            && [_delegate respondsToSelector:@selector(managerDidRecvLaunchFromWXReq:)]) {
            LaunchFromWXReq *launchReq = (LaunchFromWXReq *)req;
            [_delegate managerDidRecvLaunchFromWXReq:launchReq];
        }
    }
}


- (void)weixinPayResultSucceed:(weixinPaySucceed)weixinSucceed failure:(weixinPayFailure)weixinFailure{
    _weixinPaySucceedBlock = weixinSucceed;
    _weixinPayFailureBlock = weixinFailure;
//    WXSuccess           = 0,    /**< 成功    */
//    WXErrCodeCommon     = -1,   /**< 普通错误类型    */
//    WXErrCodeUserCancel = -2,   /**< 用户点击取消并返回    */
//    WXErrCodeSentFail   = -3,   /**< 发送失败    */
//    WXErrCodeAuthDeny   = -4,   /**< 授权失败    */
//    WXErrCodeUnsupport  = -5,   /**< 微信不支持    */
    
}





@end
