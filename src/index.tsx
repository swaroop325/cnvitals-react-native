import { NativeModules } from 'react-native';

type CnvitalsReactNativeType = {
  getVitals(a: any): Promise<any>;
};

const { CnvitalsReactNative } = NativeModules;

export default CnvitalsReactNative as CnvitalsReactNativeType;
