//
//  VDeviceInfo.m
//
//

#import "VDeviceInfo.h"

#include <sys/sysctl.h>
#include <sys/types.h>

@implementation VDeviceInfo

+ (NSString *)platform
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}

+ (NSString *)platformString
{
    static NSDictionary *platformDescriptions;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void)
    {
        // platform descriptions courtesy of http://theiphonewiki.com/wiki/Models
        // alternate source of platform descriptions: https://ipsw.me/all
        platformDescriptions =
        @{
            @"iPhone1,1": @"iPhone 1G",
            @"iPhone1,2": @"iPhone 3G",
            @"iPhone2,1": @"iPhone 3GS",
            @"iPhone3,1": @"iPhone 4",
            @"iPhone3,2": @"iPhone 4",
            @"iPhone3,3": @"iPhone 4", // Verizon
            @"iPhone4,1": @"iPhone 4S",
            @"iPhone5,1": @"iPhone 5", // GSM
            @"iPhone5,2": @"iPhone 5", // CDMA
            @"iPhone5,3": @"iPhone 5c",
            @"iPhone5,4": @"iPhone 5c",
            @"iPhone6,1": @"iPhone 5s",
            @"iPhone6,2": @"iPhone 5s",
            @"iPhone7,1": @"iPhone 6 Plus",
            @"iPhone7,2": @"iPhone 6",
            @"iPhone8,1": @"iPhone 6s",
            @"iPhone8,2": @"iPhone 6s Plus",
            @"iPod1,1":   @"iPod Touch 1G",
            @"iPod2,1":   @"iPod Touch 2G",
            @"iPod3,1":   @"iPod Touch 3G",
            @"iPod4,1":   @"iPod Touch 4G",
            @"iPod5,1":   @"iPod Touch 5G",
            @"iPod7,1":   @"iPod Touch 6G",
            @"iPad1,1":   @"iPad",
            @"iPad2,1":   @"iPad 2 (WiFi)",
            @"iPad2,2":   @"iPad 2 (GSM)",
            @"iPad2,3":   @"iPad 2 (CDMA)",
            @"iPad2,4":   @"iPad 2 (WiFi)",
            @"iPad2,5":   @"iPad Mini (WiFi)",
            @"iPad2,6":   @"iPad Mini (GSM)",
            @"iPad2,7":   @"iPad Mini (CDMA)",
            @"iPad3,1":   @"iPad 3 (WiFi)",
            @"iPad3,2":   @"iPad 3 (CDMA)",
            @"iPad3,3":   @"iPad 3 (GSM)",
            @"iPad3,4":   @"iPad 4 (WiFi)",
            @"iPad3,5":   @"iPad 4 (GSM)",
            @"iPad3,6":   @"iPad 4 (CDMA)",
            @"iPad4,1":   @"iPad Air (WiFi)",
            @"iPad4,2":   @"iPad Air (WiFi + Cellular)",
            @"iPad4,3":   @"iPad Air",
            @"iPad4,4":   @"iPad Mini Retina (WiFi)",
            @"iPad4,5":   @"iPad Mini Retina (WiFi + Cellular)",
            @"iPad4,6":   @"iPad Mini Retina",
            @"iPad4,7":   @"iPad Mini 3 (WiFi)",
            @"iPad4,8":   @"iPad Mini 3 (WiFi + Cellular)",
            @"iPad4,9":   @"iPad Mini 3",
            @"iPad5,1":   @"iPad Mini 4",
            @"iPad5,2":   @"iPad Mini 4",
            @"iPad5,3":   @"iPad Air 2 (WiFi)",
            @"iPad5,4":   @"iPad Air 2 (WiFi + Cellular)",
            @"i386":      @"Simulator",
            @"x86_64":    @"Simulator",
        };
    });
    
    NSString *platform = [self platform];
    return platformDescriptions[platform] ?: platform;
}

@end
