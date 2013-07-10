#import "XMPPStringPrep.h"

#define U_HAVE_LIB_SUFFIX 1
#define U_LIB_SUFFIX_C_NAME _xmppframework
#define U_CHARSET_IS_UTF8 1
#define U_NO_DEFAULT_INCLUDE_UTF_HEADERS 1
#define UCONFIG_NO_LEGACY_CONVERSION 1
#define UCONFIG_NO_BREAK_ITERATION 1
#define UCONFIG_NO_FORMATTING 1
#define UCONFIG_NO_REGULAR_EXPRESSIONS 1
#define UCONFIG_NO_SERVICE 1
#include <unicode/usprep.h>

@interface XMPPStringPrep ()

+(XMPPStringPrep*)sharedInstance;
-(NSString*)privatePrepNode:(NSString *)node;
-(NSString*)privatePrepDomain:(NSString *)domain;
-(NSString*)privatePrepResource:(NSString *)resource;

@end

@implementation XMPPStringPrep {
  UStringPrepProfile *_nodeProfile;
  UStringPrepProfile *_nameProfile;
  UStringPrepProfile *_resourceProfile;
}

+(XMPPStringPrep*)sharedInstance {
  static XMPPStringPrep *instance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[XMPPStringPrep alloc] init];
  });
  return instance;
}

+(NSString *)prepNode:(NSString *)node {
  return [[XMPPStringPrep sharedInstance] privatePrepNode:node];
}

+(NSString *)prepDomain:(NSString *)domain {
  return [[XMPPStringPrep sharedInstance] privatePrepDomain:domain];
}

+(NSString *)prepResource:(NSString *)resource {
  return [[XMPPStringPrep sharedInstance] privatePrepResource:resource];
}

-(id)init {
  if ((self = [super init])) {
    UErrorCode errorCode = U_ZERO_ERROR;
    _nodeProfile = usprep_openByType(USPREP_RFC3920_NODEPREP, &errorCode);
    assert(U_SUCCESS(errorCode));
    _nameProfile = usprep_openByType(USPREP_RFC3491_NAMEPREP, &errorCode);
    assert(U_SUCCESS(errorCode));
    _resourceProfile = usprep_openByType(USPREP_RFC3920_RESOURCEPREP, &errorCode);
    assert(U_SUCCESS(errorCode));
  }
  return self;
}

-(void)dealloc {
  if (_nodeProfile) usprep_close(_nodeProfile);
  if (_nameProfile) usprep_close(_nameProfile);
  if (_resourceProfile) usprep_close(_resourceProfile);
}

-(NSString *)privatePrepNode:(NSString *)node {
  NSUInteger length = [node length];
  if (length > 1023) return nil;
  UErrorCode errorCode = U_ZERO_ERROR;
  const UChar *src = [[node dataUsingEncoding:NSUTF16StringEncoding] bytes];
  UChar dst[1023];
  int32_t retLen = usprep_prepare(_nodeProfile, src, (int32_t)length + 1, dst, 1023, USPREP_DEFAULT, NULL, &errorCode);
  if (U_FAILURE(errorCode)) return nil;
  return [NSString stringWithCharacters:dst length:(NSUInteger)retLen];
}

-(NSString *)privatePrepDomain:(NSString *)domain {
  UErrorCode errorCode = U_ZERO_ERROR;
  NSMutableString *result = [NSMutableString stringWithCapacity:1023];
  BOOL firstLabel = YES;
  for (NSString *label in [domain componentsSeparatedByString:@"."]) {
    NSUInteger length = [label length];
    if (length > 63 || length == 0) return nil;
    const UChar *src = [[label dataUsingEncoding:NSUTF16StringEncoding] bytes];
    UChar dst[63];
    int32_t retLen = usprep_prepare(_nameProfile, src, (int32_t)length + 1, dst, 63, USPREP_DEFAULT, NULL, &errorCode);
    if (U_FAILURE(errorCode)) {
      return nil;
    } else if (firstLabel) {
      firstLabel = NO;
    } else {
      [result appendString:@"."];
    }
    NSString *preparedLabel = [NSString stringWithCharacters:dst length:(NSUInteger)retLen];
    [result appendString:preparedLabel];
  }
  return result;
}

-(NSString *)privatePrepResource:(NSString *)resource {
  UErrorCode errorCode = U_ZERO_ERROR;
  const UChar *src = [[resource dataUsingEncoding:NSUTF16StringEncoding] bytes];
  UChar dst[1023];
  int32_t retLen = usprep_prepare(_resourceProfile, src, (int32_t)[resource length] + 1, dst, 1023, USPREP_DEFAULT, NULL, &errorCode);
  if (U_FAILURE(errorCode)) return nil;
  return [NSString stringWithCharacters:dst length:(NSUInteger)retLen];
}

@end
