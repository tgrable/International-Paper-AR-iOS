//
//  ViewController.m
//  InternationalPaper
//
//  Created by Timothy C Grable on 8/20/15.
//  Copyright (c) 2015 Trekk Design. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "ARMarker.h"
#import <WikitudeSDK/WikitudeSDK.h>
#import <WikitudeSDK/WTArchitectViewDebugDelegate.h>

#define IPBLUE [UIColor colorWithRed:0/256.0 green:82/256.0 blue:202/256.0 alpha:1.0]
#define IPDARKBLUE [UIColor colorWithRed:0/256.0 green:61/256.0 blue:150/256.0 alpha:1.0]
#define IPTEXT [UIColor colorWithRed:128/256.0 green:120/256.0 blue:115/256.0 alpha:1.0]

@interface ViewController ()<WTArchitectViewDelegate, WTArchitectViewDebugDelegate, UIPopoverPresentationControllerDelegate> {
    float markerHeight;
    int markerCount;
    NSInteger totalMarkers;
    BOOL navWindowIsOpen, companyHidden, privacyHidden, downloadHidden;
}

@property (nonatomic, strong) WTArchitectView       *architectView;
@property (nonatomic, weak) WTNavigation            *architectWorldNavigation;
@property (strong, nonatomic) UIView                *arBrowserView, *navBar, *navWindowView, *contentView, *companyView, *privacyView, *downloadMarkerView;
@property (strong, nonatomic) UIScrollView          *markerScrollView;
@property (strong, nonatomic) UILabel               *headerLabel;
@property (strong, nonatomic) NSMutableDictionary   *markerDict;
@property (strong, nonatomic) NSMutableArray        *markerObjects;
@property (strong, nonatomic) NSString              *pageHeader;
@property (strong, nonatomic) NSString              *device;

@end

@implementation ViewController

@synthesize arBrowserView;  //UIView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Shared applicatiion method used to check device type
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    _device = [delegate platformType];
    
    _markerObjects = [NSMutableArray array];
    _markerDict = [NSMutableDictionary dictionary];
    
    float y = 75;
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        y = 50;
    }
    //UIView used to hold the AR Browser
    arBrowserView = [[UIView alloc] initWithFrame:CGRectMake(0, y, self.view.bounds.size.width, self.view.bounds.size.height - 50)];
    [arBrowserView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:arBrowserView];
    
    NSError *deviceSupportError = nil;
    if ( [WTArchitectView isDeviceSupportedForRequiredFeatures:WTFeature_Geo | WTFeature_ImageTracking error:&deviceSupportError] ) {
//    if ( [WTArchitectView isDeviceSupportedForRequiredFeatures:WTFeature_2DTracking error:&deviceSupportError] ) {
        
        /* Standard WTArchitectView object creation and initial configuration */
        self.architectView = [[WTArchitectView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 50)];
        self.architectView.delegate = self;
        self.architectView.debugDelegate = self;
        
        /* Use the -setLicenseKey method to unlock all Wikitude SDK features that you bought with your license. */
        [self.architectView setLicenseKey:@"PKEsuNcLgH6OUCEk3fGue3UFD4H6SA99OMsCqXSozZo6PUcvE8F1LX9AQS1M6xAa8V0w+9l/g8m/F0mRCyz6JWk684/NN0HvQIYqy6eb5dX312AO9o8bLpZAA8cPd6S0AN+alQgHnXVdlvWHSU9pOW0CVxejRP6ck2A3p4b9351TYWx0ZWRfXz3Azq7EUTaqzdFT18XPXg2kClHoEfjE829wNe4vnPDpzy68Do6NmwunF/V+bwFRoCKKPFnJxKWvNynIKdDZGVYyeeTzqLeq8R4oPurllGjPgHigcXOjfDsb+qScPQMLU7cG9hM2LExpk1aqqI4djDv1b7zg+YtsYZcx1eopCNL1wanz21oeRlV5FckAvQcdVsQQniB2P6JjTyczNdrBhiSEqec+SQd7sUhG3a01dGMLKcLSr0J1TWGs2na0IZXBq2rGS2F+G5pIFgMQd4krH08D4nsD0KHsjh6h3OgBprjOVPRETbgSyR3dKfIMYsk364qMZc+g9yjmhb7snVozQwv5njTMsYuK8ndIPc/gZx9w6zNQ8SCBkN2JxhYj79Vw1t750RnEzQRgk1qsQx4/Ip0wPDx9HEEdzA4lnCxGONEWdnsJ9CQl1ElBNWa2SlV6l6pb+vi2AeC5Gc83LSq1EBb6ne9XAUN2AI6U+dNhms5HYRctfm7nndA="];
        
//        NSURL *url = [NSURL URLWithString:@"http://s3-eu-west-1.amazonaws.com/studio-live/799958/worlds/03773e97-7d01-426c-850c-59cb1ee6d031/wikitudeStudio.html"];
//        self.architectWorldNavigation = [self.architectView loadArchitectWorldFromURL:url withRequiredFeatures:WTFeature_2DTracking];
        
//        self.architectWorldNavigation = [self.architectView loadArchitectWorldFromURL:[[NSBundle mainBundle] URLForResource:@"index" withExtension:@"html" subdirectory:@"assets"] withRequiredFeatures:WTFeature_2DTracking];
        
        NSURL *architectWorldURL = [[NSBundle mainBundle] URLForResource:@"index" withExtension:@"html" subdirectory:@"assets"];
        [self.architectView loadArchitectWorldFromURL:architectWorldURL];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            
            if (self.architectWorldNavigation.wasInterrupted) {
                [self.architectView reloadArchitectWorld];
            }
            
            /* Standard WTArchitectView rendering resuming after the application becomes active again */
            [self startWikitudeSDKRendering];
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            
            /* Standard WTArchitectView rendering suspension when the application resignes active */
            [self stopWikitudeSDKRendering];
        }];
        
        /* Standard subview handling using Autolayout */
        [arBrowserView addSubview:self.architectView];
        
        self.architectView.translatesAutoresizingMaskIntoConstraints = NO;
        arBrowserView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin |
        UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        
        NSDictionary *views = NSDictionaryOfVariableBindings(_architectView);
        [arBrowserView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"|[_architectView]|" options:0 metrics:nil views:views] ];
        [arBrowserView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_architectView]|" options:0 metrics:nil views:views] ];
        
    }
    else {
        NSLog(@"This device is not supported. Show either an alert or use this class method even before presenting the view controller that manages the WTArchitectView. Error: %@", [deviceSupportError localizedDescription]);
    }
    
    //UIView used to hold the navigation bar
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    [_contentView setBackgroundColor:[UIColor clearColor]];
    _contentView.hidden = YES;
    [self.view addSubview:_contentView];
    
    // Build Views
    [self buildAppNavigationView];
    
    companyHidden = YES;
    [self buildCompanyView];
    
    privacyHidden = YES;
    [self buildPrivacyView];
    
    downloadHidden = YES;
    [self buildDownloadView];
    [self createMarkerImages];
    
    [self buildNavigation];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    /* WTArchitectView rendering is started once the view controllers view will appear */
    [self startWikitudeSDKRendering];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    //Handle device rotation
    //[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    /* WTArchitectView rendering is stopped once the view controllers view did disappear */
    [self stopWikitudeSDKRendering];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    /* Remove this view controller from the default Notification Center so that it can be released properly */
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark - View Rotation
- (void)orientationChanged:(NSNotification *)note {
    UIDevice *device = note.object;
    [_contentView setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    
    switch(device.orientation) {
        case UIDeviceOrientationPortrait:
            [self updateViews];
            break;
        case UIDeviceOrientationLandscapeLeft:
            [self updateViews];
            break;
        case UIDeviceOrientationLandscapeRight:
            [self updateViews];
            break;
        default:
            break;
    };
}

- (void)updateViews {
    //Remove Views
    [self removeEverything:_navBar];
    [self removeEverything:_navWindowView];
    [self removeEverything:_companyView];
    [self removeEverything:_privacyView];
    [self removeEverything:_downloadMarkerView];
    
    //Build the app views
    [self buildAppNavigationView];
    [self buildCompanyView];
    [self buildPrivacyView];
    [self buildDownloadView];
    markerHeight = 0;
    [self buildMarkerView];
    [self buildNavigation];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    /* When the device orientation changes, specify if the WTArchitectView object should rotate as well */
    [self.architectView setShouldRotate:YES toInterfaceOrientation:toInterfaceOrientation];
}

#pragma mark -
#pragma mark - Private Methods (WikiTude)
/* Convenience methods to manage WTArchitectView rendering. */
- (void)startWikitudeSDKRendering{
    /* To check if the WTArchitectView is currently rendering, the isRunning property can be used */
    if ( ![self.architectView isRunning] ) {
        
        /* To start WTArchitectView rendering and control the startup phase, the -start:completion method can be used */
        [self.architectView start:^(WTStartupConfiguration *configuration) {
            
            /* Use the configuration object to take control about the WTArchitectView startup phase */
            /* You can e.g. start with an active front camera instead of the default back camera */
            
            // configuration.captureDevicePosition = AVCaptureDevicePositionFront;
            
        } completion:^(BOOL isRunning, NSError *error) {
            
            /* The completion block is called right after the internal start method returns.
             
             NOTE: In case some requirements are not given, the WTArchitectView might not be started and returns NO for isRunning.
             To determine what caused the problem, the localized error description can be used.
             */
            if ( !isRunning ) {
                NSLog(@"WTArchitectView could not be started. Reason: %@", [error localizedDescription]);
            }
        }];
    }
}

- (void)stopWikitudeSDKRendering {
    /* The stop method is blocking until the rendering and camera access is stopped */
    if ( [self.architectView isRunning] ) {
        [self.architectView stop];
    }
}

/* The WTArchitectView provides two delegates to interact with. */
#pragma mark -
#pragma mark - Delegation
/* The standard delegate can be used to get information about:
 * The Architect World loading progress
 * architectsdk:// protocol invocations using document.location inside JavaScript
 * Managing view capturing
 * Customizing view controller presentation that is triggered from the WTArchitectView
 */

#pragma mark -
#pragma mark - WTArchitectViewDelegate
- (void)architectView:(WTArchitectView *)architectView didFinishLoadArchitectWorldNavigation:(WTNavigation *)navigation {
    /* Architect World did finish loading */
}

- (void)architectView:(WTArchitectView *)architectView didFailToLoadArchitectWorldNavigation:(WTNavigation *)navigation withError:(NSError *)error {
    NSLog(@"Architect World from URL '%@' could not be loaded. Reason: %@", navigation.originalURL, [error localizedDescription]);
}

- (void)architectView:(WTArchitectView *)architectView didCaptureScreenWithContext:(NSDictionary *)context {
    //Screen shot of the the ARBrowser view and the HTML inside it
    UIImage *screenShot = [context objectForKey:kWTScreenshotImageKey];
    NSMutableArray *itemsToShare = [NSMutableArray array];
    [itemsToShare addObject:screenShot];
    
    //UIActivityViewController used to show the share action sheet
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
    activityVC.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact]; //or whichever you don't need
    [self presentViewController:activityVC animated:YES completion:nil];
}

/* 
 The debug delegate can be used to respond to internal issues, e.g. the user declined camera or GPS access.
 NOTE: The debug delegate method -architectView:didEncounterInternalWarning is currently not used.
*/

#pragma mark -
#pragma mark - WTArchitectViewDebugDelegate
- (void)architectView:(WTArchitectView *)architectView didEncounterInternalWarning:(WTWarning *)warning {
    /* Intentionally Left Blank */
}

- (void)architectView:(WTArchitectView *)architectView didEncounterInternalError:(NSError *)error {
    NSLog(@"WTArchitectView encountered an internal error '%@'", [error localizedDescription]);
}

#pragma mark -
#pragma mark - invokedURL
- (void)architectView:(WTArchitectView *)architectView invokedURL:(NSURL *)URL {
    
    NSString *urlBase = @"https://www.hammermill.com/";
    NSString *urlString = [NSString stringWithFormat:@"%@", URL];
    NSURL *newURL = [[NSURL alloc] init];
    
    NSLog(@"DEUG: %@", urlString);
    
    //UIApplication used to open the International Paper website in Safari
    UIApplication *mySafari = [UIApplication sharedApplication];
    if ([urlString isEqualToString:@"architectsdk://170613_PFL_KIT_4x6WEBCARDS_IP4D-1"]) {
        newURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/for-home/", urlBase]];
        [mySafari openURL:newURL];
    }
    else if ([urlString isEqualToString:@"architectsdk://170613_PFL_KIT_4x6WEBCARDS_IP4D-2"]) {
        newURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/for-work/", urlBase]];
        [mySafari openURL:newURL];
    }
    else if ([urlString isEqualToString:@"architectsdk://170613_PFL_KIT_4x6WEBCARDS_IP4D-3"]) {
        newURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/for-school/", urlBase]];
        [mySafari openURL:newURL];
    }
    else if ([urlString isEqualToString:@"architectsdk://170613_PFL_KIT_4x6WEBCARDS_IP4D-4"]) {
        newURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/business-card-templates/", urlBase]];
        [mySafari openURL:newURL];
    }
    else if ([urlString isEqualToString:@"architectsdk://170613_PFL_KIT_4x6WEBCARDS_IP4D-5"]) {
        newURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", urlBase]];
        [mySafari openURL:newURL];
    }
    else if ([urlString isEqualToString:@"architectsdk://170613_PFL_KIT_4x6WEBCARDS_IP4D-6"]) {
        newURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/outside-the-lines-coloring-book/", urlBase]];
        [mySafari openURL:newURL];
    }
    else if ([urlString isEqualToString:@"architectsdk://170613_PFL_KIT_4x6WEBCARDS_IP4D-7"]) {
        newURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/pride-in-your-work/", urlBase]];
        [mySafari openURL:newURL];
    }
    else if ([urlString isEqualToString:@"architectsdk://170613_PFL_KIT_4x6WEBCARDS_IP4D-8"]) {
        newURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/st-jude-paper-partnership/", urlBase]];
        [mySafari openURL:newURL];
    }
    else if ([urlString isEqualToString:@"architectsdk://170613_PFL_KIT_4x6WEBCARDS_IP4D-9"]) {
        newURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/print-hammermill/", urlBase]];
        [mySafari openURL:newURL];
    }
    else if ([urlString isEqualToString:@"architectsdk://170613_PFL_KIT_4x6WEBCARDS_IP4D-10"]) {
        newURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/easy-to-use-recipe-cards/", urlBase]];
        [mySafari openURL:newURL];
    }
    else if ([urlString isEqualToString:@"architectsdk://170613_PFL_KIT_4x6WEBCARDS_IP4D-11"]) {
        newURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/99-99-jam-free-guarantee/", urlBase]];
        [mySafari openURL:newURL];
    }
    else if ([urlString isEqualToString:@"architectsdk://170613_PFL_KIT_4x6WEBCARDS_IP4D-12"]) {
        newURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/history/", urlBase]];
        [mySafari openURL:newURL];
    }
    else if ([urlString isEqualToString:@"architectsdk://170613_PFL_KIT_4x6WEBCARDS_IP4D-13"]) {
        newURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/paper-is-power/", urlBase]];
        [mySafari openURL:newURL];
    }
    else {
        /* Currently this is just checking for something and used to take a screen shot of the current camera view and contained HTML */
        if (_companyView.hidden && _privacyView.hidden) {
            NSMutableDictionary *saveContext = [NSMutableDictionary dictionary];
            [architectView captureScreenWithMode:WTScreenshotCaptureMode_CamAndWebView usingSaveMode:WTScreenshotSaveMode_Delegate saveOptions:WTScreenshotSaveOption_CallDelegateOnSuccess context:saveContext];
        }
    }
}

#pragma mark -
#pragma mark - App Navigation View
- (void)buildAppNavigationView {
    
    //Check device type and orientation
    float y = 25;
    float h = 75;
    
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        y = ([_device rangeOfString:@"iPad"].location != NSNotFound) ? 25 : 0;
        h = ([_device rangeOfString:@"iPad"].location != NSNotFound) ? 75 : 50;
    }
    
    //UIView used to hold the navigation bar
    _navBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, h)];
    [_navBar setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:_navBar];
    
    //UIButton used to show and hide navigation
    UIButton *hamburgerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [hamburgerButton setFrame:CGRectMake(20, y, 38, 48)];
    hamburgerButton.backgroundColor = [UIColor clearColor];
    hamburgerButton.showsTouchWhenHighlighted = YES;
    [hamburgerButton setBackgroundImage:[UIImage imageNamed:@"menuicon"] forState:UIControlStateNormal];
    [hamburgerButton setTitleColor:[UIColor colorWithRed:0/256.0 green:84/256.0 blue:129/256.0 alpha:1.0] forState:UIControlStateNormal];
    [hamburgerButton addTarget:self action:@selector(showHideNavigation)forControlEvents:UIControlEventTouchUpInside];
    [_navBar addSubview:hamburgerButton];
}

#pragma mark -
#pragma mark - Navigation Menu
- (void)buildNavigation {
    
    //UIImage used to hold the IP logo
    UIImage *logo = [UIImage imageNamed:@"ip4d_logo_v1"];
    
    //Check device type and orientation
    float y = 75;
    float h = 50;
    float buttonLocation = (logo.size.height / 3) + (65 + 5);
    float w = self.view.bounds.size.width;
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        y = ([_device rangeOfString:@"iPad"].location != NSNotFound) ? 75 : 50;
        h = ([_device rangeOfString:@"iPhone 6"].location != NSNotFound) ? 50 : 40;
        buttonLocation = 25;
        w = ([_device rangeOfString:@"iPad"].location != NSNotFound) ? self.view.bounds.size.width / 4 : self.view.bounds.size.width;
    }
    
    float navX = (navWindowIsOpen) ? 0 : self.view.bounds.size.width * -1;
    
    //UIView used to hold the top navigation menu
    _navWindowView = [[UIView alloc] initWithFrame:CGRectMake(navX, y, w, self.view.bounds.size.height - y)];
    [_navWindowView  setBackgroundColor:IPBLUE];
    [self.view addSubview:_navWindowView];
    
    /**********************************************************/
    float x = (_navWindowView.bounds.size.width / 2) - ([self getLogoSizeForDevice:logo] / 2);
    y = 35;
    float cpx = 0;
    float cpw = _navWindowView.bounds.size.width;
    
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        x = ([_device rangeOfString:@"iPad"].location != NSNotFound) ? (_navWindowView.bounds.size.width / 2) - ([self getLogoSizeForDevice:logo] / 2): (_navWindowView.bounds.size.width / 2) + ((_navWindowView.bounds.size.width / 4) - ([self getLogoSizeForDevice:logo] / 2));
        //y = ([_device rangeOfString:@"iPad"].location != NSNotFound) ? 330 : 50;
        cpx = ([_device rangeOfString:@"iPad"].location != NSNotFound) ? 0 : _navWindowView.bounds.size.width / 2;
        cpw = ([_device rangeOfString:@"iPad"].location != NSNotFound) ? _navWindowView.bounds.size.width : _navWindowView.bounds.size.width / 2;
    }
    
    if ([_device rangeOfString:@"iPad"].location != NSNotFound && UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        y += 200;
    }
    
    UIImageView *ipLogo = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, [self getLogoSizeForDevice:logo], [self getLogoSizeForDevice:logo])];
    ipLogo.image = logo;
    ipLogo.contentMode = UIViewContentModeScaleAspectFit;
    [ipLogo setBackgroundColor:[UIColor clearColor]];
    [_navWindowView addSubview:ipLogo];
    
    /**********************************************************/
    w = _navWindowView.bounds.size.width - 30;
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        w = ([_device rangeOfString:@"iPad"].location != NSNotFound) ? _navWindowView.bounds.size.width - 30 : (_navWindowView.bounds.size.width - 30) / 2;
    }
    else {
        buttonLocation = ([_device rangeOfString:@"iPad"].location != NSNotFound) ? buttonLocation += 300 : buttonLocation;
    }
    
    //UIButton used to show and hide navigation
    UIButton *arBrowserButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [arBrowserButton setFrame:CGRectMake(15, buttonLocation, w, h)];
    arBrowserButton.backgroundColor = IPDARKBLUE;
    arBrowserButton.showsTouchWhenHighlighted = YES;
    [arBrowserButton setTitle:@"AR Browser" forState:normal];
    [arBrowserButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [arBrowserButton addTarget:self action:@selector(navigateToOtherPages:)forControlEvents:UIControlEventTouchUpInside];
    arBrowserButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    arBrowserButton.tag = 1;
    [_navWindowView addSubview:arBrowserButton];
    buttonLocation += (h + 10);
    
    //UIButton used to navigate to ContentViewController
    UIButton *sampleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sampleButton setFrame:CGRectMake(15, buttonLocation, w, h)];
    sampleButton.backgroundColor = IPDARKBLUE;
    sampleButton.showsTouchWhenHighlighted = YES;
    [sampleButton setTitle:@"Company" forState:normal];
    [sampleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sampleButton addTarget:self action:@selector(navigateToOtherPages:)forControlEvents:UIControlEventTouchUpInside];
    sampleButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    sampleButton.tag = 2;
    [_navWindowView addSubview:sampleButton];
    buttonLocation += (h + 10);
    
    //UIButton used to navigate to ContentViewController
    UIButton *newsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [newsButton setFrame:CGRectMake(15, buttonLocation, w, h)];
    newsButton.backgroundColor = IPDARKBLUE;
    newsButton.showsTouchWhenHighlighted = YES;
    [newsButton setTitle:@"Privacy" forState:normal];
    [newsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [newsButton addTarget:self action:@selector(navigateToOtherPages:)forControlEvents:UIControlEventTouchUpInside];
    newsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    newsButton.tag = 3;
    [_navWindowView addSubview:newsButton];
    buttonLocation += (h + 10);
    
    //UIButton used to navigate to ContentViewController
    UIButton *downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [downloadButton setFrame:CGRectMake(15, buttonLocation, w, h)];
    downloadButton.backgroundColor = IPDARKBLUE;
    downloadButton.showsTouchWhenHighlighted = YES;
    [downloadButton setTitle:@"Download a Sample" forState:normal];
    [downloadButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [downloadButton addTarget:self action:@selector(navigateToOtherPages:)forControlEvents:UIControlEventTouchUpInside];
    downloadButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    downloadButton.tag = 4;
    [_navWindowView addSubview:downloadButton];
    buttonLocation += (h + 10);
    
    //UILabel used to hold copy right text
    UILabel *copyRightText = [[UILabel alloc] initWithFrame:CGRectMake(15, (logo.size.height / 3) + (65 + 245), _navWindowView.bounds.size.width - 30, 10)];
    copyRightText.text = @"\u00A9 2009-2014 International Paper. All Rights Reserved.";
    [copyRightText setFont:[UIFont systemFontOfSize:8]];
    copyRightText.textColor = [UIColor whiteColor];
    copyRightText.textAlignment = NSTextAlignmentCenter;
    [_navWindowView addSubview:copyRightText];
}

#pragma mark -
#pragma mark - Company View
- (void)buildCompanyView {
    float y = 75;
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        y = ([_device rangeOfString:@"iPad"].location != NSNotFound) ? 75 : 50;
    }
    
    //UIView used to hold the Company View
    _companyView = [[UIView alloc] initWithFrame:CGRectMake(0, y, self.view.bounds.size.width, self.view.bounds.size.height)];
    [_companyView  setBackgroundColor:[UIColor whiteColor]];
    _companyView.hidden = companyHidden;
    [_contentView addSubview:_companyView];
    
    //NSString used to hold the content in the Company View
    NSString *websiteURL = @"www.internationalpaper.com";
    NSString *body = @"International Paper is a global leader in the paper and packaging industry with manufacturing operations in North America, Europe, Latin America, Asia, and North Africa.";
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _companyView.bounds.size.width, _companyView.bounds.size.height)];
    scrollView.backgroundColor = [UIColor clearColor];
    [_companyView addSubview:scrollView];
    
    //UIImageView used to hold the a header image in the Company View
    UIImage *headerimage = [UIImage imageNamed:@"about_headerimage"];
    UIImageView *companyheaderimage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _companyView.bounds.size.width, _companyView.bounds.size.width * [self getImageRatio:headerimage])];
    companyheaderimage.image = headerimage;
    companyheaderimage.contentMode = UIViewContentModeScaleAspectFit;
    [companyheaderimage setBackgroundColor:[UIColor clearColor]];
    [scrollView addSubview:companyheaderimage];
    
    //UILabel used to hold the body copy content
    UILabel *bodycontentText = [[UILabel alloc] initWithFrame:CGRectMake(15, (_companyView.bounds.size.width * [self getImageRatio:headerimage]) + 20, _companyView.bounds.size.width - 30, 20)];
    bodycontentText.numberOfLines = 0;
    bodycontentText.font = [UIFont fontWithName:@"Arial" size:18.0];
    bodycontentText.text = body;
    bodycontentText.textColor = IPTEXT;
    [bodycontentText sizeToFit];
    [scrollView addSubview:bodycontentText];
    
    float offset = companyheaderimage.bounds.size.height + bodycontentText.bounds.size.height + 50;
    
    //UILabel used to hold the body copy content
    UILabel *buttonContentText = [[UILabel alloc] initWithFrame:CGRectMake(15, offset, _companyView.bounds.size.width - 30, 20)];
    buttonContentText.numberOfLines = 1;
    buttonContentText.font = [UIFont fontWithName:@"Arial" size:18.0];
    buttonContentText.text = @"Learn more at";
    buttonContentText.textColor = IPTEXT;
    buttonContentText.textAlignment = NSTextAlignmentCenter;
    [scrollView addSubview:buttonContentText];
    
    offset += buttonContentText.bounds.size.height;
    
    //UIButton used to navigate out of the app and open the website in Safari
    UIButton *urlButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [urlButton setFrame:CGRectMake(15, offset, _companyView.bounds.size.width - 30, 22)];
    urlButton.backgroundColor = [UIColor clearColor];
    urlButton.showsTouchWhenHighlighted = YES;
    [urlButton setTitle:websiteURL forState:normal];
    [urlButton setTitleColor:IPTEXT forState:UIControlStateNormal];
    [urlButton addTarget:self action:@selector(navigateToOtherPages:)forControlEvents:UIControlEventTouchUpInside];
    urlButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    urlButton.tag = 5;
    [scrollView addSubview:urlButton];
    
    offset += urlButton.bounds.size.height + 100;
    
    [scrollView setContentSize:CGSizeMake(scrollView.bounds.size.width, offset)];
}

#pragma mark -
#pragma mark - Privacy View
- (void)buildPrivacyView {
    float y = 75;
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        y = ([_device rangeOfString:@"iPad"].location != NSNotFound) ? 75 : 50;
    }
    
    //UIView used to hold the Privacy View
    _privacyView = [[UIView alloc] initWithFrame:CGRectMake(0, y, self.view.bounds.size.width, self.view.bounds.size.height)];
    [_privacyView  setBackgroundColor:[UIColor clearColor]];
    _privacyView.hidden = privacyHidden;
    [self.view addSubview:_privacyView];
    
    //UIWebView used to hold the privacy information content at https://www.internationalpaper.com/utility/privacy.html
    UIWebView *webview = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, _privacyView.bounds.size.width, _privacyView.bounds.size.height)];
    NSString *urlAddress = @"http://www.internationalpaper.com/legal-pages/privacy-statement";
    NSURL *url = [NSURL URLWithString:urlAddress];
    
    //Search for @"WIDTH: 600px" and replace it with the width of the device
    NSString *html = [NSString stringWithContentsOfURL:url encoding:[NSString defaultCStringEncoding] error:nil];
    NSRange range = [html rangeOfString:@"WIDTH: 600px"];
    
    //If @"WIDTH: 600px" is found replace it
    if(range.location != NSNotFound) {
        // Adjust style for mobile
        NSString *adjustedSize = [NSString stringWithFormat:@"WIDTH: %fpx", _privacyView.bounds.size.width];
        html = [NSString stringWithFormat:@"%@%@%@", [html substringToIndex:range.location], adjustedSize, [html substringFromIndex:range.location]];
    }
    [webview loadHTMLString:html baseURL:url];
    
    //webview.scalesPageToFit = YES;
    //[webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.internationalpaper.com/legal-pages/privacy-statement"]]];
    
    [_privacyView addSubview:webview];
}

#pragma mark -
#pragma mark - Download a Sample View
- (void)buildDownloadView {
    float y = 75;
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        y = ([_device rangeOfString:@"iPad"].location != NSNotFound) ? 75 : 50;
    }
    
    //UIView used to hold the Download a Marker View
    _downloadMarkerView = [[UIView alloc] initWithFrame:CGRectMake(0, y, self.view.bounds.size.width, self.view.bounds.size.height)];
    [_downloadMarkerView  setBackgroundColor:[UIColor whiteColor]];
    _downloadMarkerView.hidden = downloadHidden;
    [self.view addSubview:_downloadMarkerView];
    
    //UIScrollView used to hold the markers in Download a Marker View
    _markerScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _downloadMarkerView.bounds.size.width, _downloadMarkerView.bounds.size.height)];
    [_markerScrollView setBackgroundColor:[UIColor clearColor]];
    [_downloadMarkerView addSubview:_markerScrollView];
}

#pragma mark -
#pragma mark - Marker Images
- (void)createMarkerImages {
    NSArray *markers = @[@"coverpage", @"desk", @"flyingbutterfly", @"hangingfromstars", @"sleep", @"window"];
    for (NSString *markerName in markers) {
        ARMarker *marker = [[ARMarker alloc] init];
        marker.markerName = markerName;
        
        //Add ARMarker object to the markerObjects array
        [_markerObjects addObject:marker];
        
        //Add ARMarker object to the markerDict dictionary
        UIImage *img = [UIImage imageNamed:markerName]; //[[UIImage alloc] initWithContentsOfFile:markerName];
        [_markerDict setObject:img forKey:markerName];
    }
    
    [self buildMarkerView];
}


- (void)buildMarkerView {
    for (ARMarker *arm in _markerObjects) {
        //UIButton used to navigate to display the markers
        UIButton *markerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [markerButton setFrame:CGRectMake(15, markerHeight, _downloadMarkerView.bounds.size.width - 30, (_downloadMarkerView.bounds.size.width - 30) * [self getImageRatio:[_markerDict objectForKey:arm.markerName]])];
        [markerButton setImage:[_markerDict objectForKey:arm.markerName] forState:UIControlStateNormal];
        markerButton.backgroundColor = [UIColor clearColor];
        markerButton.showsTouchWhenHighlighted = YES;
        [markerButton setTitle:arm.markerName forState:normal];
        [markerButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        [markerButton addTarget:self action:@selector(markerAction:)forControlEvents:UIControlEventTouchUpInside];
        markerButton.tag = 1;
        [_markerScrollView addSubview:markerButton];

        markerHeight += ((_downloadMarkerView.bounds.size.width - 30) * [self getImageRatio:[_markerDict objectForKey:arm.markerName]]) + 50;
    }
    
    [_markerScrollView setContentSize:CGSizeMake(_downloadMarkerView.bounds.size.width, markerHeight + 50)];
}

//Create Action Activity view controller
- (void)markerAction:(UIButton *)sender {
    NSString *name = sender.titleLabel.text;
    
    UIImage *screenShot = [_markerDict objectForKey:name];
    NSMutableArray *itemsToShare = [NSMutableArray array];
    [itemsToShare addObject:screenShot];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
    activityVC.excludedActivityTypes = @[UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeAddToReadingList]; //or whichever you don't need
    
    if ([_device rangeOfString:@"iPad"].location == NSNotFound) {
        [self presentViewController:activityVC animated:YES completion:nil];
    }
    else {
        // present the controller
        // on iPad, this will be a Popover
        // on iPhone, this will be an action sheet
        activityVC.modalPresentationStyle = UIModalPresentationPopover;
        [self presentViewController:activityVC animated:YES completion:nil];
        
        // configure the Popover presentation controller
        UIPopoverPresentationController *popController = [activityVC popoverPresentationController];
        popController.permittedArrowDirections = UIPopoverArrowDirectionDown;
        popController.delegate = self;
        
        // in case we don't have a bar button as reference
        popController.sourceView = self.view;
        popController.sourceRect = CGRectMake(self.view.bounds.size.width / 2, self.view.bounds.size.height - 5, self.view.bounds.size.width - 50, self.view.bounds.size.height - 50);
    }
}

//Scale the image to fit the device and keep it's ratio
- (float)getImageRatio:(UIImage *)img {
    return img.size.height / img.size.width;
}

- (float)getLogoSizeForDevice:(UIImage *)img {
    float imgSize = 0.0f;
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if ([_device rangeOfString:@"iPad"].location != NSNotFound) {
        imgSize = img.size.width / 1.25;
        if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
            imgSize = img.size.width / 2.5;
        }
    }
    else {
        if (!UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
            imgSize = ([_device rangeOfString:@"iPhone 6"].location != NSNotFound) ? img.size.width / 2.5 : img.size.width / 3;
        }
        else {
            imgSize = img.size.width / 2.5;
        }
    }
    
    return imgSize;
}

#pragma mark -
#pragma mark - Navigation
- (void)showHideNavigation {
    navWindowIsOpen = (navWindowIsOpen) ? NO : YES;
    
    float y = 75;
    float w = self.view.bounds.size.width;
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        y = ([_device rangeOfString:@"iPad"].location != NSNotFound) ? 75 : 50;
        w = ([_device rangeOfString:@"iPad"].location != NSNotFound) ? self.view.bounds.size.width / 4 : self.view.bounds.size.width;
    }
    
    //Set x location off the screen on the left side
    int x = self.view.bounds.size.width * -1;
    
    //if navigation view is not currently visible set x location
    //to 0 so the menu view is visible
    if (_navWindowView.frame.origin.x != 0) {
        x = 0;
    }
    
    //Animate the view in and out of view
    [UIView animateWithDuration:0.4f delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [_navWindowView setFrame:CGRectMake(x, y, w, self.view.bounds.size.height)];
    } completion:nil];
}

- (void)navigateToOtherPages:(UIButton *)sender {
    
    //UIApplication used to open the International Paper website in Safari
    UIApplication *mySafari = [UIApplication sharedApplication];
    NSURL *myURL = [[NSURL alloc]initWithString:@"http://www.internationalpaper.com/"];
    
    switch (sender.tag) {
        case 1:
            [self startWikitudeSDKRendering];
            
            //Show the ARBrowser View
            _companyView.hidden = YES;
            _privacyView.hidden = YES;
            _downloadMarkerView.hidden = YES;
            [self showHideNavigation];
            
            companyHidden = YES;
            privacyHidden = YES;
            downloadHidden = YES;
            
            break;
        case 2:
            //Show the Company View
            _contentView.hidden = NO;
            
            _companyView.hidden = NO;
            companyHidden = NO;
            
            _privacyView.hidden = YES;
            privacyHidden = YES;
            
            _downloadMarkerView.hidden = YES;
            downloadHidden = YES;
            
            [self stopWikitudeSDKRendering];
            [self showHideNavigation];

            break;
        case 3:
            //Show the Privacy View
            _contentView.hidden = NO;
            
            _companyView.hidden = YES;
            companyHidden = YES;
            
            _privacyView.hidden = NO;
            privacyHidden = NO;
            
            _downloadMarkerView.hidden = YES;
            downloadHidden = YES;
            
            [self stopWikitudeSDKRendering];
            [self showHideNavigation];

            break;
        case 4:
            //Show the Download a Marker View
            _contentView.hidden = NO;
            
            _companyView.hidden = YES;
            companyHidden = YES;
            
            _privacyView.hidden = YES;
            privacyHidden = YES;
            
            _downloadMarkerView.hidden = NO;
            downloadHidden = NO;
            
            [self stopWikitudeSDKRendering];
            [self showHideNavigation];
            
            break;
        case 5:
            //Open International Paper Website in Safari
            [mySafari openURL:myURL];
            companyHidden = YES;
            privacyHidden = YES;
            downloadHidden = YES;
            
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark - Memory Management
- (void)removeEverything:(UIView *)view {
    [view removeFromSuperview];
}

- (void)removeFromScrollView:(UIScrollView *)scrollView {
    for (UIView *view in [scrollView subviews]) {
        if (![view isKindOfClass:[UIRefreshControl class]]) {
            [view removeFromSuperview];
        }
    }
}

@end
