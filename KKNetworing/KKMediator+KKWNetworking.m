//
//  KKMediator+KKWNetworking.m
//  KKWNetworking
//
//  Created by Tony on 2018/8/30.
//  Copyright © 2018年 KK. All rights reserved.
//

#import "KKMediator+KKWNetworking.h"
@implementation KKMediator (KKWNetworking)


+ (void)get:(NSString *)url param:(NSDictionary *)param relativeUser:(BOOL)relativeUser success:(void(^)(id respectObj))success failure:(void(^)(NSError *error))failure{
    [KKWNetworking get:url param:param relativeUser:relativeUser success:success failure:failure];
}

/**
 post请求
 
 @param url 请求url
 @param param 请求参数
 @param relativeUser 请求url是否带user/ 即：用户相关
 @param success <#success description#>
 @param failure <#failure description#>
 */
+ (void)post:(NSString *)url param:(NSDictionary *)param relativeUser:(BOOL)relativeUser success:(void(^)(id respectObj))success failure:(void(^)(NSError *error))failure{
    [KKWNetworking post:url param:param relativeUser:relativeUser success:success failure:failure];
}

/**
 带返回block的post请求(success带返回参数)
 
 @param url 请求url
 @param param 请求参数
 @param relativeUser 请求url是否带user/ 即：用户相关
 @param sucess <#sucess description#>
 @param failure <#failure description#>
 @param block <#block description#>
 */
+ (void)post:(NSString *)url param:(NSDictionary *)param relativeUser:(BOOL)relativeUser success:(void (^)(id repectObj))sucess failure:(void (^)(NSError *error))failure block:(void(^)(id<AFMultipartFormData> formData))block{
    [KKWNetworking post:url param:param relativeUser:relativeUser success:sucess failure:failure block:block];
}

+ (void)delete:(NSString *)url param:(NSDictionary *)param relativeUser:(BOOL)relativeUser success:(void(^)(id respectObj))success failure:(void(^)(NSError *error))failure{
    [KKWNetworking delete:url param:param relativeUser:relativeUser success:success failure:failure];
}

/**
 更新操作
 
 @param url <#url description#>
 @param param <#param description#>
 @param relativeUser <#relativeUser description#>
 @param success <#success description#>
 @param failure <#failure description#>
 */
+ (void)put:(NSString *)url param:(NSDictionary *)param relativeUser:(BOOL)relativeUser success:(void(^)(id respectObj))success failure:(void(^)(NSError *error))failure{
    [KKWNetworking put:url param:param relativeUser:relativeUser success:success failure:failure];
}

/**
 * 获取网络状况
 */
+(void)getNetworkConditionWithBlock:(void (^)(AFNetworkReachabilityStatus status))statusBlock{
    [KKWNetworking getNetworkConditionWithBlock:statusBlock];
}

/*
 *1 获取以太坊余额  address  以太坊地址
 *module = account  action = balance tag=latest  apikey=YourApiKeyToken
 *address 传入地址
 *2 获取代币余额接口  contractaddress  合约地址   address  以太坊地址
 *module = account  action = tokenbalance tag=latest  apikey=YourApiKeyToken
 *address 传入地址
 *https://api.etherscan.io/api?module=account&action=balance&address=0xddbd2b932c763ba5b1b7ae3b362eac3e8d40121a&tag=latest&apikey=YourApiKeyToken
 */
+(void)getEthereumBalanceWithParameters:(NSDictionary *)parameters success:(void(^)(id respectObj))success failure:(void(^)(NSError *error))failure{
    [KKWNetworking getEthereumBalanceWithParameters:parameters success:success failure:failure];
}

/*
 *获取当前地址的全部转币记录
 */
//http://api.etherscan.io/api?module=account&action=txlist&address=0xB44a5F97425A54aeB44baCF674d999694F891759&startblock=0&endblock=99999999&sort=asc&apikey=YourApiKeyToken&offset=1&page=1

+(void)getDealWithParameters:(NSDictionary *)parameters success:(void(^)(id respectObj))success failure:(void(^)(NSError *error))failure{
    [KKWNetworking getDealWithParameters:parameters success:success failure:failure];
}

/*
 *通过hash值检查这次交易的状态   成功还是失败
 */
//https://api.etherscan.io/api?module=transaction&action=gettxreceiptstatus&txhash=0x513c1ba0bebf66436b5fed86ab668452b7805593c05073eb2d51d3a52f480a76&apikey=YourApiKeyToken
/*
 *获取代币余额接口
 *contractaddress  合约地址
 *address  以太坊地址
 */

+ (BOOL)checkShouldReLoginForError:(NSDictionary *)userInfo url:(NSString *)url{
    return [KKWNetworking checkShouldReLoginForError:userInfo url:url];
}

/*
 *获取比特币余额
 */
//https://blockexplorer.com/api/addr/181mp8kYPgSMcDD9BffuJFhUPauPZkGip4/balance
+(void)getBTCBalanceWithAddress:(NSString *)address success:(void(^)(id respectObj))success failure:(void(^)(NSError *error))failure{
    [KKWNetworking getBTCBalanceWithAddress:address success:success failure:failure];
}


/**
 *blockexplorer.com接口
 *address btc地址
 */
//https://blockexplorer.com/api/txs/?address=1JrnrMWNpcfMjXDzSMH9RsXSuagnt1x64u
+(void)getBTCDealWithParameters:(NSDictionary *)parameters success:(void(^)(id respectObj))success failure:(void(^)(NSError *error))failure{
    [KKWNetworking getBTCDealWithParameters:parameters success:success failure:failure];
}

/**
 *blockexplorer.com接口
 *获取UTXO
 */
//https://blockexplorer.com/api/addrs/2NF2baYuJAkCKo5onjUKEPdARQkZ6SYyKd5,2NAre8sX2povnjy4aeiHKeEh97Qhn97tB1f/utxo
+(void)getBTCUTXOWithPaarameters:(NSArray *)parameters success:(void(^)(id respectObj))success failure:(void(^)(NSError *error))failure{
    [KKWNetworking getBTCUTXOWithPaarameters:parameters success:success failure:failure];
}

/*
 *上传图片
 */
+ (void)upLoadImageFilesSafe:(NSString *)url param:(NSDictionary *)param imageArr:(NSArray *)imageArr header:(NSDictionary *)header index:(NSInteger)index relativeUser:(BOOL)relativeUser success:(void(^)(id respectObj))success failure:(void(^)(NSError *error))failure{
    [KKWNetworking upLoadImageFilesSafe:url param:param imageArr:imageArr header:header index:index relativeUser:relativeUser success:success failure:failure];
}


+ (void)getLoginTokenAndSaveWithAddressKey:(NSString *)userName success:(void(^)(id respectObj))success failure:(void(^)(NSError *error))failure{
    [KKWNetworking getLoginTokenAndSaveWithAddressKey:userName success:success failure:failure];
}
@end
