/*
 
 Copyright 2010 www.adview.cn. All rights reserved.
 
 */

#import "AdViewAdapterImmob.h"
#import "AdViewViewImpl.h"
#import "AdViewAdNetworkAdapter+Helpers.h"
#import "AdViewAdNetworkConfig.h"
#import "AdViewAdNetworkRegistry.h"
#import "AdViewLog.h"
#import "AdViewView.h"
#import "SingletonAdapterBase.h"
#import "AdviewObjCollector.h"

#define LMMOB_CHANNEL_KEY		@"channelID"
#define LMMOB_VIEW_CLASS_NAME	@"immobView"


@interface AdViewAdapterImmob()

- (void)updateAdFrame:(UIView*)view;
- (UIView*)createAdView;

@end

@implementation AdViewAdapterImmob

+ (AdViewAdNetworkType) networkType {
    return AdViewAdNetworkTypeImmob;
}

+ (void) load
{
    if (NSClassFromString(LMMOB_VIEW_CLASS_NAME)){
        //AWLogInfo(@"AdView: Found LMMob AdNetwork");
        [[AdViewAdNetworkRegistry sharedRegistry] registerClass:self];
    }
}

- (void) getAd
{
    Class lmmob_view_class = NSClassFromString(LMMOB_VIEW_CLASS_NAME);
	if (nil == lmmob_view_class) {
		AWLogInfo(@"no lmmob sdk, can not show.");
		[adViewView adapter:self didFailAd:nil];
		return;
	}
	
    immobView* lmmob_view = (immobView*)[self createAdView];
	if (nil == lmmob_view) {
		[adViewView adapter:self didFailAd:nil];
		return;
	}
	
    self.adNetworkView = lmmob_view;
	self.bWaitAd = YES;
	[lmmob_view immobViewRequest];
	[lmmob_view release];
}

- (void) stopBeingDelegate
{
	AWLogInfo(@"--LMMOB stopBeingDelegate--");
    immobView* lmmob_view = (immobView*)self.adNetworkView;

    [lmmob_view performSelector:@selector(setDelegate:) withObject:nil];
	
	//maybe need wait release in AdviewObjCollector.
	if (self.bWaitAd && nil != lmmob_view) {
		[[AdviewObjCollector sharedCollector] addObj:lmmob_view];
	}
	
	//[lmmob_view removeFromSuperview];
	self.adNetworkView = nil;
}

- (void)updateSizeParameter {
	BOOL isIPad = [AdViewAdNetworkAdapter helperIsIpad];
	
	AdviewBannerSize	sizeId = AdviewBannerSize_Auto;
	if ([adViewDelegate respondsToSelector:@selector(PreferBannerSize)]) {
		sizeId = [adViewDelegate PreferBannerSize];
	}
	
	if (sizeId > AdviewBannerSize_Auto) {
		switch (sizeId) {
			case AdviewBannerSize_320x50:
				self.nSizeAd = 0;
				break;
			case AdviewBannerSize_300x250:
				self.nSizeAd = 0;
				break;
			case AdviewBannerSize_480x60:
				self.nSizeAd = 0;
				break;
			case AdviewBannerSize_728x90:
				self.nSizeAd = 0;
				break;
			default:
				break;
		}
	} else if (isIPad) {
		self.nSizeAd = 0;
	} else {
		self.nSizeAd = 0;
	}
}

- (void) dealloc
{
    [super dealloc];
}

- (void)updateAdFrame:(UIView*)view {
	//can not set, it will be set by lmmod sdk.
//    CGRect r = CGRectMake(0.0f, 0.0f, 320.0f, 50.0f);
//    view.frame = r;	
}

- (UIView*)createAdView {
    NSString *appIdString = self.networkConfig.pubId;
    AWLogInfo(@"LMMob: application id: %@", appIdString);
    
    Class lmmob_view_class = NSClassFromString(LMMOB_VIEW_CLASS_NAME);
    immobView* lmmob_view = [[lmmob_view_class alloc] initWithAdUnitID:appIdString];
	if (nil == lmmob_view) {
		return nil;
	}
	
	AWLogInfo(@"lmmob view:%u", lmmob_view);
	self.adNetworkView = lmmob_view;
	
    [lmmob_view performSelector:@selector(setDelegate:) withObject:self];
	[lmmob_view.UserAttribute setObject:@"adview" forKey:LMMOB_CHANNEL_KEY];

    [self updateAdFrame:lmmob_view];
	return lmmob_view;
}

#pragma mark immobViewDelegate

- (UIViewController *)immobViewController {
	if ([self.adViewDelegate respondsToSelector:@selector(viewControllerForPresentingModalView)])
		return [self.adViewDelegate viewControllerForPresentingModalView];
	return nil;
}

- (void) immobViewDidReceiveAd {
	AWLogInfo(@"immobViewDidReceiveAd");
	self.bWaitAd = NO;
	
	[self updateAdFrame:self.adNetworkView];
    [self.adViewView adapter:self didReceiveAdView:self.adNetworkView];
	[(immobView*)self.adNetworkView immobViewDisplay];
}

- (void) immobView: (immobView*) immobView didFailReceiveimmobViewWithError: (NSInteger) errorCode
{
	AWLogInfo(@"immobView fail, code:%d", errorCode);
	self.bWaitAd = NO;
	
	[self.adViewView adapter:self didFailAd:nil];
}

- (void) onPresentScreen:(immobView *)immobView
{
	AWLogInfo(@"immobViewDelegate onPresentScreen");
    //[self helperNotifyDelegateOfFullScreenModal];
}

- (void) onDismissScreen:(immobView *)immobView
{
	AWLogInfo(@"immobViewDelegate onDismissScreen");
    //[self helperNotifyDelegateOfFullScreenModalDismissal];
}

@end
