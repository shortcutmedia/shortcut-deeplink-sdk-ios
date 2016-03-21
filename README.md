# IMPORTANT: this SDK has been deprecated

The functionality of the Shortcut Deep Linking SDK have been integrated into [Shortcut for iOS](https://github.com/shortcutmedia/shortcut-ios). Please use [Shortcut for iOS](https://github.com/shortcutmedia/shortcut-ios) instead of the Shortcut Deep Linking SDK.

If you have already integrated the Shortcut Deep Linking SDK into your app then please follow the [Migration Guide](https://github.com/shortcutmedia/shortcut-ios#migrating-from-the-shortcut-deep-linking-sdk) to upgrade your app to use the new SDK.

---

# Shortcut Deep Linking SDK for iOS

This SDK provides the following features:

- Support for [deferred deep linking](https://en.wikipedia.org/wiki/Deferred_deep_linking).
- Collection of additional statistics to build a user acquisition funnel and evaluate user activity.
- Creating Shortcuts (short mobile deep links) to share from within your app.

There is also an [Android version of this SDK](https://github.com/shortcutmedia/shortcut-deeplink-sdk-android).

## Requirements

The SDK works with any device running iOS6 and newer.

## Installation

The SDK is packaged in a .framework file. To use it within your project follow these steps:

1. Download the latest SDK as zip file from the [releases page](https://github.com/shortcutmedia/shortcut-deeplink-sdk-ios/releases).
2. Unzip it and add the *ShortcutDeepLinkingSDK.framework*  file to your project, e.g. by dragging it into the Project Navigator of your project in Xcode.
3. Within your project's **Build phases** make sure that the *ShortcutDeepLinkingSDK.framework* is added in the **Link binary with libraries** section. If you don't find it there, drag it from the Project Navigator to the list.

## Prerequisites

To make use of this SDK you need the following:

- An iOS app that supports deep linking (using a [custom URL scheme](https://developer.apple.com/library/ios/documentation/iPhone/Conceptual/iPhoneOSProgrammingGuide/Inter-AppCommunication/Inter-AppCommunication.html#//apple_ref/doc/uid/TP40007072-CH6-SW10) or [Universal Links](https://developer.apple.com/library/ios/documentation/General/Conceptual/AppSearch/UniversalLinks.html)).
- A Shortcut with a mobile deep link to your app. Use the [Shortcut Manager](http://manager.shortcutmedia.com) to create one.
- An API key. Use the [Shortcut Manager](http://manager.shortcutmedia.com/mobile_apps) to create a mobile app with an associated API key. This is only needed if you intend to create Shortcuts to share from within your app.


## Integration into your app

Make sure to import our SDK in all files where you use it:

```objective-c
#import <ShortcutDeepLinkingSDK/ShortcutDeepLinkingSDK.h>
```

#### Enabling deferred deep linking

To enable deferred deep linking you just have to tell the SDK about the app launch.

Add the following to `-application:didFinishLaunchingWithOptions:` in your *AppDelegate.m* file:

```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [[SCDeepLinking sharedInstance] launch];

    // ...
    return YES;
}
```

#### Collecting deep link interaction statistics

To collect deep link interaction statistics you have to tell the SDK when a deep link is opened: The SDK keeps track of your users looking at deep link content through sessions. You have to create a session whenever a a deep link is opened; the SDK will automatically terminate the session when a user leaves your app.

##### When using custom URL schemes:
Add the following to `-application:openURL:sourceApplication:annotation:` (you have added this method to your app delegate when you implemented your app's custom-scheme deep link handling):

```objective-c
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {

    SCSession *deepLinkSession = [[SCDeepLinking sharedInstance] startSessionWithURL:url];
    url = deepLinkSession.url // Use the session object's url property for further processing

    // ...
}
```

##### When using Universal Links:
Add the following to `-application:continueUserActivity:restorationHandler:` (you have added this method to your app delegate when you implemented your app's Universal Link handling):

```objective-c
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler {

    if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        self.deepLinkSession = [[SCDeepLinking sharedInstance] startSessionWithURL:userActivity.webpageURL];
        userActivity.webpageURL = self.deepLinkSession.url; // Use the session object's url property for further processing
    }

    // ...
}
```

#### Creating Shortcuts (short mobile deep links)

**Prerequisite:** You need an API key with an authentication token. You can generate a mobile app with an associated API key in the [Shortcut Manager](http://manager.shortcutmedia.com/mobile_apps). We need this in order to identify your app and assign the Shortcut to it..

Tell the SDK about your token by adding the following to `-application:didFinishLaunchingWithOptions:` in your *AppDelegate.m* file:

```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [[SCDeepLinking sharedInstance] setAuthToken:@"YOUR_AUTH_TOKEN_HERE"];

    // ...
    return YES;
}
```

If you are also using deferred deep linking then add it before the `[[SCDeepLinking sharedInstance] launch];` call (see *[Enabling deferred deep linking](#enabling-deferred-deep-linking)*).

Creating short links is an asynchronous process, since your link parameters need to be sent to the Shortcut backend. This can take a short amount of time during which you do not want to block your app. Therefore the short link creation process runs in the background and you are notified once it is finished via a completion handler.

**An example:** Let's assume you have a *Share* button in your app which should bring up an action sheet that allows you to share some content within your app through a short link.

An implementation could look something like this:

```objective-c
- (IBAction)shareButtonPressed:(id)button {

    SCDeepLinking *dl = [SCDeepLinking sharedInstance];

    [dl createShortLinkWithTitle:@"content title"
                      websiteURL:[NSURL URLWithString:@"http://your.site/content"]
                     deepLinkURL:[NSURL URLWithString:@"your-app://your/content"]
               completionHandler:^(NSURL *shortLinkURL, NSError *error) {

        if (!error) {
            [self displayShareSheetWithURL:shortLinkURL];
        } else {
            // do error handling...
        }
    }];
}

- (void)displayShareSheetWithURL:(NSURL *)urlToShare {
    // ...
}
```

This will create a short link that deep links into your app on all platforms you have configured in the Shortcut Manager.

**Advanced configuration:** If you have different deep link schemes for different platforms or if you want to override the app store URLs you set up in the manager, you can use the following method instead:

```objective-c
- (IBAction)shareButtonPressed:(id)button {

    SCDeepLinking *dl = [SCDeepLinking sharedInstance];

    [dl createShortLinkWithTitle:@"content title"
                      websiteURL:[NSURL URLWithString:@"http://your.site/content"]
                  iOSAppStoreURL:[NSURL URLWithString:@"https://itunes.apple.com/app/idYOURAPPID?mt=8"]
                  iOSDeepLinkURL:[NSURL URLWithString:@"your-ios-scheme://your/content"]
              androidAppStoreURL:[NSURL URLWithString:@"https://play.google.com/store/apps/details?id=YOURAPPID"]
              androidDeepLinkURL:[NSURL URLWithString:@"your-android-scheme://your/content"]
         windowsPhoneAppStoreURL:[NSURL URLWithString:@"https://www.microsoft.com/store/apps/YOURAPPID"]
         windowsPhoneDeepLinkURL:[NSURL URLWithString:@"your-windows-phone-scheme://your/content"]
               completionHandler:^(NSURL *shortLinkURL, NSError *error) {

        if (!error) {
            [self displayShareSheetWithURL:shortLinkURL];
        } else {
            // do error handling...
        }
    }];
}

- (void)displayShareSheetWithURL:(NSURL *)urlToShare {
    // ...
}
```

The parameters `websiteURL` and `completionHandler` are mandatory. All other parameters are optional (you can pass nil). There are also shorter alternative methods that omit different sets of optional parameters. Just play around with Xcode autocompletion of method names ;)


## License
This project is released under the MIT license. See included LICENSE.txt file for details.
