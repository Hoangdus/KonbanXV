#import "KonbanSpringboard.h"
#import "Konban.h"
//#import <AppList/AppList.h>

@interface UIScene ()
-(id)_identifier;
@end

HBPreferences *preferences;
BOOL dpkgInvalid = false;
BOOL visible = NO;
BOOL enabled;
BOOL enabledCoverSheet;
BOOL enabledHomeScreen;
BOOL hideStatusBar;
BOOL useInNC = true;
CGFloat scale = 0.8;
CGFloat cornerRadius = 16;
NSString *bundleID = @"com.miro.uyou";
// UIViewController *ourVC = nil;

CGRect insetByPercent(CGRect f, CGFloat s) {
    CGFloat originScale = (1.0 - s)/2.0;
    return CGRectMake(f.origin.x + f.size.width * originScale, f.origin.y + f.size.height * originScale, f.size.width * s, f.size.height * s);
}

// @interface SBHomeScreenViewController : UIViewController
// @end

// %hook SBHomeScreenViewController

//     -(void)viewWillAppear:(BOOL)arg1{
//       %orig();
//       if (enabled){

//           //Loading View
//           // UIActivityIndicatorView *LoadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//           // LoadingView.frame = self.view.frame;
//           // LoadingView.hidesWhenStopped = YES;
//           // LoadingView.transform = CGAffineTransformMakeScale(scale, scale);
//           // LoadingView.alpha = 0.5;
//           // LoadingView.layer.cornerRadius = cornerRadius;
//           // [LoadingView setBackgroundColor:[UIColor grayColor]];
//           // [LoadingView startAnimating];
//           // [self.view addSubview:LoadingView];  

//           NSLog(@"[Konban] %@", bundleID);
//           @try {
//             [Konban launch:bundleID];
//             UIView *testAppView = [Konban viewFor:bundleID]; //prevent crashes by putting it in a try-catch block. While the app is loading, the FBSceneLayer will return nil, which will cause a crash.
//             testAppView.frame = self.view.frame;
//             testAppView.transform = CGAffineTransformMakeScale(scale, scale);
//             [self.view addSubview:testAppView];   
//           }
//           @catch (NSException *exception){
//             if (exception) {
//               // %log(@"konView ERROR:%@", exception);
//               UIActivityIndicatorView *LoadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//               LoadingView.frame = self.view.frame;
//               LoadingView.hidesWhenStopped = YES;
//               LoadingView.transform = CGAffineTransformMakeScale(scale, scale);
//               LoadingView.alpha = 0.5;
//               LoadingView.layer.cornerRadius = cornerRadius;
//               [LoadingView setBackgroundColor:[UIColor grayColor]];
//               [LoadingView startAnimating];
//               [self.view addSubview:LoadingView];  
//             }
//           }
 
//       }
//     }

// %end

%hook SBTodayViewController

%property (nonatomic, retain) UIView *konHostView;
%property (nonatomic, retain) UIActivityIndicatorView *konSpinnerView;

-(void)viewWillAppear:(bool)arg1 {
    %orig;

    SBLockStateAggregator *lockStateAggregator = [%c(SBLockStateAggregator) sharedInstance];
     if ((MSHookIvar<NSUInteger>(lockStateAggregator, "_lockState") != 0 || self.view.tag == 5)) {
       if (!useInNC && MSHookIvar<NSUInteger>(lockStateAggregator, "_lockState") == 1) {
         for (UIView *view in [self.view subviews]) {
           view.hidden = NO;
         }
        return;
      }
    }
    else if (!enabled) return;

    if (enabled && self.konHostView){
      self.konHostView.frame = insetByPercent(self.view.frame, scale);
      self.konHostView.transform = CGAffineTransformMakeScale(scale, scale);
      [Konban rehost:bundleID];
      NSLog(@"[Konban] %s", "konHostView exists");
      NSLog(@"[Konban] rehosting!");
      return;
    }

    if (enabled) {
        for (UIView *view in [self.view subviews]) {
            view.hidden = YES;
        }

        [self.konSpinnerView stopAnimating];
        [self.konSpinnerView removeFromSuperview];
        [self.konHostView removeFromSuperview];

        if (!self.konSpinnerView) self.konSpinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.konSpinnerView.hidesWhenStopped = YES;
        self.konSpinnerView.frame = self.view.frame;
        [self.view addSubview:self.konSpinnerView];
        [self.konSpinnerView startAnimating];

        // visible = YES;
        NSLog(@"[Konban] %@", bundleID);

        @try {
        [Konban launch:bundleID];
        self.konHostView = [Konban viewFor:bundleID]; //prevent crashes by putting it in a try-catch block. While the app is loading, the FBSceneLayer will return nil, which will cause a crash.
        [self.konSpinnerView stopAnimating];
        }
        @catch (NSException *exception){
          if (exception) {
            %log(@"konView ERROR:%@", exception);
          }
        }
        %log(@"[konban] konHostView: %@", self.konHostView);
        self.konHostView.backgroundColor = [UIColor whiteColor];//safari fix
        self.konHostView.alpha = 1;
        self.konHostView.frame = self.view.frame;
        self.konHostView.transform = CGAffineTransformMakeScale(scale, scale);
        self.konHostView.layer.cornerRadius = cornerRadius;
        self.konHostView.layer.masksToBounds = true;
        [self.view addSubview:self.konHostView];
        [self.view bringSubviewToFront:self.konHostView];
        self.konHostView.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
          self.konHostView.alpha = 1;
        }];

        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)@"me.nepeta.konban/StatusBarHide", nil, nil, true);

        if (!self.konHostView) { // loop through these steps until the application is launched and our view is returned.
            [self.konSpinnerView startAnimating];
            [self.view bringSubviewToFront:self.konSpinnerView];
            [self performSelector:@selector(viewWillAppear:) withObject:nil afterDelay:0.5];
        }
    } else {
        for (UIView *view in [self.view subviews]) {
            view.hidden = NO;
        }

        if (self.konHostView) {
            [self.konHostView removeFromSuperview];
            [Konban dehost:bundleID];
            self.konHostView = nil;
        }
    }
}

-(void)viewDidDisappear:(bool)arg1 {
    %orig;
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)@"me.nepeta.konban/StatusBarShow", nil, nil, true);

    // visible = NO;
    if (!self.konHostView) return;
    // [self.konHostView removeFromSuperview];
    [Konban dehost:bundleID];
    self.konHostView = nil;
}

%end

/*void changeApp() {
    NSMutableDictionary *appList = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/me.nepeta.konban-app.plist"];
    if (!appList) return;

    if ([appList objectForKey:@"App"]) {
        bundleID = [appList objectForKey:@"App"];
    }
}*/

%ctor{
    preferences = [[HBPreferences alloc] initWithIdentifier:@"me.nepeta.konban"];
    [preferences registerBool:&enabled default:YES forKey:@"Enabled"];
    [preferences registerFloat:&cornerRadius default:16 forKey:@"CornerRadius"];
    [preferences registerFloat:&scale default:0.8 forKey:@"Scale"];
    [preferences registerBool:&hideStatusBar default:YES forKey:@"HideStatusBar"];
    [preferences registerBool:&useInNC default:YES forKey:@"useInNotificationCenter"];
    /*dpkgInvalid = ![[NSFileManager defaultManager] fileExistsAtPath:@"/var/lib/dpkg/info/com.nicho1asdev.konban.list"];

    if (dpkgInvalid) %init(dpkgInvalid);*/

    if (!enabled) return;

    /*changeApp();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)changeApp, (CFStringRef)@"me.nepeta.konban/ReloadApp", NULL, (CFNotificationSuspensionBehavior)kNilOptions);*/
}
