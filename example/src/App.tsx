import * as React from 'react';

import { StyleSheet, View, Text } from 'react-native';
import CnvitalsReactNative from 'react-native-cnvitals-react-native';

export default function App() {
  const [result, setResult] = React.useState<string | undefined>();

  React.useEffect(() => {
    let data = JSON.stringify({
      api_key: '',
      scan_token: '',
      user_id: '',
    });
    CnvitalsReactNative.getVitals(data).then(setResult);
  }, []);

  return (
    <View style={styles.container}>
      <Text>Result: {result}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
});
