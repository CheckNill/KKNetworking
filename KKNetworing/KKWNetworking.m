//
//  KKWNetworking.m
//  KKNetworing
//
//  Created by Tony on 2018/8/28.
//  Copyright © 2018年 KK. All rights reserved.
//

#import "KKWNetworking.h"


#pragma mark - Notification Keys
const NSString* KKLoginPlatformFailNotification = @"KKLoginPlatformFailNotification";

#define relativeUserToken @"relativeUserToken"
#define Authorization @"Authorization"
#define UserHasLogin @"userHasLogin"


#define showNetMessage(type,msg) \
{void(^runOnMainThead)(void) = ^{\
if(type == 0)[SVProgressHUD dismiss];\
else if(type == 1)[SVProgressHUD showWithStatus:msg]; \
else if(type == 2)[SVProgressHUD showSuccessWithStatus:msg];\
else [SVProgressHUD showErrorWithStatus:msg];};\
if ( [NSThread isMainThread] )runOnMainThead();\
else dispatch_async( dispatch_get_main_queue(), runOnMainThead );}

#define KKNet_STR(key, comment) NSLocalizedStringFromTable(key, @"KKWNetworkinging", comment)




typedef enum : NSUInteger {
    showTypeNetNone = 0,
    showTypeNetStatus,
    showTypeNetSuccess,
    showTypeNetError
} showTypeNet;

static KKWNetworking *network = nil;
static NSString *KKBase_URL = @"";
static NSString *KKBase_Safe = @"";
static NSString *APP_SECRET = @"";
static NSString *APPID = @"";



@implementation KKPlatformHttpSessionManager

+ (KKPlatformHttpSessionManager *)sessionManager{
    static dispatch_once_t onceToken;
    static KKPlatformHttpSessionManager *sessionManager = nil;
    dispatch_once(&onceToken, ^{
        if(!sessionManager){
            sessionManager = [[KKPlatformHttpSessionManager alloc] initWithBaseURL:[NSURL URLWithString:KKBase_Safe]];
            sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
            sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
            sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json", @"text/json", @"text/plain", nil];
//            [sessionManager.requestSerializer setValue:KKAppInfoManager.sharedInstance.platAccessToken forHTTPHeaderField:Authorization];
        }
    });
    
    [sessionManager resetLocal];
    
    return sessionManager;
}

- (void)resetLocal{
    NSString *locale = @"en-US,en;q=0.5";
    NSString *localeId = [NSLocale currentLocale].localeIdentifier;
    if([localeId hasPrefix:@"zh"]){
        locale = @"zh-CN,zh;q=0.9";
    }
    [self.requestSerializer setValue:locale forHTTPHeaderField:@"Accept-Language"];
}

@end

@interface KKWNetworking ()

@property (nonatomic, strong) NSMutableDictionary <NSString *,NSNumber *>*requestUrls;

@end

@implementation KKWNetworking



+(instancetype)initWithBaseUrl:(NSString *)baseUrl{//有baseurl初始化
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(!network){
            network = [[KKWNetworking alloc]init];
            //手机钱包后台
            network.manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrl]];
            [network.manager.requestSerializer willChangeValueForKey:@"timeoutinterval"];
            [network.manager.requestSerializer didChangeValueForKey:@"timeoutinterval"];
            network.manager.responseSerializer = [AFJSONResponseSerializer serializer];
            network.manager.requestSerializer = [AFJSONRequestSerializer serializer];
            network.manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json", @"text/json", @"text/plain", nil];
            [network.manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            KKBase_URL = baseUrl;
            //交易所
            network.platformManager = [KKPlatformHttpSessionManager sessionManager];
        }
    });
    return network;
}

+ (instancetype)shareInstance{//无初始化   可以直接使用
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(!network){
            network = [[KKWNetworking alloc]init];
            //手机钱包后台
            network.manager = [[AFHTTPSessionManager alloc] init];
            [network.manager.requestSerializer willChangeValueForKey:@"timeoutinterval"];
            [network.manager.requestSerializer didChangeValueForKey:@"timeoutinterval"];
            network.manager.responseSerializer = [AFJSONResponseSerializer serializer];
            network.manager.requestSerializer = [AFJSONRequestSerializer serializer];
            network.manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json", @"text/json", @"text/plain", nil];
            [network.manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            
            //交易所
            network.platformManager = [KKPlatformHttpSessionManager sessionManager];
            
        }
    });
    return network;
}

+ (NSString *)reLoginPrefix{
    return @"401";
}

- (NSMutableDictionary <NSString *,NSNumber *>*)requestUrls{
    if(!_requestUrls){
        _requestUrls = [NSMutableDictionary new];
    }
    return _requestUrls;
}

+ (BOOL)checkShouldReLoginForError:(NSDictionary *)userInfo url:(NSString *)url{
    
    BOOL ex = [url containsString:[NSString stringWithFormat:@"%@currency_exchange_rates",KKBase_URL]];
    BOOL random = [url containsString:[NSString stringWithFormat:@"%@random_string?device_id=",KKBase_URL]];
    BOOL version = [url isEqualToString:[NSString stringWithFormat:@"%@version",KKBase_URL]];
    BOOL cy = [url containsString:[NSString stringWithFormat:@"%@cryptocurrencies",KKBase_URL]];
    BOOL cy2curt =  [url containsString:[NSString stringWithFormat:@"%@cryptocurrency",KKBase_URL]];
    if(ex || random || version || cy || cy2curt){
        return NO;
    }
    
    if([[userInfo[@"code"] stringValue] hasPrefix:[self reLoginPrefix]]){
//        [[NSNotificationCenter defaultCenter] postNotificationName:KKLoginWalletFailedNotification object:nil];
//        [[KKAppInfoManager sharedInstance] clearUserInfo];
    }
    return YES;
}
/// FIXME：钱包登录才用这个判断，暂时放桶
+ (BOOL)userHasLogin{
//    if(![[KKAppInfoManager sharedInstance] userHasLogin]){
//        [[NSNotificationCenter defaultCenter] postNotificationName:KKLoginWalletFailedNotification object:nil];
//        return NO;
//    }
    return YES;
}

+ (void)get:(NSString *)url param:(NSDictionary *)param relativeUser:(BOOL)relativeUser  success:(void(^)(id respectObj))success failure:(void(^)(NSError *error))failure{
    
    AFHTTPSessionManager *session = [KKWNetworking shareInstance].manager;
//    NSString *token = [KKAppInfoManager getTokenWithType:relativeUser];
    NSString *token = relativeUserToken;
    //传token
    if(relativeUser){
        if(![self userHasLogin]){
            return;
        }
        [[KKWNetworking shareInstance].manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", token] forHTTPHeaderField:Authorization];
    }else{
        [[KKWNetworking shareInstance].manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", token] forHTTPHeaderField:Authorization];
    }//Authorization
    [session GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([responseObject isKindOfClass:[NSDictionary class]] && [responseObject[@"code"] integerValue] == 0){
            if(success){
                success(responseObject);
            }
        }else {
            if([responseObject isKindOfClass:[NSDictionary class]] && [[responseObject[@"code"] stringValue] hasPrefix:[self reLoginPrefix]] ){
                
                BOOL relog =  [self checkShouldReLoginForError:responseObject url:task.response.URL.absoluteString];
                if (!relog) {
                    // 不需重登录，但要新获取接口2.1的token
                    [KKWNetworking getLoginTokenAndSaveWithAddressKey:nil success:nil failure:nil];
                }else{
                    if(failure){
                        failure([NSError errorWithDomain:responseObject[@"message"] code:[responseObject[@"code"] integerValue] userInfo:nil]);
                    }
                }
            }else{
                if(failure){
                    failure([NSError errorWithDomain:responseObject[@"message"] code:[responseObject[@"code"] integerValue] userInfo:nil]);
                }
            }
        }
        NSLog(@"get ok1");
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSData *data = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        if(data){
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if(url && [url hasSuffix:@"application/version?client_type=1"]){
                
            }else{
                NSInteger statusCode = 0;
                if([task.response isKindOfClass:[NSHTTPURLResponse class]]){
                    NSHTTPURLResponse *res = (NSHTTPURLResponse *)task.response;
                    statusCode = res.statusCode;
                }
                //用户相关且返回code需要重新登录
                BOOL relog = ([self checkShouldReLoginForError:dic url:task.response.URL.absoluteString] || statusCode == 401) && relativeUser == YES;
                if (!relog) {
                    // 不需重登录，但要新获取接口2.1的token
                    [KKWNetworking getLoginTokenAndSaveWithAddressKey:nil success:nil failure:nil];
                }else{
                    [KKWNetworking showErrorMessageWithDic:error.userInfo url:url];//get
                    showNetMessage(showTypeNetError, @"");
                }
            }
        }
        if(failure){
            failure(error);
            NSData *data = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
            if(!data)return;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSLog(@"\n\nerror occur: \n\nrequest url is : %@\n\n errMsg:%@\n\n",url,dic[@"message"]);
        }
        NSLog(@"not get ok2");
    }];
}

+(void)showErrorMessageWithDic:(NSDictionary *)dictionary url:(NSString *)url
{
    NSData *data = dictionary[AFNetworkingOperationFailingURLResponseDataErrorKey];
    if(data){
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSString *msg = dic[@"message"];
        [self showErr:msg];
        NSLog(@"error occured %@ url: %@",msg,url);
    }
}

+ (void)showErr:(NSString *)errorStr{
    if(!errorStr)return;
    NSRange range = [errorStr rangeOfString:@"oken"];
    if (range.location != NSNotFound) {
        errorStr = KKNet_STR(@"请重新输入密码", nil);
    }
    showNetMessage(showTypeNetError, errorStr);
}

/**测试ok,post请求*/
+ (void)post:(NSString *)url param:(NSDictionary *)param relativeUser:(BOOL)relativeUser success:(void(^)(id respectObj))success failure:(void(^)(NSError *error))failure{
//    NSString *token = [KKAppInfoManager getTokenWithType:relativeUser];
    NSString *token = relativeUserToken;

    if(relativeUser){
        if(![self userHasLogin]){
            return;
        }
        [[KKWNetworking shareInstance].manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", token] forHTTPHeaderField:Authorization];
    }else{
        if(token.length != 0){
            [[KKWNetworking shareInstance].manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", token] forHTTPHeaderField:Authorization];
        }
    }
    
    [[KKWNetworking shareInstance].manager POST:url parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([responseObject isKindOfClass:[NSDictionary class]] && [responseObject[@"code"] integerValue] == 0){
            if(success){
                success(responseObject);
            }
        }else {
            if([responseObject isKindOfClass:[NSDictionary class]] && [[responseObject[@"code"] stringValue] hasPrefix:[self reLoginPrefix]]){
                BOOL relog = [self checkShouldReLoginForError:responseObject url:task.response.URL.absoluteString];
                if (!relog) {
                    // 不需重登录，但要新获取接口2.1的token
                    [KKWNetworking getLoginTokenAndSaveWithAddressKey:nil success:nil failure:nil];
                }
            }else{
                if(failure){
                    failure([NSError errorWithDomain:responseObject[@"message"] code:[responseObject[@"code"] integerValue] userInfo:nil]);
                }
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSData *data = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        if(data){
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            BOOL relog = [self checkShouldReLoginForError:dic url:task.response.URL.absoluteString];
            if (!relog) {
                // 不需重登录，但要新获取接口2.1的token
                [KKWNetworking getLoginTokenAndSaveWithAddressKey:nil success:nil failure:nil];
            }else{
                [KKWNetworking showErrorMessageWithDic:error.userInfo url:url];//post
            }
        }
        if(failure){
            failure(error);
        }
    }];
    
}

// 带返回block的post请求(success带返回参数)
+ (void)post:(NSString *)url param:(NSDictionary *)param relativeUser:(BOOL)relativeUser success:(void (^)(id repectObj))sucess failure:(void (^)(NSError *error))failure block:(void(^)(id<AFMultipartFormData> formData))block{
//    NSString *token = [KKAppInfoManager getTokenWithType:relativeUser];
    NSString *token = relativeUserToken;

    if(relativeUser){
        if(![self userHasLogin]){
            return;
        }
        
        [[KKWNetworking shareInstance].manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", token] forHTTPHeaderField:Authorization];
    }else{
        
        [[KKWNetworking shareInstance].manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", token] forHTTPHeaderField:Authorization];
    }
    NSLog(@"request url is : %@",url);
    
    [[KKWNetworking shareInstance].manager POST:url parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        if(block){
            block(formData);
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([responseObject isKindOfClass:[NSDictionary class]] && [responseObject[@"code"] integerValue] == 0){
            if(sucess){
                sucess(responseObject);
            }
        }else {
            if([responseObject isKindOfClass:[NSDictionary class]] && [responseObject[@"code"] hasPrefix:[self reLoginPrefix]]){
                BOOL relog = [self checkShouldReLoginForError:responseObject url:task.response.URL.absoluteString];
                if (!relog) {
                    // 不需重登录，但要新获取接口2.1的token
                    [KKWNetworking getLoginTokenAndSaveWithAddressKey:nil success:nil failure:nil];
                }
            }else{
                if(failure){
                    failure([NSError errorWithDomain:responseObject[@"message"] code:[responseObject[@"code"] integerValue] userInfo:nil]);
                }
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSData *data = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        if(data){
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            BOOL relog = [self checkShouldReLoginForError:dic url:task.response.URL.absoluteString];
            if (!relog) {
                // 不需重登录，但要新获取接口2.1的token
                [KKWNetworking getLoginTokenAndSaveWithAddressKey:nil success:nil failure:nil];
            }
        }
        if(failure){
            failure(error);
        }
    }];
    
}

+ (void)delete:(NSString *)url param:(NSDictionary *)param relativeUser:(BOOL)relativeUser success:(void(^)(id respectObj))success failure:(void(^)(NSError *error))failure{
    
//    NSString *token = [KKAppInfoManager getTokenWithType:relativeUser];
    NSString *token = relativeUserToken;

    
    if(relativeUser){
        if(![self userHasLogin]){
            return;
        }
        [[KKWNetworking shareInstance].manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", token] forHTTPHeaderField:Authorization];
    }else{
        [[KKWNetworking shareInstance].manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", token] forHTTPHeaderField:Authorization];
    }
    
    NSLog(@"request url is : %@",url);
    [KKWNetworking.shareInstance.manager DELETE:url parameters:param success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([responseObject isKindOfClass:[NSDictionary class]] && [responseObject[@"code"] integerValue] == 0){
            if(success){
                success(responseObject);
            }
        }else {
            if([responseObject isKindOfClass:[NSDictionary class]] && [[responseObject[@"code"] stringValue] hasPrefix:[self reLoginPrefix]]){
                BOOL relog =  [self checkShouldReLoginForError:responseObject url:task.response.URL.absoluteString];
                if (!relog) {
                    // 不需重登录，但要新获取接口2.1的token
                    [KKWNetworking getLoginTokenAndSaveWithAddressKey:nil success:nil failure:nil];
                }
            }else{
                if(failure){
                    failure([NSError errorWithDomain:responseObject[@"message"] code:[responseObject[@"code"] integerValue] userInfo:nil]);
                }
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSData *data = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        if(data){
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            BOOL relog = [self checkShouldReLoginForError:dic url:task.response.URL.absoluteString];
            if (!relog) {
                // 不需重登录，但要新获取接口2.1的token
                [KKWNetworking getLoginTokenAndSaveWithAddressKey:nil success:nil failure:nil];
            }
        }
        if(failure){
            failure(error);
        }
    }];
}

+ (void)put:(NSString *)url param:(NSDictionary *)param relativeUser:(BOOL)relativeUser success:(void(^)(id respectObj))success failure:(void(^)(NSError *error))failure{
    
//    NSString *token = [KKAppInfoManager getTokenWithType:relativeUser];
    NSString *token = relativeUserToken;

    if(relativeUser){
        if(![self userHasLogin]){
            return;
        }
        
        [[KKWNetworking shareInstance].manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", token] forHTTPHeaderField:Authorization];
    }else{
        
        [[KKWNetworking shareInstance].manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", token] forHTTPHeaderField:Authorization];
    }
    
    NSLog(@"request url is : %@",url);
    [[KKWNetworking shareInstance].manager PUT:url parameters:param success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([responseObject isKindOfClass:[NSDictionary class]] && [responseObject[@"code"] integerValue] == 0){
            if(success){
                success(responseObject);
            }
        }else {
            if([responseObject isKindOfClass:[NSDictionary class]] && [responseObject[@"code"] hasPrefix:[self reLoginPrefix]]){
                BOOL relog = [self checkShouldReLoginForError:responseObject url:task.response.URL.absoluteString];
                if (!relog) {
                    // 不需重登录，但要新获取接口2.1的token
                    [KKWNetworking getLoginTokenAndSaveWithAddressKey:nil success:nil failure:nil];
                }
            }else{
                if(failure){
                    failure([NSError errorWithDomain:responseObject[@"message"] code:[responseObject[@"code"] integerValue] userInfo:nil]);
                }
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSData *data = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        if(data){
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            BOOL relog = [self checkShouldReLoginForError:dic url:task.response.URL.absoluteString];
            if (!relog) {
                // 不需重登录，但要新获取接口2.1的token
                [KKWNetworking getLoginTokenAndSaveWithAddressKey:nil success:nil failure:nil];
            }
        }
        if(failure){
            failure(error);
        }
        
    }];
    
}

//设置证书
- (void)setSecerityCertificater{
    __weak typeof(self) weakSelf = self;
    [_manager setSessionDidReceiveAuthenticationChallengeBlock:^NSURLSessionAuthChallengeDisposition(NSURLSession *session, NSURLAuthenticationChallenge *challenge, NSURLCredential *__autoreleasing *_credential) {
        
        SecTrustRef serverTrust = [[challenge protectionSpace] serverTrust];
        /**
         *  导入多张CA证书
         */
        // FIXME: 0125 需要处理证书名字和位置
        NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"zbc" ofType:@"cer"];//自签名证书
        
        
        NSData* caCert = [NSData dataWithContentsOfFile:cerPath];
        //        NSArray *cerArray = @[caCert];
        NSSet *cerArray = [[NSSet alloc]initWithObjects:caCert, nil];
        weakSelf.manager.securityPolicy.pinnedCertificates = cerArray;
        
        SecCertificateRef caRef = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)caCert);
        NSCAssert(caRef != nil, @"caRef is nil");
        
        NSArray *caArray = @[(__bridge id)(caRef)];
        NSCAssert(caArray != nil, @"caArray is nil");
        
        OSStatus status = SecTrustSetAnchorCertificates(serverTrust, (__bridge CFArrayRef)caArray);
        SecTrustSetAnchorCertificatesOnly(serverTrust,NO);
        NSCAssert(errSecSuccess == status, @"SecTrustSetAnchorCertificates failed");
        
        NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
        __autoreleasing NSURLCredential *credential = nil;
        if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
            if ([weakSelf.manager.securityPolicy evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:challenge.protectionSpace.host]) {
                credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
                if (credential) {
                    disposition = NSURLSessionAuthChallengeUseCredential;
                } else {
                    disposition = NSURLSessionAuthChallengePerformDefaultHandling;
                }
            } else {
                disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
            }
        } else {
            disposition = NSURLSessionAuthChallengePerformDefaultHandling;
        }
        return disposition;
    }];
    
}

/**
 * 获取网络状况
 */
+(void)getNetworkConditionWithBlock:(void (^)(AFNetworkReachabilityStatus status))statusBlock{
    
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager startMonitoring];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (statusBlock) {
            statusBlock(status);
            
        }
    }];
}

/*
 *1 获取以太坊余额  address  以太坊地址
 *module = account  action = balance tag=latest  apikey=YourApiKeyToken
 *address 传入地址
 *2 获取代币余额接口  contractaddress  合约地址   address  以太坊地址
 *module = account  action = tokenbalance tag=latest  apikey=YourApiKeyToken
 *address 传入地址
 */
//https://api.etherscan.io/api?module=account&action=balance&address=0xB44a5F97425A54aeB44baCF674d999694F891759&tag=latest&apikey=YourApiKeyToken
//https://api.etherscan.io/api

+(void)getEthereumBalanceWithParameters:(NSDictionary *)parameters success:(void(^)(id respectObj))success failure:(void(^)(NSError *error))failure{
    [KKWNetworking.shareInstance.manager GET:@"http://api.etherscan.io/api" parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
        //放到外面解析
        //NSDictionary *data = [responseObject objectForKey:@"data"];
        //self.randomStr = [data objectForKey:@"random_string"];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if(failure) failure(error);
    }];
    
}

/*
 *获取当前地址的全部转币记录
 *module=account  action=txlist   sort=asc   apikey=YourApiKeyToken
 *address 地址
 *startblock 开始区块高度
 *endblock 结束区块高度
 *可不传参数 page 页数   offset  最多返回数据的条数
 *现在默认获取全部
 */
//http://api.etherscan.io/api?module=account&action=txlist&address=0xB44a5F97425A54aeB44baCF674d999694F891759&startblock=0&endblock=99999999&sort=asc&apikey=YourApiKeyToken&offset=1&page=1

+(void)getDealWithParameters:(NSDictionary *)parameters success:(void(^)(id respectObj))success failure:(void(^)(NSError *error))failure{
    
    //    [[KKWNetworking shareInstance].manager.requestSerializer setValue:@"" forHTTPHeaderField:Authorization];
    [KKWNetworking.shareInstance.manager GET:@"http://api.etherscan.io/api" parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
        //放到外面解析
        //NSDictionary *data = [responseObject objectForKey:@"data"];
        //self.randomStr = [data objectForKey:@"random_string"];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [KKWNetworking showErrorMessageWithDic:error.userInfo url:@"http://api.etherscan.io/api"];//get
        if(failure){
            failure(error);
        }
    }];
}



/*
 *获取比特币余额  未使用
 */
//https://blockexplorer.com/api/addr/181mp8kYPgSMcDD9BffuJFhUPauPZkGip4/balance
+(void)getBTCBalanceWithAddress:(NSString *)address success:(void(^)(id respectObj))success failure:(void(^)(NSError *error))failure{
    NSString *urlAdress = [NSString stringWithFormat:@"http://blockexplorer.com/api/addr/%@/balance",address];
    
    NSURL *url = [NSURL URLWithString:urlAdress];
    //返回的不是json，af报错。。。
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        NSString *balance = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        if (!connectionError && success) {
            success(balance);
        }else{
            NSLog(@"网路链接错误 connectionError响应：response：%@",connectionError);
        }
    }];
    
}

/**
 *blockexplorer.com接口
 *address btc地址
 */
//https://blockexplorer.com/api/txs/?address=1JrnrMWNpcfMjXDzSMH9RsXSuagnt1x64u    但地址查询，只有10条数据
//https://blockexplorer.com/api/addrs/2NF2baYuJAkCKo5onjUKEPdARQkZ6SYyKd5,2NAre8sX2povnjy4aeiHKeEh97Qhn97tB1f/txs?from=0&to=20。多地址查询好像最多50条
+(void)getBTCDealWithParameters:(NSDictionary *)parameters success:(void(^)(id respectObj))success failure:(void(^)(NSError *error))failure{
        NSString *url =[NSString stringWithFormat:@"http://blockexplorer.com/api/addrs/%@/txs?from=0&to=50",parameters[@"address"]];
    //    url = [NSString stringWithFormat:@"http://192.168.8.55:8889/api/v1/txs?address=1BW18n7MfpU35q4MTBSk8pse3XzQF8XvzT&limit=10&order=-1&prevminkey=&prevmaxkey"];
//    NSString *url = [NSString stringWithFormat:@"%@%@%@",TestDomainPort54_8889,Api_v1,Session_get_btc_record(parameters[@"address"],10,-1)];
    //    NSString *url = [NSString stringWithFormat:@"http://192.168.8.54:8889/api/v1/txs?address=%@&limit=10&order=-1&prevminkey=&prevmaxkey",parameters[@"address"]];
    [KKWNetworking.shareInstance.manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //    [KKWNetworking.shareInstance.manager GET:@"https://blockexplorer.com/api/txs/" parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [KKWNetworking showErrorMessageWithDic:error.userInfo url:@"https://blockexplorer.com/api"];//get
        if(failure){
            failure(error);
        }
    }];
}

/**
 *blockexplorer.com接口
 *获取UTXO
 */
//https://blockexplorer.com/api/addrs/2NF2baYuJAkCKo5onjUKEPdARQkZ6SYyKd5,2NAre8sX2povnjy4aeiHKeEh97Qhn97tB1f/utxo
+(void)getBTCUTXOWithPaarameters:(NSArray *)parameters success:(void(^)(id respectObj))success failure:(void(^)(NSError *error))failure{
//    NSString *url = [NSString stringWithFormat:@"%@%@%@",TestDomainPort54_8889,Api_v1,Session_get_btc_address];
        NSString *url = @"http://blockexplorer.com/api/addrs/";
    //    url = @"http://192.168.8.54:8889/api/v1/addr/";
    for (int i=0; i<parameters.count; i++) {
        if (i==parameters.count-1) {
            url = [NSString stringWithFormat:@"%@%@/utxo",url,parameters[i]];
        }else{
            url = [NSString stringWithFormat:@"%@%@,",url,parameters[i]];
        }
    }
    [KKWNetworking.shareInstance.manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [KKWNetworking showErrorMessageWithDic:error.userInfo url:@"https://blockexplorer.com/api"];//get
        if(failure){
            failure(error);
        }
    }];
}


/**
 *接口功能: 获取认证信息
 *请求地址: /api/v1/account/security
 *请求方式: GET
 *注意: 请求首部 Authorization 需要携带登录接口返回的token
 */
+(void)getSecurityWithSuccess:(void(^)(id respectObj))success failure:(void(^)(NSError *error))failure{
    [KKWNetworking getSafe:@"user/api/v1/account/security" param:nil success:^(id respectObj) {
        if (success) success(respectObj);
    } failure:^(NSError *error) {
        if (failure) failure(error);
    }];
}


+ (void)resetPwd:(NSString *)url param:(NSDictionary *)param token:(NSString *)token success:(void(^)(id respectObj))success failure:(void(^)(NSError *error))failure{
    NSLog(@"request url is : %@",url);
    
    [KKWNetworking.shareInstance.platformManager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", token] forHTTPHeaderField:Authorization];
    [KKWNetworking putSafe:url param:param success:^(id respectObj) {
        
        if(success){
            success(respectObj);
        }
    } failure:^(NSError *error) {
        if(failure){
            failure(error);
        }
    }];
}

+ (void)upLoadImageFilesSafe:(NSString *)url param:(NSDictionary *)param imageArr:(NSArray *)imageArr header:(NSDictionary *)header index:(NSInteger)index relativeUser:(BOOL)relativeUser success:(void(^)(id respectObj))success failure:(void(^)(NSError *error))failure{
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"PUT";
    NSData *data = imageArr[0];
    request.HTTPBody = data;
    [request setValue:[NSString stringWithFormat:@"%ld",data.length] forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"public-read" forHTTPHeaderField:@"x-amz-acl"];
    
    NSURLSession *sessionM = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [sessionM dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
            long statusCode = (long)[httpResponse statusCode];
            if (statusCode == 200) {//成功
                success(@"");
            }else{//失败
                failure(nil);
            }
        });
    }];
    //开始请求
    [task resume];
}

+ (void)getSafe:(NSString *)url param:(NSDictionary *)param success:(void(^)(id respectObj))success failure:(void(^)(NSError *error))failure{
    
    [KKWNetworking.shareInstance.platformManager GET:url parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"get ok");
        
        if([responseObject[@"statusCode"] intValue] == 0){
            if(success){
                success(responseObject);
            }
        }else {
            [self processErrorResponse:responseObject failure:failure url:url params:param];
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [self processPlatformError:error failure:failure url:url params:param];
        
        
    }];
}


+ (void)putSafe:(NSString *)url param:(NSDictionary *)param success:(void(^)(id respectObj))success failure:(void(^)(NSError *error))failure{
    
    NSLog(@"request url is : %@",url);
    
    [KKWNetworking.shareInstance.platformManager PUT:url parameters:param success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if([responseObject[@"statusCode"] intValue] == 0){
            if(success){
                success(responseObject);
            }
        }else {
            [self processErrorResponse:responseObject failure:failure url:url params:param];
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [self processPlatformError:error failure:failure url:url params:param];
        
    }];
}


+ (void)postSafe:(NSString *)url param:(NSDictionary *)param success:(void(^)(id respectObj))success failure:(void(^)(NSError *error))failure{
    
    NSLog(@"request url is : %@",url);
    
    [KKWNetworking.shareInstance.platformManager POST:url parameters:param progress:nil success:^(NSURLSessionDataTask *  _Nonnull task, id  _Nullable responseObject) {
        
        
        if([responseObject[@"statusCode"] intValue] == 0){
            if(success){
                success(responseObject);
            }
        }else {
            [self processErrorResponse:responseObject failure:failure url:url params:param];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [self processPlatformError:error failure:failure url:url params:param];
        
    }];
    
}

+ (void)deleteSafe:(NSString *)url param:(NSDictionary *)param success:(void(^)(id respectObj))success failure:(void(^)(NSError *error))failure{
    
    NSLog(@"request url is : %@",url);
    
    [KKWNetworking.shareInstance.platformManager DELETE:url parameters:param success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if([responseObject[@"statusCode"] intValue] == 0){
            if(success){
                success(responseObject);
            }
        }else {
            
            [self processErrorResponse:responseObject failure:failure url:url params:param];
            
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [self processPlatformError:error failure:failure url:url params:param];
        
    }];
}

+ (void)processErrorResponse:(id)errorResponse failure:(void(^)(NSError * _Nonnull error))failure url:(NSString *)url params:(NSDictionary *)params{
    
//    if(!errorResponse[@"message"]){
//        errorResponse.message = @"Unknown error", nil;
//    }
//    NSError *error = [NSError errorWithDomain:errorResponse.message code:errorResponse.statusCode userInfo:nil];
//
//    [self processPlatformError:error failure:failure url:url params:params];
    
}

+ (void)processPlatformError:(NSError *)error failure:(void(^)(NSError * _Nonnull error))failure url:(NSString *)url params:(NSDictionary *)params{
    
    NSString *errMsg = error.localizedDescription;
    
    NSString *errCode = nil;
    //1
    NSData *data = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
    if(data){
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if(dic[@"message"]){
            NSString *err = dic[@"message"];
            errMsg = err.length > 0 ? err:errMsg;
        }
        errCode = [dic[@"code"] stringValue];
    }
    //2
    NSHTTPURLResponse *errResponse = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
    if(!errResponse){
        
        NSError *underlineError = error.userInfo[@"NSUnderlyingError"];
        errResponse = underlineError.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
        errMsg = underlineError.userInfo[@"NSLocalizedDescription"];
    }else{
        if(errMsg.length == 0){
            NSString *err = [NSHTTPURLResponse localizedStringForStatusCode:errResponse.statusCode];
            errMsg = err.length > 0 ? err:errMsg;
        }
        if(![errCode hasPrefix:@"401"]){
            errCode = [NSString stringWithFormat:@"%ld",errResponse.statusCode];
        }
    }
    
    if(errMsg.length == 0){
        errMsg = error.domain;
    }
    
    if([errCode hasPrefix:@"50"]){
        errMsg = @"Service is unavailable  temporarily, please try again later";
    }
    
    NSError *errorInfo = [NSError errorWithDomain:errMsg code:[errCode integerValue]  userInfo:@{@"url":url?:@""}];
    
    if(failure){
        failure(errorInfo);
    }
    if([errCode isEqualToString:@"401001"] || [errCode isEqualToString:@"401002"]){
//        [[KKAppInfoManager sharedInstance] logoutPlatformWithCompletionAction:^{
//
//        }];
        NSNotification *notice = [NSNotification notificationWithName:KKLoginPlatformFailNotification object:errorInfo];
        [[NSNotificationCenter defaultCenter] postNotificationName:KKLoginPlatformFailNotification object:notice];
    }
}

+ (void)getLoginTokenAndSaveWithAddressKey:(NSString *)userName success:(void(^)(id respectObj))success failure:(void(^)(NSError *error))failure{
    
    NSDictionary *parameters = @{@"app_id":APPID,@"app_secret":APP_SECRET};
    [KKWNetworking post:@"application/login" param:parameters relativeUser:NO success:^(id respectObj) {
        if(success){
            NSDictionary *data = [respectObj objectForKey:@"data"];
            // warning:这里如果扩展多钱包,单键值不能满足要求了,要组合键值:和地址绑定关系
            //这里只返回了access_token
            NSString *accessToken = data[@"access_token"];
//            [KKAppInfoManager.sharedInstance updateAccessToken:accessToken];
            success(respectObj);
        }
    } failure:^(NSError *error) {
        NSLog(@"get token error == %@",error);
        if(failure){
            failure(error);
        }
    }];
}

@end

