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
    intent.putExtra("employee_id", jsonData.getString("employee_id"));
    intent.putExtra("language", jsonData.getString("language"));
    intent.putExtra("color_code", jsonData.getString("color_code"));
    intent.putExtra("measured_height", jsonData.getString("measured_height"));
    intent.putExtra("measured_weight", jsonData.getString("measured_weight"));
    intent.putExtra("posture", jsonData.getString("posture"));
    if (intent.resolveActivity(this.reactContext.getPackageManager()) != null) {
      this.reactContext.startActivityForResult(intent, 90, null);
    }
  }


  @Override
  public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {
    JSONObject item = new JSONObject();
    SharedPreferences pref = reactContext.getSharedPreferences("CNV", 0);
    String otherResponse = pref.getString("message", "");
    if (resultCode == RESULT_OK) {
      StringBuilder str = new StringBuilder();
      
     
      int heartrate = pref.getInt("heart_rate", 0);
      int O2R = pref.getInt("spo2", 0);
      int Breath = pref.getInt("resp_rate", 0);
      int BPM = pref.getInt("heart_rate_cnv", 0);
      String ppgData = pref.getString("ecgdata", "");
      String ecgData = pref.getString("ppgdata", "");
      String heartData = pref.getString("heartdata", "");
      String heartDataArray = pref.getString("heartDataArray", "");
      String apiResponse = pref.getString("api_result", "");
     
      try {
        item.put("breath", Breath);
        item.put("O2R", O2R);
        item.put("bpm2", BPM);
        item.put("bpm", heartrate);
        item.put("ecgdata", ecgData);
        item.put("ppgdata", ppgData);
        item.put("heartdata", heartData);
        item.put("heartDataArray", heartDataArray);
        item.put("apiResponse",apiResponse);
      } catch (JSONException e) {

      }
      this.promise.resolve(item.toString());
    } else{
      try {
        item.put("message", otherResponse);
        item.put("reason", "Cancelled");
        this.promise.resolve(item.toString());
      } catch (JSONException e) {

      }
    }
  }

  @Override
  public void onNewIntent(Intent intent) {

  }
}
