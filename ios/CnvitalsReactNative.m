#import "CnvitalsReactNative.h"
#import <CNVitalsiOS/CNVitalsiOS.h>

@interface CnvitalsReactNative()<HeartRateDetectionModelDelegate>
@property (nonatomic, assign) bool detecting;
@property (nonatomic, assign) int bpms;
@property (nonatomic, assign) int so2;
@property (nonatomic, assign) int rr;
@property (nonatomic, getter = isModalInPresentation) BOOL modalInPresentation;
@property (nonatomic, strong) NSString *ppgdata;
@property (nonatomic, strong) NSString *ecgdata;
@property (nonatomic, strong) NSString *heartdataArray;
@property (nonatomic, strong) NSString *apiResponse;
@property(strong, nonatomic) UIViewController *viewController;
@property(strong, nonatomic) RCTPromiseResolveBlock _callbackResult;
@end

@implementation CnvitalsReactNative
RCT_EXPORT_MODULE()

// Example method
// See // https://reactnative.dev/docs/native-modules-ios
RCT_REMAP_METHOD(getVitals,
                 multiplyWithA:(nonnull NSString*)data
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)
{
    NSError *error;
    NSData *dataValues = [data dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:dataValues options:NSJSONWritingPrettyPrinted error:nil];
    NSString *api_key = jsonData[@"api_key"];
    NSString *scan_token = jsonData[@"scan_token"];
    NSString *color_code = jsonData[@"color_code"];
    NSString *employee_id = jsonData[@"employee_id"];
    NSString *measured_height= jsonData[@"measured_height"];
    NSString *measured_weight= jsonData[@"measured_weight"];
    NSString *posture =jsonData[@"posture"];
    NSDictionary *postDict = @{@"api_key":api_key, @"scan_token":scan_token,@"employee_id":employee_id,@"measured_height": measured_height, @"measured_weight":measured_weight,@"posture": posture };
    __callbackResult = resolve;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"bodyvitals" bundle:nil];
        BodyVitalsViewController *vc = [sb instantiateViewControllerWithIdentifier:@"BodyVitalsViewController"];
        vc.api_details = postDict;
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
- (void)apiResponseUpdate:(NSString *)apiResponse{
    self.apiResponse = apiResponse;
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

- (void)setHeartDataArray:(NSString *)heartDataArray{
    self.heartdataArray = heartDataArray;
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
    [dict setValue:self.heartdataArray forKey:@"heartDataArray"];
    [dict setValue:self.apiResponse forKey:@"apiResponse"];
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
    __callbackResult([@"" stringByAppendingString:jsonString]);
    
}

- (void)heartRateMeasurementFailed:(NSString *)message{
    self.detecting = false;
    __callbackResult([@"" stringByAppendingString:message]);
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}
@end
