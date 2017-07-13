//
//  VPInterfaceController.m
//  VideoPlsInterfaceViewSDK
//
//  Created by Zard1096 on 2017/6/25.
//  Copyright © 2017年 videopls. All rights reserved.
//

#import "VPInterfaceController.h"

#define VP_USE_VIDEOOS  0
#define VP_USE_LIVEOOS  0

#ifdef VP_VIDEOOS
#import <VideoPlsCytronSDK/VPCytronView.h>
#undef VP_USE_VIDEOOS
#define VP_USE_VIDEOOS 1
#endif

#ifdef VP_LIVEOS
#import <VideoPlsLiveSDK/LDSDKIVAView.h>
#undef VP_USE_LIVEOOS
#define VP_USE_LIVEOOS 1
#endif

@interface VPInterfaceController()

@property (nonatomic) id interfaceView;

#ifdef VP_VIDEOOS
@property (nonatomic) VPCytronView *cytronView;
#endif

#ifdef VP_LIVEOS
@property (nonatomic) LDSDKIVAView *liveView;
#endif

@end

@implementation VPInterfaceController {
    BOOL _canSet;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (void)startVideoPls {
#if defined VP_VIDEOOS
    [VPCytronView startVideoPls];
#elif defined VP_LIVEOS
    [LDSDKIVAView startVideoPls];
#endif
}

+ (void)stopVideoPls {
#if defined VP_VIDEOOS
    [VPCytronView stopVideoPls];
#elif defined VP_LIVEOS
    [LDSDKIVAView stopVideoPls];
#endif
}

#pragma mark init method
- (instancetype)initWithFrame:(CGRect)frame
              videoIdentifier:(NSString *)identifier
                       isLive:(BOOL)isLive {
    self = [super init];
    if(self) {
        _canSet = YES;
        [self initViewWithFrame:frame
                videoIdentifier:identifier
                         isLive:isLive];
    }
    return self;
}

#ifdef VP_VIDEOOS
#pragma mark VideoOS init
//默认isLive为No
- (instancetype)initVideoOSViewWithFrame:(CGRect)frame
                         videoIdentifier:(NSString *)identifier
                              videoTitle:(NSString *)videoTitle {
    NSAssert(identifier, @"VideoIdentifier不能为空");
    self = [self initWithFrame:frame videoIdentifier:identifier isLive:NO];
    if(self) {
        [self setVideoTitle:videoTitle];
    }
    return self;
}
#endif

#ifdef VP_LIVEOS
#pragma mark LiveOS init
//默认isLive为YES
- (instancetype)initLiveOSViewWithFrame:(CGRect)frame
                        videoIdentifier:(NSString *)identifier
                         platformUserID:(NSString *)platformUserID {
    NSAssert(platformUserID, @"PlatformUserID不能为空");
    self = [self initWithFrame:frame videoIdentifier:identifier isLive:YES];
    if(self) {
        [self setPlatformUserID:_platformUserID];
    }
    return self;
}
#endif

- (void)initViewWithFrame:(CGRect)frame
          videoIdentifier:(NSString *)identifier
                   isLive:(BOOL)isLive {
    NSAssert(VP_USE_VIDEOOS || VP_USE_LIVEOOS, @"VideoOS和LiveOS都没有被使用");
    
    _videoIdentifier = identifier;
    _live = isLive;
    
    if((!isLive && VP_USE_VIDEOOS) || !VP_USE_LIVEOOS) {
        //TODO: 新建VideoOS层
        [self initVideoOSViewWithFrame:frame];
    }
    else if((isLive && VP_USE_LIVEOOS) || !VP_USE_VIDEOOS) {
        //TODO: 新建LiveOS层
        [self initLiveOSViewWithFrame:frame];
    }
}

- (void)initVideoOSViewWithFrame:(CGRect)frame {
#ifdef VP_VIDEOOS
    NSAssert(_videoIdentifier, @"VideoIdentifier不能为空");
    _cytronView = [[VPCytronView alloc] initWithFrame:frame videoIdentifier:_videoIdentifier];
    [_cytronView setLive:_live];
    [_cytronView setVideoType:VPCVideoTypeSource];
    
    _view = _cytronView;
#endif
}

- (void)initLiveOSViewWithFrame:(CGRect)frame {
#ifdef VP_LIVEOS
    _liveView = [[LDSDKIVAView alloc] initWithFrame:frame Url:_videoIdentifier VideoType:1 isLive:_live];
    
    _view = _liveView;
#endif
}

#pragma mark set method
- (void)setVideoIdentifier:(NSString *)videoIdentifier {
    if(![self validateSetAttribute]) {
        return;
    }
#ifdef VP_VIDEOOS
    if(_cytronView) {
        [_cytronView setVideoIdentifier:videoIdentifier];
    }
#endif
#ifdef VP_LIVEOS
    if(_liveView) {
        [_liveView setUrl:videoIdentifier];
    }
#endif
}

- (void)setVideoType:(NSInteger)videoType {
    if(![self validateSetAttribute]) {
        return;
    }
#ifdef VP_VIDEOOS
    if(_cytronView) {
        [_cytronView setVideoType:videoType];
    }
#endif
#ifdef VP_LIVEOS
    if(_liveView) {
        [_liveView setVideoType:videoType];
    }
#endif
}

- (void)setLive:(BOOL)isLive {
    if(![self validateSetAttribute]) {
        return;
    }
    
    _live = isLive;
#ifdef VP_VIDEOOS
    if(_cytronView) {
        [_cytronView setLive:isLive];
    }
#endif
#ifdef VP_LIVEOS
    if(_liveView) {
        [_liveView setIsLive:isLive];
    }
#endif
}

#ifdef VP_VIDEOOS
#pragma mark VideoOS set method
- (void)setVideoTitle:(NSString *)videoTitle {
    _videoTitle = videoTitle;
    [_cytronView setVideoTitle:videoTitle];
}
#endif

#ifdef VP_LIVEOS
#pragma mark LiveOS set method
- (void)setPlatformUserID:(NSString *)platformUserID {
    NSAssert(platformUserID, @"PlatformUserID不能为空");
    _platformUserID = platformUserID;
    [_liveView setPlatformUserID:platformUserID];
}
#endif

- (BOOL)validateSetAttribute {
    if(!_canSet) {
        //TODO: already start loading, could not set
        
        return NO;
    }
    
    if(!_view) {
        //TODO: Assert use wrong init method
        
        return NO;
    }
    
    return YES;
}

#pragma mark Interface loading and control
- (void)startLoading {
    NSAssert(_view, @"使用错误的init方法, view不存在");
    
    [self registerStatusNotification];
#ifdef VP_VIDEOOS
    if(_cytronView) {
        [_cytronView startLoading];
    }
#endif

#ifdef VP_LIVEOS
    if(_liveView) {
        //TODO: Assert use wrong init method
        [_liveView startLoading];
    }
#endif
}

#ifdef VP_VIDEOOS
- (void)updateCurrentPlaybackTime:(NSTimeInterval)milliSecond {
    if(_cytronView) {
        [_cytronView updateCurrentPlaybackTime:milliSecond];
    }
}

- (void)closeAllInfoLayer {
    if(_cytronView) {
        [_cytronView closeAllInfoLayer];
    }
}
#endif

- (void)updateFrame:(CGRect)frame videoRect:(CGRect)videoRect isFullScreen:(BOOL)isFullScreen {
#ifdef VP_VIDEOOS
    if(_cytronView) {
        [_cytronView updateFrame:frame videoRect:videoRect isFullScreen:isFullScreen];
    }
#endif
    
#ifdef VP_LIVEOS
    if(_liveView) {
        [_liveView updateFrame:frame videoRect:videoRect isFullScreen:isFullScreen];
    }
#endif
}

- (void)stop {
    
#ifdef VP_VIDEOOS
    if(_cytronView) {
        [_cytronView stop];
    }
#endif
    
#ifdef VP_LIVEOS
    if(_liveView) {
        [_liveView stop];
    }
#endif
    
    [self unregisterStatusNotification];
}


#pragma mark Notification
- (void)registerStatusNotification {
#ifdef VP_VIDEOOS
    if(_cytronView) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webViewOpen:) name:VPCytronMyAppWebLinkDidOpenNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interfaceLoadComplete:) name:VPCytronLoadCompleteNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interfaceLoadError:) name:VPCytronViewLoadErrorNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interfaceItemShow:) name:VPCytronViewNodeStateNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interfaceViewChangeStatus:) name:VPCytronViewNodeStateNotification object:nil];
    }
#endif
    
#ifdef VP_LIVEOS
    if(_liveView) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webViewOpen:) name:LDSDKMyAppLinkDidOpenNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interfaceLoadComplete:) name:LDSDKIVAViewLoadCompleteNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interfaceLoadError:) name:LDSDKIVAViewLoadErrorNotification object:nil];
    }
#endif
}

- (void)unregisterStatusNotification {
#ifdef VP_VIDEOOS
    if(_cytronView) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:VPCytronMyAppWebLinkDidOpenNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:VPCytronLoadCompleteNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:VPCytronViewLoadErrorNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:VPCytronViewNodeStateNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:VPCytronViewNodeStateNotification object:nil];
    }
#endif
    
#ifdef VP_LIVEOS
    if(_liveView) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:LDSDKMyAppLinkDidOpenNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:LDSDKIVAViewLoadCompleteNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:LDSDKIVAViewLoadErrorNotification object:nil];
    }
#endif
}

- (void)webViewOpen:(NSNotification *)sender {
    if(self.delegate) {
        if([self.delegate respondsToSelector:@selector(vp_webLinkOpenWithURL:)]) {
            NSDictionary *userInfo = sender.userInfo;
            if([userInfo objectForKey:@"LinkUrl"]) {
                NSString *url = [userInfo objectForKey:@"LinkUrl"];
                [self.delegate vp_webLinkOpenWithURL:url];
            }
        }
    }
}

- (void)interfaceLoadComplete:(NSNotification *)sender {
    if(self.delegate) {
        if([self.delegate respondsToSelector:@selector(vp_interfaceLoadComplete:)]) {
#ifdef VP_VIDEOOS
            if(_cytronView) {
                NSDictionary *userInfo = sender.userInfo;
                [self.delegate vp_interfaceLoadComplete:userInfo];
            }
#endif
#ifdef VP_LIVEOS
            if(_liveView) {
                [self.delegate vp_interfaceLoadComplete:nil];
            }
#endif      
        }
    }
}

- (void)interfaceLoadError:(NSNotification *)sender {
    if(self.delegate) {
        if([self.delegate respondsToSelector:@selector(vp_interfaceLoadError:)]) {
            NSDictionary *userInfo = sender.userInfo;
            if([userInfo objectForKey:@"ErrorState"]) {
                NSInteger errorState = [[userInfo objectForKey:@"ErrorState"] integerValue];
                NSString *errorString = nil;
                
                //详见 VPCytronViewLoadErrorState 和 LDSDKIVAViewLoadErrorState ,两者一致
                switch (errorState) {
                    case 0:
                        //已经不常见
                        errorString = @"错误的地址";
                        break;
                    case 1:
                        //已经不常见
                        errorString = @"错误的地址格式或为本地文件";
                        break;
                    case 2:
                        //可能由于本地网络不稳定,也有可能服务器网络不稳定
                        errorString = @"连接服务器出错";
                        break;
                    case 3:
                        //连接超时
                        errorString = @"网络连接超时";
                        break;
                    case 4:
                        //
                        errorString = @"无效AppKey";
                        break;
                    case 5:
                        //
                        errorString = @"Appkey与bundleID不匹配";
                        break;
                    case 6:
                        //
                        errorString = @"网络连接取消";
                        break;
                    default:
                        errorString = @"未知错误";
                        break;
                }
                
                [self.delegate vp_interfaceLoadError:errorString];
            }
        }
    }
}

#ifdef VP_VIDEOOS
- (void)interfaceItemShow:(NSNotification *)sender {
    if(self.delegate) {
        if([self.delegate respondsToSelector:@selector(vp_interfaceCytronItemShow:)]) {
            NSDictionary *userInfo = sender.userInfo;
            if([userInfo objectForKey:@"CytronNodeType"]) {
                VPCytronViewNodeType itemType = [[userInfo objectForKey:@"CytronNodeType"] integerValue];
                /*
                NSString *itemTypeString = nil;
                
                switch (itemType) {
                    case VPCytronViewNodeTag:
                        itemTypeString = @"热点";
                        break;
                    case VPCytronViewNodeInfoLayer:
                        itemTypeString = @"信息层";
                        break;
                    default:
                        itemTypeString = @"未知";
                        break;
                }
                */
                [self.delegate vp_interfaceCytronItemShow:itemType];
            }
        }
    }
}

- (void)interfaceViewChangeStatus:(NSNotification *)sender {
    if(self.delegate) {
        if([self.delegate respondsToSelector:@selector(vp_interfaceViewChangeStatus:)]) {
            NSDictionary *userInfo = sender.userInfo;
            if([userInfo objectForKey:@"CytronNodeState"]) {
                VPCytronViewNodeState itemStatus = [[userInfo objectForKey:@"CytronNodeState"] integerValue];

                [self.delegate vp_interfaceViewChangeStatus:itemStatus];
            }
        }
    }
}

#endif


@end
