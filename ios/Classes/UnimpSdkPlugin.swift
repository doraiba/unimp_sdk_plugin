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
    case "isExistsUniMP":
      result(DCUniMPSDKEngine.isExistsUniMP("\(call.arguments)"))
    case "releaseWgtWithAppid":
      let m = call.arguments as! [String:String];

      let appid: String = m["appid"] as! String
      let wgtPath: String = m["wgtPath"] as! String

			do {
          try DCUniMPSDKEngine.installUniMPResource(withAppid: appid, resourceFilePath: wgtPath, password: nil)
          let version = DCUniMPSDKEngine.getUniMPVersionInfo(withAppid: appid)!
          let name = version["name"]!
          let code = version["code"]!
          print("✅ 小程序：\(appid) 资源释放成功，版本信息：name:\(name) code:\(code)")
          result("name: \(name) code: \(code)")
      } catch let err as NSError {
          print("❌ 小程序：\(appid) 资源释放失败:\(err)")
          result(err)
      }


    case "openUniMP":
				let arguments = call.arguments as! [String: Any];
        let appid = arguments["appid"] as! String;
//        let extraData = arguments["extraData"] as? [String: Any] ?? [:]
        let configuration = DCUniMPConfiguration();
//        configuration.enableBackground = true
//        configuration.extraData = extraData
	      DCUniMPSDKEngine.openUniMP(appid, configuration: configuration) { instance, error in
	          if let instance = instance {
	              print("小程序打开成功")
	              result(instance)
	              // 在此处处理小程序实例对象 instance
	          } else if let error = error {
	              print(error)
	              // 在此处处理打开小程序时的错误 error
	          }
	      }

    default:
      result(FlutterMethodNotImplemented)
    }
  }

    
}
