//
//  Captcha.swift
//  MTCaptcha
//
//  Created by Sanjeev Sree on 27/08/21.
//
import UIKit
import WebKit

public class CaptchaSDK: UIView,WKUIDelegate {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    var webView: WKWebView!
    var domain=""
    var sitekey=""
    var theme=""
    var action=""
    var customStyle=""
    var widgetSize=""
    
    var html=""
    var script=""
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func setDomain(productionDomain:String){
        self.domain=productionDomain
    }
    
    func setSitekey(sitekey:String){
        self.sitekey=sitekey
    }
    
    func setAction(action:String){
        self.action=action
    }
    func setTheme(theme:String){
        self.theme=theme
    }
    
    func setWidgetSize(widgetSize:String){
        self.widgetSize=widgetSize
    }
    
    func setCustomStyle(customStyle:String){
        self.customStyle=customStyle
    }
    
    func getSitekey() -> String {
        return self.sitekey
    }
    
    func getWidgetSize() -> String {
        return self.widgetSize
    }
    
    func getTheme() -> String {
        return self.theme
    }
    
    func getAction() -> String {
        return self.action
    }
    
    func getCustomStyle() -> String {
        return self.customStyle
    }
    
    func generateConfiguration() -> String {
        var config:String="{"
        config+="\"sitekey\":\""+getSitekey()+"\", // Get tie site key from Sites page of MTCaptcha admin site \n"
        if (getWidgetSize() != "")
        { config += "    \"widgetSize\": \"" + getWidgetSize() + "\",\n"}
        if (getTheme() != "")
        {config += "    \"theme\": \"" + getTheme() + "\",\n"}
        if (getAction() != "")
        { config += "    \"action\": \"" + getAction() + "\",\n"}
        if (getCustomStyle() != "")
        {config += "    \"customStyle\": " + getCustomStyle() + ",\n";}
        config += "};\n";
        return config;
    }
    
    func initWidget(productionDomain:String,sitekey:String){
        // Do any additional setup after loading the view.
        
        self.setDomain(productionDomain: productionDomain)
        self.setSitekey(sitekey: sitekey)
        
        self.script="""
         var mtcaptchaConfig =
         """ + self.generateConfiguration()+"""

        (
          function(){
            var mt_service = document.createElement('script');
            mt_service.async = true;
            mt_service.src = 'https://qa-service.sadtron.com/mtcv1/client/mtcaptcha.min.js';
            (
              document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]
            ).appendChild(mt_service);
            var mt_service2 = document.createElement('script');
            mt_service2.async = true;
            mt_service2.src = 'https://qa-service2.sadtron.com/mtcv1/client/mtcaptcha2.min.js';
            (
              document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]
            ).appendChild(mt_service2);
          }
        )();
        """
        
        self.html = """
        <html>
        <head>
        <meta name=\"viewport\" content=\"width=device-width, shrink-to-fit=YES\">
        </head>
        <body>
        <script>
        """+self.script+"""

        </script>
        <script>
        function getToken(){
        return window.mtcaptcha.getVerifiedToken();
        }
        </script>
        <div class="mtcaptcha"/>
        </body>
        </html>
        """
    }
    
    func renderWidget(){
        webView = WKWebView(frame: self.bounds, configuration: WKWebViewConfiguration() )
        self.addSubview(webView)
        self.webView.allowsBackForwardNavigationGestures = true
        self.webView.scrollView.contentInset=UIEdgeInsets.zero
        let myurl=URL(string:self.domain)
        webView.loadHTMLString(self.html, baseURL:myurl )
    }
    
    func getVerifiedToken() -> String {
        let scriptSource = "getToken()"
        var res=""
        webView.evaluateJavaScript(scriptSource) { (result, error) in
            if result != nil {
                print(result!)
                res=result as! String
            }
            if error != nil {
                print(error!)
                res=""
            }
        }
        return res
    }
    
}

