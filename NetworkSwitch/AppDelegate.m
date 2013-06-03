//
//  AppDelegate.m
//  NetworkSwitch
//
//  Created by Xinrong Guo on 13-2-1.
//  Copyright (c) 2013年 Xinrong Guo. All rights reserved.
//

#import "AppDelegate.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <Security/Security.h>

#define PROXY_SOCKS_PORT 11080
#define PROXY_SOCKS_ADDR @"127.0.0.1"

@interface AppDelegate ()

@property (strong, nonatomic) NSStatusItem *statusItem;
@property (strong, nonatomic) NSMenuItem *proxyOnMenuItem;
@property (strong, nonatomic) NSMenuItem *proxyOffMenuItem;

@end

@implementation AppDelegate {
    AuthorizationRef _authRef;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSImage *statusIcon = [NSImage imageNamed:@"MenuBarIcon.pdf"];
    [statusIcon setTemplate:YES];
    
    NSMenu *statusMenu = [[NSMenu alloc] initWithTitle:@"StatusMenu"];
    _proxyOffMenuItem = [[NSMenuItem alloc] initWithTitle:@"Donlike drinking tea" action:@selector(proxyOff) keyEquivalent:@""];
    _proxyOnMenuItem = [[NSMenuItem alloc] initWithTitle:@"Make my life easiser" action:@selector(proxyOn) keyEquivalent:@""];
    [statusMenu addItem:_proxyOffMenuItem];
    [statusMenu addItem:_proxyOnMenuItem];
    
    [statusMenu addItem:[NSMenuItem separatorItem]];
    [statusMenu addItemWithTitle:@"Quit" action:@selector(quit) keyEquivalent:@""];
    
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [_statusItem setImage:statusIcon];
    [_statusItem setHighlightMode:YES];
    [_statusItem setMenu:statusMenu];
    
    [self configureAuthorization];
}

- (void)configureAuthorization {
    AuthorizationFlags authFlags = kAuthorizationFlagDefaults
                                    | kAuthorizationFlagExtendRights
                                    | kAuthorizationFlagInteractionAllowed
                                    | kAuthorizationFlagPreAuthorize;
    
    OSStatus authErr = AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, authFlags, &_authRef);
    
    if (authErr) {
        NSLog(@"auth error");
        NSAlert *alert = [NSAlert alertWithMessageText:@"Auth Error" defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
        [alert runModal];
    }
}

#pragma mark - Proxy Settings
#pragma mark = Helpers
- (NSString *)proxiesPathOfDevice:(NSString *)devId {
    NSString *path = [NSString stringWithFormat:@"/%@/%@/%@", kSCPrefNetworkServices, devId, kSCEntNetProxies];
    return path;
}

- (NSDictionary *)modifiedProxiesDictWithDict:(NSDictionary *)dict proxyEnabled:(BOOL)enabled {
    NSMutableDictionary *modifiedProxies = [NSMutableDictionary dictionaryWithDictionary:dict];
    if (enabled) {
        [modifiedProxies setObject:[NSNumber numberWithInteger:PROXY_SOCKS_PORT] forKey:(NSString *)kCFNetworkProxiesSOCKSPort];
        [modifiedProxies setObject:PROXY_SOCKS_ADDR forKey:(NSString *)kCFNetworkProxiesSOCKSProxy];
        [modifiedProxies setObject:[NSNumber numberWithInt:1] forKey:(NSString *)kCFNetworkProxiesSOCKSEnable];
    }
    else {
        [modifiedProxies setObject:[NSNumber numberWithInt:0] forKey:(NSString *)kCFNetworkProxiesSOCKSEnable];
    }
    return modifiedProxies;
}

#pragma mark = Functions
- (void)enableProxy:(BOOL)enabled {
    SCPreferencesRef prefRef = SCPreferencesCreateWithAuthorization(kCFAllocatorDefault, CFSTR("NetworkSwitch"), NULL, _authRef);
    // TODO: lock? SCPreferencesLock
    NSDictionary *sets = (__bridge NSDictionary *)SCPreferencesGetValue(prefRef, kSCPrefNetworkServices);
//    NSLog(@"%@", [sets description]);
    for (NSString *key in [sets allKeys]) {
        NSDictionary *dict = [sets objectForKey:key];
        NSString *hardware = [dict valueForKeyPath:@"Interface.Hardware"];
        if ([hardware isEqualToString:@"Ethernet"] || [hardware isEqualToString:@"AirPort"]) {
//            NSLog(@"%@", [dict description]);
            NSDictionary *proxies = [dict objectForKey:(NSString *)kSCEntNetProxies];
//            NSLog(@"%@", [proxies description]);
            if (proxies) { // Here we assume there's alaways a "Proxies" key
                NSDictionary *modifiedProxies = [self modifiedProxiesDictWithDict:proxies proxyEnabled:enabled];
                NSString *path = [self proxiesPathOfDevice:key];
                SCPreferencesPathSetValue(prefRef, (__bridge CFStringRef)path, (__bridge CFDictionaryRef)modifiedProxies);
            }
        }
    }
    SCPreferencesCommitChanges(prefRef);
    SCPreferencesApplyChanges(prefRef);
    SCPreferencesSynchronize(prefRef);
}


- (void)proxyOff {
    [self enableProxy:NO];
    
    [_proxyOffMenuItem setState:NSOnState];
    [_proxyOnMenuItem setState:NSOffState];
}

- (void)proxyOn {
    [self enableProxy:YES];
    
    [_proxyOffMenuItem setState:NSOffState];
    [_proxyOnMenuItem setState:NSOnState];
}

- (void)quit {
    [[NSApplication sharedApplication] terminate:nil];
}

@end
