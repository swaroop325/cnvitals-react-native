package com.reactnativecnvitalsreactnative;

import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.module.annotations.ReactModule;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import sdk.carenow.cnvitals.Calibration;

import static android.app.Activity.RESULT_OK;

@ReactModule(name = CnvitalsReactNativeModule.NAME)
public class CnvitalsReactNativeModule extends ReactContextBaseJavaModule implements ActivityEventListener {
  public static final String NAME = "CnvitalsReactNative";

  public CnvitalsReactNativeModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
    this.reactContext.addActivityEventListener(this);
  }

  static final int REQUEST_VIDEO_CAPTURE = 1;


  final ReactApplicationContext reactContext;
  Promise promise;


  @Override
  @NonNull
  public String getName() {
    return NAME;
  }


  @ReactMethod
  public void getVitals(String data, Promise promise) throws JSONException {
    this.promise = promise;

    JSONObject jsonData = new JSONObject(data);

    Intent intent = new Intent(reactContext.getApplicationContext(), Calibration.class);
    intent.putExtra("api_key", jsonData.getString("api_key"));
    intent.putExtra("scan_token", jsonData.getString("scan_token"));
    intent.putExtra("user_id", jsonData.getString("user_id"));
    if (intent.resolveActivity(this.reactContext.getPackageManager()) != null) {
      this.reactContext.startActivityForResult(intent, 90, null);
    }
  }


  @Override
  public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {
    if (resultCode == RESULT_OK) {
      StringBuilder str = new StringBuilder();
      JSONObject item = new JSONObject();
      SharedPreferences pref = reactContext.getSharedPreferences("CNV", 0);
      int heartrate = pref.getInt("heart_rate", 0);
      int O2R = pref.getInt("spo2", 0);
      int Breath = pref.getInt("resp_rate", 0);
      int BPM = pref.getInt("heart_rate_cnv", 0);
      String ppgData = pref.getString("ecgdata", "");
      String ecgData = pref.getString("ppgdata", "");
      String heartData = pref.getString("heartdata", "");
      try {
        item.put("breath", Breath);
        item.put("O2R", O2R);
        item.put("bpm2", BPM);
        item.put("bpm", heartrate);
        item.put("ecgdata", ecgData);
        item.put("ppgdata", ppgData);
        item.put("heartdata", heartData);
      } catch (JSONException e) {

      }
      this.promise.resolve(item.toString());
    } else if (resultCode == 2) {
      this.promise.resolve("license invalid");
    } else if (resultCode == 0) {
      this.promise.resolve("cancelled");
    }
  }

  @Override
  public void onNewIntent(Intent intent) {

  }
}
