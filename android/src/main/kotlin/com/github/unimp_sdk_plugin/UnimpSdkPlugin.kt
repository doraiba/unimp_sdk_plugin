package com.github.unimp_sdk_plugin

import android.app.Activity
import android.content.Context
import android.os.Bundle
import android.os.PersistableBundle
import android.util.Log
import io.dcloud.feature.sdk.DCSDKInitConfig
import io.dcloud.feature.sdk.DCUniMPSDK
import io.dcloud.feature.sdk.Interface.IUniMP
import io.dcloud.feature.sdk.MenuActionSheetItem
import io.dcloud.feature.unimp.config.IUniMPReleaseCallBack
import io.dcloud.feature.unimp.config.UniMPOpenConfiguration
import io.dcloud.feature.unimp.config.UniMPReleaseConfiguration
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.json.JSONObject
import java.util.concurrent.ConcurrentHashMap


/** UnimpSdkPlugin */
class UnimpSdkPlugin : FlutterPlugin, MethodCallHandler,ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel: MethodChannel
  private lateinit var activity: Activity;

  companion object {
    var runningInstances = ConcurrentHashMap<String, IUniMP>()
  }
  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "unimp_sdk_plugin")
    channel.setMethodCallHandler(this)



  }

  override fun onMethodCall(call: MethodCall, result: Result) {

    when (call.method) {
      "getPlatformVersion" -> {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")

      }

      "isExistsUniMP" -> {
        result.success(DCUniMPSDK.getInstance().isExistsApp(call.arguments?.toString()))
      }

      "releaseWgtWithAppid" -> {
        var appid = call.argument<String>("appid");
        var wgtPath = call.argument<String>("wgtPath");
        val uniMPReleaseConfiguration = UniMPReleaseConfiguration()
        uniMPReleaseConfiguration.wgtPath = wgtPath;
//      uniMPReleaseConfiguration.password = "789456123222"
        DCUniMPSDK.getInstance()
          .releaseWgtToRunPath(appid, uniMPReleaseConfiguration, IUniMPReleaseCallBack() { i: Int, any: Any ->
            if (i == 1) {
              val appVersionInfo = DCUniMPSDK.getInstance().getAppVersionInfo(appid);
              result.success(jsonObjectToMap(appVersionInfo));
            } else {
              result.error("释放app错误", appid, any);
            }
          })
      }

      "openUniMP" -> {

        var appid = call.argument<String>("appid");
        var extraData = call.argument<Map<*, *>>("extraData");
        val uniMPOpenConfiguration = UniMPOpenConfiguration()
        uniMPOpenConfiguration.extraData = extraData?.let { JSONObject(it) };
        val openUniMP = DCUniMPSDK.getInstance().openUniMP(this.activity, appid, uniMPOpenConfiguration);
        val mapOf = mapOf(Pair("appid", openUniMP.appid), Pair("ok", true));
        runningInstances.put(openUniMP.appid,openUniMP);
        result.success(mapOf);
      }

      "getAppBasePath" -> {
        val appBasePath = DCUniMPSDK.getInstance().getAppBasePath(this.activity);
        result.success(appBasePath);
      }

      "updateCheck" -> {
        var appid = call.argument<String>("appid");
        var version = call.argument<Int>("code");
        if (DCUniMPSDK.getInstance().isExistsApp(appid)) {
          var info = DCUniMPSDK.getInstance().getAppVersionInfo(appid)
          var oldCode = info.getInt("code");
          var res = version?.compareTo(oldCode)
          if (res != null) {
            if (res > 0) {
              result.success(true)
              return
            }
          }
        }
        result.success(false)
      }

      else -> {
        result.notImplemented();
      }
    }

  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  fun jsonObjectToMap(jsonObject: JSONObject): Map<String, String> {
    val map = mutableMapOf<String, String>()
    jsonObject.keys().forEach { key ->
      map[key] = jsonObject.getString(key)
    }
    return map
  }

  override fun onAttachedToActivity(p0: ActivityPluginBinding) {
    this.activity = p0.activity;
    val item = MenuActionSheetItem("关于", "gy")
    val sheetItems: MutableList<MenuActionSheetItem> = ArrayList<MenuActionSheetItem>()
    sheetItems.add(item)
    val config: DCSDKInitConfig = DCSDKInitConfig.Builder()
      .setCapsule(true)
      .setMenuDefFontSize("16px")
      .setMenuDefFontColor("#ff00ff")
      .setMenuDefFontWeight("normal")
      .setMenuActionSheetItems(sheetItems)
      .build()
    DCUniMPSDK.getInstance().initialize(p0.activity, config)
    Log.i("flutter","initial sdk");
  }

  override fun onDetachedFromActivityForConfigChanges() {

  }

  override fun onReattachedToActivityForConfigChanges(p0: ActivityPluginBinding) {

  }

  override fun onDetachedFromActivity() {

  }
}
