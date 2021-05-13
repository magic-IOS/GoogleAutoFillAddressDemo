//
//  ViewController.swift
//  DemoTemp
//
//  Created by Magic-IOS on 31/12/20.
//

import UIKit
import GooglePlaces

class ViewController: UIViewController {
    
    let gmsAutoFill = GoogleAutoFillUpAddress()
    
    @IBOutlet weak var txtAddress: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gmsAutoFill.delegate = self
        txtAddress.delegate = self
        gmsAutoFill.vc = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    
}

extension ViewController : UITextFieldDelegate , CLLocationManagerDelegate {
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
           let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(setGoogleAutoPlace), object: nil)
            self.perform(#selector(setGoogleAutoPlace), with: nil, afterDelay: 2.0)

        }
        return true
    }
    
    @objc func setGoogleAutoPlace() {
        gmsAutoFill.getPlaceNamesUsingString(strLocation: txtAddress.text ?? "", textField: txtAddress)
    }
    
    
}

extension ViewController : GoogleAutoFillUpAddressProtocol {
    
    func selectedPlaceWithDetails(place: GMSPlace, strAddress: String) {
        print(strAddress)
        
        
    }
}


extension UIViewController {
    
    func showAlert(string:String,handler: (()->())? = nil) {
        let alert = UIAlertController(title: "", message: string, preferredStyle: .alert)
        let alertOkayAction = UIAlertAction(title: "Okay", style: .default) { (_) in
            handler?()
        }
        alert.addAction(alertOkayAction)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
}
