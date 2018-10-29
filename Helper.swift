//
//  Helper.swift
//  Retail365cloud
//
//  Created by Citta's iMac1 on 21/08/18.
//  Copyright © 2018 Citta's iMac1. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD

class Helper: NSObject {

    static func setContiner(VC aVC: String, parent : UIViewController, container : UIView){
        guard let aVC = parent.storyboard?.instantiateViewController(withIdentifier: aVC) else { return }
        
        for aView in container.subviews{
            aView.removeFromSuperview()
        }
        
        for aChildVC in parent.childViewControllers{
            aChildVC.removeFromParentViewController()
        }
        
        aVC.view.frame = container.bounds
        container.addSubview(aVC.view)
        parent.addChildViewController(aVC)
    }
    
    class API : NSObject {
       static func requestPost(url aUrl: String, paramter: [String:Any]?, isSilent:Bool = false, completion : (([String:Any]?,Error?) ->())?){
        
        request(url: aUrl, paramter: paramter, method: .post, isSilent: isSilent, completion: completion)
        
        }
        
        /// Call API with GET request
        static func requestGet(url aUrl: String, paramter: [String:Any]?, isSilent:Bool = false, completion : (([String:Any]?,Error?) ->())?){
            
            request(url: aUrl, paramter: paramter, method: .get, isSilent: isSilent, completion: completion)
            
        }
        
        private static func request(url aUrl: String, paramter: [String:Any]?, method:HTTPMethod, isSilent:Bool = false, completion : (([String:Any]?,Error?) ->())?){
            
            let aCurrentVC = Constant.appDel.window?.rootViewController
            
            if !isSilent{
                SVProgressHUD.show()
                aCurrentVC?.view.isUserInteractionEnabled = false
            }
            
            Alamofire.request(aUrl, method: method, parameters: paramter, encoding: URLEncoding.default, headers: nil).responseJSON { (aJsonResponse) in
                if !isSilent{
                    SVProgressHUD.dismiss()
                    aCurrentVC?.view.isUserInteractionEnabled = true
                }
                
                print("=============================================")
                print("URL -> \(aUrl)")
                print("URL -> \(paramter ?? [:])")
                print("=============================================")
                
                guard aJsonResponse.result.error == nil else{
                    //                    print ("Error ->\(aJsonResponse.result.error!)")
                    completion?(nil,aJsonResponse.result.error!)
                    return
                }
                
                
                
                guard let aDicResponse = aJsonResponse.result.value as? [String:Any] else {
                    return
                }
                
                completion?(aDicResponse,nil)
                
            }
        }
    }
    struct Request {
        
        static func post(url: String, parameter : [String:Any]?, callSilently : Bool = false , header : HTTPHeaders? = nil, completionBlock : (([String:Any]?,Error?)->())?){
            
            request(url: url, type: .post, parameter: parameter, callSilently :callSilently, header: header, completionBlock: completionBlock)
        }
        
        static func get(url: String, parameter : [String:Any]?, header : HTTPHeaders? = nil, callSilently : Bool = false, encoding:ParameterEncoding = JSONEncoding.default, completionBlock : (([String:Any]?,Error?)->())?){
            
            request(url: url, type: .get, parameter: parameter, callSilently :callSilently, header: header, encoding: encoding, completionBlock: completionBlock)
        }
        
        private static func request(url: String, type : HTTPMethod, parameter : [String:Any]?, callSilently : Bool = false, header : HTTPHeaders? = nil,encoding:ParameterEncoding = JSONEncoding.default, completionBlock : (([String:Any]?,Error?)->())?){
            
            guard let aUrl = URL(string: url) else { return }
            
            print("========================================")
            print("API -> \(url)")
            print("Param -> \(parameter ?? [:])")
            print("========================================")
            
            let aController : UIViewController? = Constant.appDel.window?.rootViewController as? UINavigationController ?? Constant.appDel.window?.rootViewController
            
            if !callSilently{
                SVProgressHUD.show()
                aController?.view.isUserInteractionEnabled = false
            }
            
            Alamofire.request(aUrl, method: type, parameters: parameter, encoding: encoding, headers: header).responseJSON { (aResponse) in
                
                if !callSilently{
                    SVProgressHUD.dismiss()
                    aController?.view.isUserInteractionEnabled = true
                }
                
                guard aResponse.error == nil else {
                    completionBlock?(nil,aResponse.error)
                    return
                }
                
                guard let aDicResponse = aResponse.result.value as? [String:Any] else {
                    completionBlock?(nil,aResponse.error)
                    return
                }
                
                completionBlock?(aDicResponse,aResponse.error)
            }
        }
    }
    
    //MARK:- Email Validation
    
    static func isValidEmailAddress(emailAddressString: String) -> Bool {
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = emailAddressString as NSString
            let results = regex.matches(in: emailAddressString, range: NSRange(location: 0, length: nsString.length))
                if results.count == 0{
                    returnValue = false
                    }
            
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            returnValue = false
            
        }
            return  returnValue
    }
}
