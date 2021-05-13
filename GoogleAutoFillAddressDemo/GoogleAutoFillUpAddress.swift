//
//  GoogleAutoFillUpAddress.swift
//  DemoTemp
//
//  Created by Magic-IOS on 22/02/21.
//

import Foundation
import GooglePlaces

protocol GoogleAutoFillUpAddressProtocol : class {
    func selectedPlaceWithDetails(place:GMSPlace,strAddress : String)
}

class GoogleAutoFillUpAddress : NSObject {
    
    let placeClient = GMSPlacesClient()
    var textfield : UITextField?
    var delegate : GoogleAutoFillUpAddressProtocol?
    var dropDown = DropDown()
    var vc : UIViewController?
    
    override init() {
        super.init()
        
    }
    
    func getPlaceNamesUsingString(strLocation : String,textField:UITextField) {
        self.textfield = textField
        let token = GMSAutocompleteSessionToken.init()
        let filter = GMSAutocompleteFilter()
        filter.type = .noFilter
        
        placeClient.findAutocompletePredictions(fromQuery: strLocation, filter: filter, sessionToken: token) { [weak self] (arrPrediction, error) in
            guard let `self` = self else { return }
            if let error = error {
                self.vc?.showAlert(string: error.localizedDescription)
                self.dropDown.hide()
                return
            }
            guard let arr = arrPrediction else {
                self.dropDown.hide()
                return
            }
            DispatchQueue.main.async {
                let arrStrings = arr.compactMap({ $0.attributedFullText.string })
                self.showDropDown(anchorView: textField, arr: arrStrings) { (index, string) in
                    if arr.count > index {
                        self.getPlaceDetailsFromID(placeID: arr[index].placeID,strAddress: string)
                    }
                }
            }
            
        }
        
    }
    
    func getPlaceDetailsFromID(placeID : String,strAddress : String) {
        placeClient.lookUpPlaceID(placeID) { [weak self] (place, error) in
            guard let `self` = self else { return }
            if let error = error {
                self.vc?.showAlert(string: error.localizedDescription)
                return
            }
            guard let placeDetails = place else { return }
            self.delegate?.selectedPlaceWithDetails(place: placeDetails, strAddress: strAddress)
        }
    }
    
    func getPlaceAsPerCurrentLocation() {
        placeClient.currentPlace { [weak self] (place, error) in
            guard let `self` = self else { return }
            if let error = error {
                self.vc?.showAlert(string: error.localizedDescription)
                return
            }
            guard let placeDetails = place?.likelihoods.first?.place else { return }
            self.getPlaceDetailsFromID(placeID: placeDetails.placeID ?? "", strAddress: placeDetails.formattedAddress ?? "")
        }
    }
    
    func showDropDown(anchorView:UIView,arr:[String],direction:DropDown.Direction = .any,containerView:UIView? = nil,complation: @escaping ((Int,String)->())) {
        dropDown.isDynamicHeight = true
        dropDown.anchorView = anchorView
        dropDown.width = anchorView.frame.size.width
        dropDown.bottomOffset = CGPoint(x: 0, y: anchorView.bounds.height)
        dropDown.dataSource = arr
        dropDown.direction = direction
        dropDown.backgroundColor = .white
        dropDown.shadowColor1 = UIColor.black.withAlphaComponent(0.25)
        dropDown.selectionAction = { (index, item) in
            complation(index,item)
        }
        dropDown.dismissMode = .manual
        
        if arr.count <= 0 {
            self.dropDown.hide()
        }else {
            dropDown.show()
        }
        
        dropDown.tableView.rowHeight = UITableView.automaticDimension
        dropDown.tableView.estimatedRowHeight = 50
        dropDown.tableView.isScrollEnabled = true
        dropDown.tableView.reloadData()
        
    }
    
    /*
     self.placeClient.lookUpPlaceID(arr.first?.placeID ?? "") { (place, error) in
     print(place)
     }
     */
}
