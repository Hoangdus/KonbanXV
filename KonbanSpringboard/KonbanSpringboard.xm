#import "KonbanSpringboard.h"
#import "Konban.h"

HBPreferences *preferences;
BOOL dpkgInvalid = false;
BOOL visible = NO;
BOOL enabled;
BOOL enabledCoverSheet;
BOOL enabledHomeScreen;
BOOL hideStatusBar;
BOOL useInNC = false;
CGFloat scale = 0.8;
CGFloat cornerRadius = 16;
NSString *bundleID = @"com.apple.mobilesafari";
// UIViewController *ourVC = nil;

CGRect insetByPercent(CGRect f, CGFloat s) {
    CGFloat originScale = (1.0 - s)/2.0;
    return CGRectMake(f.origin.x + f.size.width * originScale, f.origin.y + f.size.height * originScale, f.size.width * s, f.size.height * s);
}

@implementation KonbanSpringboard

+(BOOL)isLocked{
    SBLockStateAggregator *lockStateAggregator = [%c(SBLockStateAggregator) sharedInstance];
    NSUInteger lockState = MSHookIvar<NSUInteger>(lockStateAggregator, "_lockState");
    if (lockState == 1) {
        return YES;
    }
    return NO;
}

@end

%hook SBTodayViewController

%property (nonatomic, retain) UIView *konHostView;
%property (nonatomic, retain) UIActivityIndicatorView *konSpinnerView;

-(void)viewDidAppear:(bool)arg1 {
    %orig;

    if(!enabled || ([KonbanSpringboard isLocked] && !useInNC)){
        for (UIView *view in [self.view subviews]) {
            if(view.hidden){
                view.hidden = NO;
            }
        }

        if(self.konSpinnerView){
            [(_UISceneLayerHostContainerView *)self.konHostView invalidate];
            [self.konHostView removeFromSuperview];
            self.konHostView = nil;
        }

        if(self.konSpinnerView){
            [self.konSpinnerView removeFromSuperview];  
            self.konSpinnerView = nil;
        }
        return;
    }

    for (UIView *view in [self.view subviews]) {
        view.hidden = YES;
    }

    if([[self.konHostView description] containsString: bundleID]){
        NSLog(@"[Konban] %s", "app hasn't been changed");
    }

    if (enabled && self.konHostView && [[self.konHostView description] containsString: bundleID]){
        NSLog(@"[Konban] %s", "konHostView exists");
        self.konHostView.transform = CGAffineTransformMakeScale(scale, scale);
        self.konHostView.layer.cornerRadius = cornerRadius;
        self.konHostView.hidden = NO;
        [self.view addSubview:self.konHostView];
        [Konban rehost:bundleID];
        return;
    }

    if (enabled) {
        [self.konSpinnerView stopAnimating];
        // [self.konSpinnerView removeFromSuperview];
        [self.konHostView removeFromSuperview];

        if (!self.konSpinnerView){
            self.konSpinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
            self.konSpinnerView.backgroundColor = [UIColor whiteColor];
            self.konSpinnerView.hidesWhenStopped = YES;
            self.konSpinnerView.frame = self.view.frame;
            self.konSpinnerView.transform = CGAffineTransformMakeScale(scale, scale);
            self.konSpinnerView.layer.cornerRadius = cornerRadius;
            self.konSpinnerView.layer.masksToBounds = true;
        }
        [self.view addSubview:self.konSpinnerView];
        [self.konSpinnerView startAnimating];

        // visible = YES;
        NSLog(@"[Konban] bundleID: %@", bundleID);
        
        if(self.konHostView){
            [(_UISceneLayerHostContainerView *)self.konHostView invalidate];
            [self.konHostView removeFromSuperview];
            self.konHostView = nil;
        }

        @try {
            [self.konSpinnerView stopAnimating];
            self.konHostView = [Konban viewFor:bundleID]; //prevent crashes by putting it in a try-catch block. While the app is loading, the FBSceneLayer will return nil, which will cause a crash.
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

        // CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)@"me.nepeta.konban/StatusBarHide", nil, nil, true);

        if (!self.konHostView) { // loop through these steps until the application is launched and our view is returned.
            [self.konSpinnerView startAnimating];
            [self.view bringSubviewToFront:self.konSpinnerView];
            [self performSelector:@selector(viewDidAppear:) withObject:nil afterDelay:0.5];
        }
    }
}

-(void)viewWillDisappear:(bool)arg1 {
    %orig;
    // CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)@"me.nepeta.konban/StatusBarShow", nil, nil, true);

    // visible = NO;
    if (!self.konHostView || !enabled || ([KonbanSpringboard isLocked] && !useInNC)){
        return;
    } 

    // if(){
    //     NSLog(@"[Konban] %s", "this is in NC");
    //     return;
    // }

    // [(_UISceneLayerHostContainerView *)self.konHostView invalidate];
    [self.konHostView removeFromSuperview];
    // self.konHostView = nil;
    [Konban dehost:bundleID];
}

%end

void changeApp() {
    NSDictionary *appList = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"me.nepeta.konban-app"];
    if (!appList) return;

    if ([appList objectForKey:@"selectedApplication"]) {
        bundleID = [appList objectForKey:@"selectedApplication"];
    }
}

%ctor{
    preferences = [[HBPreferences alloc] initWithIdentifier:@"me.nepeta.konban"];
    [preferences registerBool:&enabled default:YES forKey:@"Enabled"];
    [preferences registerFloat:&cornerRadius default:16 forKey:@"CornerRadius"];
    [preferences registerFloat:&scale default:0.8 forKey:@"Scale"];
    // [preferences registerBool:&hideStatusBar default:NO forKey:@"HideStatusBar"];
    // [preferences registerBool:&useInNC default:NO forKey:@"useInNotificationCenter"];
    // dpkgInvalid = ![[NSFileManager defaultManager] fileExistsAtPath:@"/var/lib/dpkg/info/com.nicho1asdev.konban.list"];

    // if (dpkgInvalid) %init(dpkgInvalid);

    if (!enabled) return;

    changeApp();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)changeApp, (CFStringRef)@"me.nepeta.konban/ReloadApp", NULL, (CFNotificationSuspensionBehavior)kNilOptions);
}
