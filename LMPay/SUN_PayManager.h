//
//  SUN_PayManager.h
//  YRYBAPP
//
//  Created by apple on 16/9/5.
//  Copyright © 2016年 sunqishuang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    SUNPAYWAYALIPAY = 1,
    SUNPAYWAYWECHAT = 2,
    SUNPAYWAYUPMP = 3,
}SUNPAYWAY;

typedef enum {
    PayResultSuccess = 1,
    PayResultFail = 2,
}PayResult;

typedef void(^payBlock)(PayResult  result);


@interface SUN_PayManager : NSObject

/** 订单号  */
@property (nonatomic, copy) NSString * orderNO;
/**  订单价格 */
@property (nonatomic, copy) NSString * price;

/**   */
@property (nonatomic, strong) NSMutableDictionary *requstData;

/** 支付宝支付秘钥 */
@property (nonatomic, copy) NSString *privateKey;
/**  支付方式 */
@property (nonatomic, assign) SUNPAYWAY  channel;
/**  购买的商品名 */
@property (nonatomic, copy) NSString * title;
/**  银联支付时的TN号 */
@property (nonatomic, copy) NSString * tn;

/** 支付结果回调  */
@property (nonatomic, copy) payBlock resultBlock;

/**  当前控制器 */
@property (nonatomic, strong) UIViewController *viewController;


/** 异步回调网址 */
@property (nonatomic, copy) NSString *notifyURL;

/**
 
 支付宝的支付信息
 
 后台传输的支付信息类 包含所有的订单信息  
 2016-10-20新增   张明勋
 */
@property (nonatomic, strong) NSString *payInfo;

/**
 微信的支付信息
 
 后台传输的支付信息类 包含所有的订单信息
 2016-10-20新增   张明勋
 */
@property (nonatomic, strong) NSDictionary  *payInfoDict;


+ (instancetype)defalltManager;


- (void)payStart;

@end
