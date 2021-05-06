import { NativeModules } from 'react-native';

type CnvitalsReactNativeType = {
  multiply(a: number, b: number): Promise<number>;
};

const { CnvitalsReactNative } = NativeModules;

export default CnvitalsReactNative as CnvitalsReactNativeType;
