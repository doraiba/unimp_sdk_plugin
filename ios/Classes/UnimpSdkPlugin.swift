import Flutter
import UIKit
import YUniMPSDK


public class UnimpSdkPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "unimp_sdk_plugin", binaryMessenger: registrar.messenger())
    let instance = UnimpSdkPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {

    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

   func checkUniMPResource(appid: String) -> Void {
        let wgtPath = Bundle.main.path(forResource: appid, ofType: "wgt") ?? ""
        if DCUniMPSDKEngine.isExistsUniMP(appid) {
            let version = DCUniMPSDKEngine.getUniMPVersionInfo(withAppid: appid)!
            let name = version["name"]!
            let code = version["code"]!
            print("小程序：\(appid) 资源已存在，版本信息：name:\(name) code:\(code)")
        } else {
            do {
                try DCUniMPSDKEngine.installUniMPResource(withAppid: appid, resourceFilePath: wgtPath, password: nil)
                let version = DCUniMPSDKEngine.getUniMPVersionInfo(withAppid: appid)!
                let name = version["name"]!
                let code = version["code"]!
                print("✅ 小程序：\(appid) 资源释放成功，版本信息：name:\(name) code:\(code)")
            } catch let err as NSError {
                print("❌ 小程序：\(appid) 资源释放失败:\(err)")
            }
        }
    }
    
}
