import Flutter
import UIKit
import Network

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var _lanChannel: FlutterMethodChannel?
  private var _probeConnection: NWConnection?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    let launched = super.application(application, didFinishLaunchingWithOptions: launchOptions)

    // After super, FlutterAppDelegate has created the FlutterViewController
    // and set it as window.rootViewController — safe to attach the channel.
    if let controller = window?.rootViewController as? FlutterViewController {
      _lanChannel = FlutterMethodChannel(
        name: "com.accesscare/lan_permission",
        binaryMessenger: controller.binaryMessenger
      )
      _lanChannel?.setMethodCallHandler { [weak self] call, result in
        guard call.method == "prime", let ip = call.arguments as? String else {
          result(FlutterMethodNotImplemented)
          return
        }
        self?.primeLanAccess(ip: ip) { result(nil) }
      }
    }

    return launched
  }

  private func primeLanAccess(ip: String, completion: @escaping () -> Void) {
    var done = false
    let finish: () -> Void = {
      guard !done else { return }
      done = true
      DispatchQueue.main.async { completion() }
    }
    let conn = NWConnection(host: NWEndpoint.Host(ip), port: 1883, using: .tcp)
    _probeConnection = conn
    conn.stateUpdateHandler = { [weak self] state in
      switch state {
      case .ready:
        conn.cancel()
      case .failed(_):
        conn.cancel()
      case .cancelled:
        self?._probeConnection = nil
        finish()
      default:
        break
      }
    }
    conn.start(queue: .main)
    DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
      guard !done else { return }
      self?._probeConnection?.cancel()
    }
  }
}
