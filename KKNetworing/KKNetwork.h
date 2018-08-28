//
//  KKNetwork.h
//  KKNetworing
//
//  Created by Tony on 2018/8/28.
//  Copyright © 2018年 KK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import <SocketIO/SocketIO-Swift.h>
#import "SVProgressHUD.h"

@interface KKPlatformHttpSessionManager:AFHTTPSessionManager

@end

@interface KKNetwork : NSObject
//钱包后台
@property (nonatomic,strong) AFHTTPSessionManager *manager;

//平台用户
@property (nonatomic, strong) KKPlatformHttpSessionManager *platformManager;

//websocket
@property (nonatomic, strong) SocketManager *socketManager;

/*
 *通过baseUrl初始化
 */
+ (instancetype)initWithBaseUrl:(NSString *)baseUrl;

+ (instancetype)shareInstance;

+ (BOOL)userHasLogin;
/**
 get请求
 
 @param url 请求url
 @param param 请求参数
 @param relativeUser 请求url是否带user/ 即：用户相关
 @param success <#success description#>
 @param failure <#failure description#>
 */
+ (void)get:(NSString *)url param:(NSDictionary *)param relativeUser:(BOOL)relativeUser success:(void(^)(id respectObj))success failure:(void(^)(NSError *error))failure;

/**
 post请求
 
 @param url 请求url
 @param param 请求参数
 @param relativeUser 请求url是否带user/ 即：用户相关
 @param success <#success description#>
 @param failure <#failure description#>
 */
+ (void)post:(NSString *)url param:(NSDictionary *)param relativeUser:(BOOL)relativeUser success:(void(^)(id respectObj))success failure:(void(^)(NSError *error))failure;

/**
 带返回block的post请求(success带返回参数)
 
 @param url 请求url
 @param param 请求参数
 @param relativeUser 请求url是否带user/ 即：用户相关
 @param sucess <#sucess description#>
 @param failure <#failure description#>
 @param block <#block description#>
 */
+ (void)post:(NSString *)url param:(NSDictionary *)param relativeUser:(BOOL)relativeUser success:(void (^)(id repectObj))sucess failure:(void (^)(NSError *error))failure block:(void(^)(id<AFMultipartFormData> formData))block;

+ (void)delete:(NSString *)url param:(NSDictionary *)param relativeUser:(BOOL)relativeUser success:(void(^)(id respectObj))success failure:(void(^)(NSError *error))failure;

/**
 更新操作
 
 @param url <#url description#>
 @param param <#param description#>
 @param relativeUser <#relativeUser description#>
 @param success <#success description#>
 @param failure <#failure description#>
 */
+ (void)put:(NSString *)url param:(NSDictionary *)param relativeUser:(BOOL)relativeUser success:(void(^)(id respectObj))success failure:(void(^)(NSError *error))failure;
/**
 * 获取网络状况
 */
+(void)getNetworkConditionWithBlock:(void (^)(AFNetworkReachabilityStatus status))statusBlock;

/*
 *1 获取以太坊余额  address  以太坊地址
 *module = account  action = balance tag=latest  apikey=YourApiKeyToken
 *address 传入地址
 *2 获取代币余额接口  contractaddress  合约地址   address  以太坊地址
 *module = account  action = tokenbalance tag=latest  apikey=YourApiKeyToken
 *address 传入地址
 *https://api.etherscan.io/api?module=account&action=balance&address=0xddbd2b932c763ba5b1b7ae3b362eac3e8d40121a&tag=latest&apikey=YourApiKeyToken
 */
+(void)getEthereumBalanceWithParameters:(NSDictionary *)parameters success:(void(^)(id respectObj))success failure:(void(^)(NSError *error))failure;

/*
 *获取当前地址的全部转币记录
 */
//http://api.etherscan.io/api?module=account&action=txlist&address=0xB44a5F97425A54aeB44baCF674d999694F891759&startblock=0&endblock=99999999&sort=asc&apikey=YourApiKeyToken&offset=1&page=1

+(void)getDealWithParameters:(NSDictionary *)parameters success:(void(^)(id respectObj))success failure:(void(^)(NSError *error))failure;

/*
 *通过hash值检查这次交易的状态   成功还是失败
 */
//https://api.etherscan.io/api?module=transaction&action=gettxreceiptstatus&txhash=0x513c1ba0bebf66436b5fed86ab668452b7805593c05073eb2d51d3a52f480a76&apikey=YourApiKeyToken
/*
 *获取代币余额接口
 *contractaddress  合约地址
 *address  以太坊地址
 */

+ (BOOL)checkShouldReLoginForError:(NSDictionary *)userInfo url:(NSString *)url;

/*
 *获取比特币余额
 */
//https://blockexplorer.com/api/addr/181mp8kYPgSMcDD9BffuJFhUPauPZkGip4/balance
+(void)getBTCBalanceWithAddress:(NSString *)address success:(void(^)(id respectObj))success failure:(void(^)(NSError *error))failure;


/**
 *blockexplorer.com接口
 *address btc地址
 */
//https://blockexplorer.com/api/txs/?address=1JrnrMWNpcfMjXDzSMH9RsXSuagnt1x64u
+(void)getBTCDealWithParameters:(NSDictionary *)parameters success:(void(^)(id respectObj))success failure:(void(^)(NSError *error))failure;

/**
 *blockexplorer.com接口
 *获取UTXO
 */
//https://blockexplorer.com/api/addrs/2NF2baYuJAkCKo5onjUKEPdARQkZ6SYyKd5,2NAre8sX2povnjy4aeiHKeEh97Qhn97tB1f/utxo
+(void)getBTCUTXOWithPaarameters:(NSArray *)parameters success:(void(^)(id respectObj))success failure:(void(^)(NSError *error))failure;

/**
 *接口功能: 获取认证信息
 *请求地址: /api/v1/account/security
 *请求方式: GET
 *注意: 请求首部 Authorization 需要携带登录接口返回的token
 */
+(void)getSecurityWithSuccess:(void(^)(id respectObj))success failure:(void(^)(NSError *error))failure;

/**
 get请求
 
 @param url 请求url
 @param param 请求参数
 */
+ (void)getSafe:(NSString *)url param:(NSDictionary *)param success:(void(^)(id respectObj))success failure:(void(^)(NSError *error))failure;


+ (void)putSafe:(NSString *)url param:(NSDictionary *)param success:(void(^)(id respectObj))success failure:(void(^)(NSError *error))failure;

+ (void)postSafe:(NSString *)url param:(NSDictionary *)param success:(void(^)(id respectObj))success failure:(void(^)(NSError *error))failure;

+ (void)deleteSafe:(NSString *)url param:(NSDictionary *)param success:(void(^)(id respectObj))success failure:(void(^)(NSError *error))failure;
/*
 *上传图片
 */
+ (void)upLoadImageFilesSafe:(NSString *)url param:(NSDictionary *)param imageArr:(NSArray *)imageArr header:(NSDictionary *)header index:(NSInteger)index relativeUser:(BOOL)relativeUser success:(void(^)(id respectObj))success failure:(void(^)(NSError *error))failure;

/*
 *重置密码
 */
+ (void)resetPwd:(NSString *)url param:(NSDictionary *)param token:(NSString *)token success:(void(^)(id respectObj))success failure:(void(^)(NSError *error))failure;


+ (void)getLoginTokenAndSaveWithAddressKey:(NSString *)userName success:(void(^)(id respectObj))success failure:(void(^)(NSError *error))failure;
@end
