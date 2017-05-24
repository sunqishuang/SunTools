//
//  BDPayManager.h
//  BDBase
//
//  Created by apple on 16/4/19.
//  Copyright © 2016年 bodong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXApi.h"

/**
 支付宝支付结果的枚举
 */
typedef enum {
    BDAlipaySucceed = 9000,    //支付成功
    BDAlipayBeingProcessed = 8000, //正在处理
    BDAlipayFailed = 4000,        //订单支付失败
    BDAlipayUserCancel = 6001,     //用户中途取消
    BDAlipayNetworkConnectionError = 6002 ///网络连接错误
    
}BDAlipayResult;

/**
 *  支付宝支付相关
 *
 *  @param AlipayResylt <#AlipayResylt description#>
 */
typedef void(^BDAliPayPayResylt)(BDAlipayResult AlipayResylt);


typedef void(^BDAlipayBlock)(NSString *resultStatus);


/**
 *  微信支付相关
 *
 *  @param code <#code description#>
 */
typedef void(^weixinPaySucceed)(int code);
typedef void(^weixinPayFailure)(int code);

@protocol WXApiManagerDelegate <NSObject>

@optional

- (void)managerDidRecvGetMessageReq:(GetMessageFromWXReq *)request;

- (void)managerDidRecvShowMessageReq:(ShowMessageFromWXReq *)request;

- (void)managerDidRecvLaunchFromWXReq:(LaunchFromWXReq *)request;

- (void)managerDidRecvMessageResponse:(SendMessageToWXResp *)response;

- (void)managerDidRecvAuthResponse:(SendAuthResp *)response;

- (void)managerDidRecvAddCardResponse:(AddCardToWXCardPackageResp *)response;


@end

/**
 *  支付宝和微信只付的管理类
 */

@interface BDPayManager : NSObject<WXApiDelegate>

/**
 支付宝使用
 
 后台传输的支付信息类 包含所有的订单信息
 2016-10-20新增   张明勋
 */
@property (nonatomic, strong) NSString *payInfo;


/**  支付宝从APPdelegate类回调过来的支付结果 */
@property (nonatomic, copy) BDAlipayBlock alipayBlock;

/**
 微信支付使用
 
 后台传输的支付信息类 包含所有的订单信息
 2016-10-20新增   张明勋
 
 */
@property (nonatomic, strong) NSDictionary *payInfoDict;



@property (nonatomic, assign) id<WXApiManagerDelegate> delegate;


/**  订单号*/
@property (nonatomic, strong) NSString *BDShop_order_No;


/** 支付宝秘钥 */
@property (nonatomic, copy) NSString *privateKey;

/**  订单名称 标题 */
@property (nonatomic, strong) NSString *BDShop_Title;
/**  商品描述*/
@property (nonatomic, strong) NSString *BDShop_productDescription;

/**  商品价格  单位为元*/
@property (nonatomic, assign) float BDShop_order_Price;

/**    支付宝异步回调网址   */
@property (nonatomic, strong) NSString *BDAliPaynotifyURL;
/**    微信异步回调网址   */
@property (nonatomic, strong) NSString *BDWeiXinPaynotifyURL;

/**   */
@property (nonatomic, strong) NSMutableDictionary *requstData;

/**
 *  支付管理类 单利
 *
 *  @return
 */
+(instancetype)sharedBDPayManager;

/**
 *  调起支付宝支付
 */
- (void)BD_Alipay;


- (void)BOD_Alipay_PayInfo;


/**
 *  支付宝支付的结果
 *
 *  @param aliPayPayResult 结果说明 枚举值
 */
- (void)BDAliPayPayResult:(BDAliPayPayResylt)aliPayPayResult;

/**
 *  调起微信支付
 */
-(void)BD_WXPay_Pay;

-(void)BOD_WXPay_PayInfo;

/**
 *  微信结果回调
 *
 *  @param weixinSucceed 成功
 *  @param weixinFailure 失败
 */
- (void)weixinPayResultSucceed:(weixinPaySucceed)weixinSucceed failure:(weixinPayFailure)weixinFailure;




@end
