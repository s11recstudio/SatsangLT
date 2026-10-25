//  SatsangLTApp.swift — સત્સંગ Lower Third (iPad)
//  iPad પર controller, HDMI (ATEM) પર અલગ 16:9 output.
//  App minimize થાય એટલે iPad આપોઆપ ફરી સામાન્ય mirror કરે છે.

import SwiftUI
import UIKit
import WebKit

// MARK: - Controller ↔ Output વચ્ચેનો સેતુ
final class Bridge: NSObject, WKScriptMessageHandler {
    static let shared = Bridge()
    weak var controller: WKWebView?
    weak var output: WKWebView?
    private var lastState: String?

    var externalConnected = false {
        didSet { notifyController() }
    }

    func userContentController(_ ucc: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let s = message.body as? String else { return }
        lastState = s
        applyToOutput()
    }

    func applyToOutput() {
        guard let o = output, let s = lastState else { return }
        o.evaluateJavaScript("window.__apply && window.__apply(\(s));", completionHandler: nil)
    }

    func notifyController() {
        let on = externalConnected ? "true" : "false"
        controller?.evaluateJavaScript("window.__ext && window.__ext(\(on));", completionHandler: nil)
    }
}

// MARK: - WebView બનાવવું
func makeWebView(isOutput: Bool) -> WKWebView {
    let cfg = WKWebViewConfiguration()
    cfg.websiteDataStore = .default()
    cfg.allowsInlineMediaPlayback = true
    let ucc = WKUserContentController()
    let flag = isOutput ? "window.__NATIVE_OUT=true;" : "window.__NATIVE=true;"
    ucc.addUserScript(WKUserScript(source: flag, injectionTime: .atDocumentStart, forMainFrameOnly: true))
    if !isOutput { ucc.add(Bridge.shared, name: "satsang") }
    cfg.userContentController = ucc

    let wv = WKWebView(frame: .zero, configuration: cfg)
    wv.isOpaque = true
    wv.backgroundColor = isOutput ? UIColor(red: 0, green: 0.69, blue: 0.25, alpha: 1) : .black
    wv.scrollView.contentInsetAdjustmentBehavior = .never
    wv.scrollView.bounces = false
    if isOutput { wv.isUserInteractionEnabled = false }

    if let url = Bundle.main.url(forResource: "satsang", withExtension: "html") {
        wv.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
    }
    return wv
}

// MARK: - iPad પરનું controller
struct ControllerView: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        let wv = makeWebView(isOutput: false)
        wv.navigationDelegate = context.coordinator
        Bridge.shared.controller = wv
        return wv
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            Bridge.shared.notifyController()
        }
    }
}

// MARK: - HDMI / ATEM પરનું output
final class OutputNav: NSObject, WKNavigationDelegate {
    static let shared = OutputNav()
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Bridge.shared.applyToOutput()
    }
}

final class ExternalSceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let ws = scene as? UIWindowScene else { return }
        ws.screen.overscanCompensation = .none
        let w = UIWindow(windowScene: ws)
        let vc = UIViewController()
        let web = makeWebView(isOutput: true)
        web.navigationDelegate = OutputNav.shared
        vc.view = web
        w.rootViewController = vc
        w.isHidden = false
        window = w
        Bridge.shared.output = web
        Bridge.shared.externalConnected = true
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        window = nil
        Bridge.shared.output = nil
        Bridge.shared.externalConnected = false
    }
}

// MARK: - App
final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        application.isIdleTimerDisabled = true   // screen બંધ ન થાય
        return true
    }

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        if connectingSceneSession.role == .windowExternalDisplayNonInteractive {
            let c = UISceneConfiguration(name: "External Display", sessionRole: connectingSceneSession.role)
            c.delegateClass = ExternalSceneDelegate.self
            return c
        }
        return UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
    }
}

@main
struct SatsangLTApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ControllerView()
                .ignoresSafeArea(.container, edges: [.bottom, .horizontal])
                .persistentSystemOverlays(.hidden)
        }
    }
}
