//
//  SUN_PayManager.m
//  YRYBAPP
//
//  Created by apple on 16/9/5.
//  Copyright © 2016年 sunqishuang. All rights reserved.
//

#import "SUN_PayManager.h"
#import "BDPayManager.h"




@interface SUN_PayManager ()<WXApiManagerDelegate>{

  BDPayManager *_manager;
    
}



@end
SUN_PayManager *_defaultManager;

@implementation SUN_PayManager

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)defalltManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _defaultManager = [[SUN_PayManager alloc] init];
        
       
    });
    
    return _defaultManager;
}

+ (id)alloc{
    @synchronized(self) {
        if (!_defaultManager) {
            _defaultManager = [super alloc];
        }
    }
    return _defaultManager;
}


- (instancetype)init{
    if ([super init]) {
        _manager = [BDPayManager sharedBDPayManager];
        _manager.delegate = self;
    }
    
    return self;
}

- (void)payStart{
//    if (_orderNO == nil && _tn == nil) {
//        [Tools showErrorHUDViewAtView:APP_WINDOW WithTitle:@"无效订单"];
//        return;
//    }
    _manager.BDShop_order_No = _orderNO;
    _manager.BDShop_order_Price = _price.floatValue;
    _manager.BDShop_Title = _title;
    _manager.BDShop_productDescription = @"慢点";
    _manager.delegate = self;
    
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    if (_channel == SUNPAYWAYALIPAY) {
    // /////////////////               支付宝// /////////////////  // /////////////////  //
    /////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////
        _manager.BDShop_order_No = _orderNO;
      
        _manager.privateKey = _privateKey;
        _manager.requstData = _requstData;
        [_manager BDAliPayPayResult:^(BDAlipayResult AlipayResylt) {
            if (AlipayResylt == BDAlipaySucceed) {
                //                         支付成功
//                LMLog(@"支付宝支付成功");
                if (_resultBlock) {
                    _resultBlock(PayResultSuccess);
                }
            }else{
                //                        失败
//                LMLog(@"支付宝支付失败");
                if (_resultBlock) {
                    _resultBlock(PayResultFail);
                }
            }
        }];
        
        ///////////////////////////////////////////
//        _manager.payInfo = self.payInfo;//////  后台传的订单信息,已经加密签名好的
        ///////////////////////////////////////////
        ////////////////////////////////////////////////////////////////////////
//        [_manager BD_Alipay]; ///调用前端 签名加密的支付方式///////////////////////
        ////////////////////////////////////////////////////////////////////////
        
        [_manager BD_Alipay];
        
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    else if (_channel == SUNPAYWAYWECHAT){
    /////////////                微信
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////
        _manager.BDWeiXinPaynotifyURL = _notifyURL;//微信支付异步通知
//        BDLog(@"%@",_manager.BDWeiXinPaynotifyURL);
     //////////////////////////////////////////////////
     //////////////////////////////////////////////////
        _manager.payInfoDict = self.payInfoDict;   ////////
                                              ////////
    //////////////////////////////////////////////////
        
        
        [_manager weixinPayResultSucceed:^(int code) {
            //                    微信支付成功
            if (_resultBlock) {
                _resultBlock(PayResultSuccess);
            }
         
        } failure:^(int code) {
            //                     微信支付失败
            if (_resultBlock) {
                _resultBlock(PayResultFail);
            }
        }];
        
        _manager.payInfoDict = self.payInfoDict;

        ///////////////////////////////////////////////////////////
//        [_manager BD_WXPay_Pay];   ///微信前端签名加密支付方式///////
        //////////////////////////////////////////////////////////
                                            //////////////////////
        [_manager BOD_WXPay_PayInfo];        //////////////////////
                                            /////////////////////
        /////////////////////////////////////////////////////////
  
        
        
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    else{
    //////////                银联
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////
//        if (_tn != nil && _tn.length > 0) {
//            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UPMPResult:) name:@"UPMPResult" object:nil];
//            
//            [[UPPaymentControl defaultControl] startPay:_tn fromScheme:@"UPMPBDYRYSJBAPP" mode:@"00" viewController:_viewController];
//            
//        }
    }
}

#pragma mark ========   银联支付结果

- (void)UPMPResult:(NSNotification *)notify{
    NSString *result = notify.object;
    
    NSLog(@"result === %@",result);
    if ([result isEqualToString:@"success"]) {
        //        支付成功
//        [APP_WINDOW showHUDWithText:@"支付成功" Type:ShowPhotoYes Enabled:YES];
        if (_resultBlock) {
            _resultBlock(PayResultSuccess);
        }
    }else{
        //        用户取消
//        [APP_WINDOW showHUDWithText:@"取消支付" Type:ShowPhotoNo Enabled:YES];
        if (_resultBlock) {
            _resultBlock(PayResultFail);
        }
    }
}


@end
