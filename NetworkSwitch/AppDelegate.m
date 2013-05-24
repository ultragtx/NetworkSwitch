//
//  AppDelegate.m
//  NetworkSwitch
//
//  Created by Xinrong Guo on 13-2-1.
//  Copyright (c) 2013年 Xinrong Guo. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (strong, nonatomic) NSStatusItem *statusItem;
@property (strong, nonatomic) NSMenuItem *proxyOnMenuItem;
@property (strong, nonatomic) NSMenuItem *proxyOffMenuItem;

@end

@implementation AppDelegate

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
}


- (void)proxyOff {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/sbin/networksetup"];
    [task setArguments:@[@"-setsocksfirewallproxystate", @"Ethernet", @"off"]];
    [task launch];
    
    [_proxyOffMenuItem setState:NSOnState];
    [_proxyOnMenuItem setState:NSOffState];
    
//    AuthorizationRef authorizationRef;
//    OSStatus status = AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, kAuthorizationFlagDefaults, &authorizationRef);
//    char *networksetup = "/usr/sbin/networksetup";
//    char *args[] = {"-setsocksfirewallproxystate", "Ethernet", "on", NULL};
//    FILE *pipe = NULL;
//    status = AuthorizationExecuteWithPrivileges(authorizationRef, networksetup, kAuthorizationFlagDefaults, args, &pipe);
}

- (void)proxyOn {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/sbin/networksetup"];
    [task setArguments:@[@"-setsocksfirewallproxystate", @"Ethernet", @"on"]];
    [task launch];
    [_proxyOffMenuItem setState:NSOffState];
    [_proxyOnMenuItem setState:NSOnState];
}

- (void)quit {
    [[NSApplication sharedApplication] terminate:nil];
}

@end
