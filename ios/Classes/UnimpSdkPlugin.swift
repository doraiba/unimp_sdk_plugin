import Flutter
import UIKit
import FlutterUniAppMp


public class UnimpSdkPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "unimp_sdk_plugin", binaryMessenger: registrar.messenger())
    let instance = UnimpSdkPlugin()
    registrar.addApplicationDelegate(instance)
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {

    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "isExistsUniMP":
        let appid = call.arguments as! String;
        result(DCUniMPSDKEngine.isExistsUniMP(appid))
    case "releaseWgtWithAppid":
      let m = call.arguments as! [String:String];

        let appid: String = m["appid"]!
        let wgtPath: String = m["wgtPath"]!

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
        let configuration = DCUniMPConfiguration.init();
        configuration.enableGestureClose = true
        configuration.enableBackground = true
//        configuration.extraData = extraData
	      DCUniMPSDKEngine.openUniMP(appid, configuration: configuration) { instance, error in
              var r = [String:Any]();
              if let instance = instance {
                  
	              print("小程序打开成功")
                  r["appid"] = instance.appid
                  r["ok"] = true
	              
	              // 在此处处理小程序实例对象 instance
	          } else if let error = error {
	              print(error)
	              // 在此处处理打开小程序时的错误 error
                  r["appid"] = nil
                  r["ok"] = false
                  
	          }
              result(r)
	      }

    default:
      result(FlutterMethodNotImplemented)
    }
  }

    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable : Any] = [:]) -> Bool {
    
    
        // DCUniMPSDKEngine.setDelegate(self)
        
        let mpOptions = NSMutableDictionary(dictionary: launchOptions )
        mpOptions.setValue(NSNumber(value: true), forKey: "debug")
        
        DCUniMPSDKEngine.initSDKEnvironment(launchOptions: mpOptions as! [AnyHashable: Any])
        //        DCUniMPSDKEngine.setCapsuleButtonHidden(false)
        //        DCUniMPSDKEngine.setAutoControlNavigationBar(true)
        //        print("hello world2");
        //        let capsuleButtonStyle = DCUniMPCapsuleButtonStyle.init()
        //        // 胶囊按钮背景颜色
        //        capsuleButtonStyle.backgroundColor = "rgba(169,169,169,0.2)"
        //        // 胶囊按钮 “···｜x” 的字体颜色
        //        capsuleButtonStyle.textColor = "#FFFFFF"
        //        // 胶囊按钮按下状态背景颜色
        //        capsuleButtonStyle.highlightColor = "rgb(203,204,205)"
        //        // 胶囊按钮边框颜色
        //        capsuleButtonStyle.borderColor = "rgba(229,229,229,0.3)"
        //        // 设置样式
        //        DCUniMPSDKEngine.configCapsuleButtonStyle(capsuleButtonStyle)
        return true;
    }
}
