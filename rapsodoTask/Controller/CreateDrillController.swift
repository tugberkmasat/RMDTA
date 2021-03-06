//
//  CreateDrillController.swift
//  rapsodoTask
//
//  Created by Çağrı Tuğberk MASAT on 6.01.2020.
//

import UIKit
import CoreData

class CreateDrillController: UIViewController {
    
   
    let buttonBorder = ButtonBorder()
    
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var courtImage: UIImageView!
    @IBOutlet weak var drillName: UITextField!
    @IBOutlet weak var drillDuration: UITextField!
    @IBOutlet weak var drillDatePicker: UITextField!
    
    var datePicker: UIDatePicker?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        buttonBorder.addBorder(selectedButton: submitButton)
        buttonBorder.addBorder(selectedButton: cancelButton)
      
        
        customizeStarterSettings()
        
    }
    
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer){
        view.endEditing(true)
        
    }
    
    
    @objc func dateChanged(datePicker: UIDatePicker){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        drillDatePicker.text = dateFormatter.string(from: datePicker.date)
       
    }
    
    func customizeStarterSettings(){
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
           courtImage.isUserInteractionEnabled = true
           courtImage.addGestureRecognizer(tapGestureRecognizer)
           courtImage.image = UIImage(named: "court")
        
           datePicker = UIDatePicker()
           datePicker?.datePickerMode = .date
           datePicker?.addTarget(self, action: #selector(CreateDrillController.dateChanged(datePicker:)), for: .valueChanged)
           let tapGesture = UITapGestureRecognizer(target: self, action: #selector(CreateDrillController.viewTapped(gestureRecognizer:)))
           view.addGestureRecognizer(tapGesture)
           drillDatePicker.inputView = datePicker
    }
    
    func testInputs() -> Bool {
        if(drillName.text != "" && drillDuration.text != "" && drillDatePicker.text != ""){
            if(-1 != getInt(drillDuration.text!)){
                return true
            }
        }
        return false
    }
    
    func getInt(_ data:String) -> Int{
        return Int(data) ?? -1
    }
    
    //MARK: Yellow Dot Creator
     @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer){
            let cgpoint = tapGestureRecognizer.location(in: courtImage)
          
            let targetDot = UIButton()
            targetDot.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
            targetDot.center.x = cgpoint.x
            targetDot.center.y = cgpoint.y  
            targetDot.layer.cornerRadius = 0.5 * targetDot.bounds.size.width
            targetDot.backgroundColor = UIColor(red: 255.0/255.0, green: 217.0/255.0, blue: 102.0/255.0, alpha: 1.0)
        
        
            targetDot.addTarget(self, action: #selector(clickedOnImage), for: .touchUpInside)
            self.courtImage.addSubview(targetDot)
        
        }
    
    //MARK: Delete the dots by touching
    @objc func clickedOnImage(uiButton: UIButton){
        uiButton.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
    }
    
    //MARK: Merge the CourtImage and Yellow Dots
    func getImage(from view:UIView) -> UIImage? {

            defer { UIGraphicsEndImageContext() }
            UIGraphicsBeginImageContextWithOptions(view.frame.size, false, UIScreen.main.scale)
            guard let context =  UIGraphicsGetCurrentContext() else { return nil }
            view.layer.render(in: context)
            return UIGraphicsGetImageFromCurrentImageContext()
        }
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        
        if(true == testInputs()){
            
            let finalImage: UIImage = getImage(from: courtImage)!
                let result = convertImageToBase64(image: finalImage)
               
                
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
                let managedContext = appDelegate.persistentContainer.viewContext
                let userEntity = NSEntityDescription.entity(forEntityName: "Task", in: managedContext)!
                let scheduledTask = NSManagedObject(entity: userEntity, insertInto: managedContext)
                scheduledTask.setValue(drillName.text, forKeyPath: "taskName")
                scheduledTask.setValue(Int(drillDuration.text!), forKey: "taskDuration")
                scheduledTask.setValue(result, forKey: "taskImage")
                scheduledTask.setValue(drillDatePicker.text, forKey: "taskDate")
              
            
                
                do {
                    try managedContext.save()
                    performSegue(withIdentifier: "submittedSuccessfully", sender: self)
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
              
            
        } else {
            print("error")
        }
          
    }
    
    //MARK: Convert Final Image to base64
    func convertImageToBase64(image: UIImage) -> String {
        let imageData = image.pngData()!
        return imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
    }
    
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    

}
