#import "CnvitalsReactNative.h"
#import <CNVitalsiOS/CNVitalsiOS.h>

@interface CnvitalsReactNative()<HeartRateDetectionModelDelegate>
@property (nonatomic, assign) bool detecting;
@property (nonatomic, assign) int bpms;
@property (nonatomic, assign) int so2;
@property (nonatomic, assign) int rr;
@property (nonatomic, getter=isModalInPresentation) BOOL modalInPresentation;
@property (nonatomic, strong) NSString *ppgdata;
@property (nonatomic, strong) NSString *ecgdata;
@property(strong, nonatomic) UIViewController *viewController;
@property(strong, nonatomic) RCTPromiseResolveBlock _callbackResult;
@end

@implementation CnvitalsReactNative
RCT_EXPORT_MODULE()

// Example method
// See // https://reactnative.dev/docs/native-modules-ios
RCT_REMAP_METHOD(getVitals,
                 multiplyWithA:(nonnull NSString*)a
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)
{
    __callbackResult = resolve;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"bodyvitals" bundle:nil];
        BodyVitalsViewController *vc = [sb instantiateViewControllerWithIdentifier:@"BodyVitalsViewController"];
        if (@available(iOS 13.0, *)) {
            [vc setModalInPresentation:YES];
        } else {
            // Fallback on earlier versions
        }
        [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:vc animated:YES completion:^{
            vc.delegate = self;
        }];
    });
}


- (void)heartRateStart{
    self.bpms = 0;
    self.so2 = 0;
    self.rr = 0;
}

- (void)heartRateUpdate:(int)bpm{
    self.bpms = bpm;
}

- (void)Spo2Update:(int)so2{
    self.so2 = so2;
}

- (void)RespirationUpdate:(int)rr{
    self.rr = rr;
}

- (void)setPPGData:(NSString *)ppgData{
    self.ppgdata = ppgData;
}

- (void)setECGData:(NSString *)ecgData{
    self.ecgdata = ecgData;
}

- (void)heartRateEnd{
    self.detecting = false;
    
    NSString* myHeartRate = [NSString stringWithFormat:@"%i", self.bpms];
    NSString* myso2 = [NSString stringWithFormat:@"%i", self.so2];
    NSString* myRespirationRate = [NSString stringWithFormat:@"%i", self.rr];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setValue:myHeartRate forKey:@"bpm"];
    [dict setValue:myso2 forKey:@"O2R"];
    [dict setValue:myRespirationRate forKey:@"breath"];
    [dict setValue:self.ppgdata forKey:@"ppgdata"];
    [dict setValue:self.ecgdata forKey:@"ecgdata"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    if (jsonData) {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    } else {
        NSLog(@"Got an error: %@", error);
        jsonString = @"";
    }
    [[UIApplication sharedApplication].delegate.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
    __callbackResult([@"iOS " stringByAppendingString:jsonString]);
    
}
@end
