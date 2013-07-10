#import <Foundation/Foundation.h>

@interface XMPPStringPrep : NSObject

+(NSString *)prepNode:(NSString *)node;
+(NSString *)prepDomain:(NSString *)domain;
+(NSString *)prepResource:(NSString *)resource;

@end
