//
//  LoginViewController.swift
//  TouchID
//
//  Created by Pablo Mateo Fernández on 02/02/2017.
//  Copyright © 2017 355 Berry Street S.L. All rights reserved.
//

import UIKit
import LocalAuthentication

class LoginViewController: UIViewController {
//Ir a la raiz, a build phases y añadir el framework en link binnary with libraries
    //Local Authentication (Framework)
        //LAContext
            //canEvaluatePolicy
            //evaluatePolicy   
                //Muestra la ventana de dialogo para desbloquear el terminal  
    @IBOutlet weak var backgroundImageView:UIImageView!
    @IBOutlet weak var loginView:UIView!
    @IBOutlet weak var emailTextField:UITextField!
    @IBOutlet weak var passwordTextField:UITextField!
    
    private var imageSet = ["cloud", "coffee", "food", "pmq", "temple"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Randomly pick an image
        let selectedImageIndex = Int(arc4random_uniform(5))
        
        // Apply blurring effect
        backgroundImageView.image = UIImage(named: imageSet[selectedImageIndex])
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        backgroundImageView.addSubview(blurEffectView)
        
        loginView.isHidden = true
        authenticateWithTouchID()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Helper methods

    func showLoginDialog() {
        // Move the login view off screen
        loginView.isHidden = false
        loginView.transform = CGAffineTransform(translationX: 0, y: -700)
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            
            self.loginView.transform = CGAffineTransform.identity
            
        }, completion: nil)
        
    }
    
    func authenticateWithTouchID(){
        //Authentication COntext
        let localAuthContext = LAContext()
        let razon = "Accede con TouchID a tu perfil"
        var authError: NSError?
        
        if !localAuthContext.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &authError){
            if let error = authError {
                print(error.localizedDescription)
            }
            showLoginDialog()
            return
        }
        //Identificar al usuario con TouchID
        localAuthContext.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: razon) { (success, error) in
            //Fallo al identificar
            if !success{
                if let error = error {
                    switch error {
                    case LAError.authenticationFailed:
                        print("Authentication failed")
                    case LAError.passcodeNotSet:
                        print("Passcode not set")
                    case LAError.systemCancel:
                        print("Authentication canceled by system")
                    case LAError.userCancel:
                        print("Authentication canceled by user")
                    case LAError.touchIDNotEnrolled:
                        print("No hay info biométrica disponible")
                    case LAError.touchIDNotAvailable:
                        print("TouchID no disponible")
                    case LAError.userFallback:
                        print("Usuario prefiere usar contraseña")
                    default:
                        print(error.localizedDescription)
                    }
                }
                // if!success lo hace en el backgroundThread y como esta en un hilo y queremos hacer cambios en la interfaz tenemos que salir al hilo principal con el operationQueue
                //Ir hacia atrás al Login
                OperationQueue.main.addOperation {
                    self.showLoginDialog()
                }
            } else {
                //Ha funcionado
                print("Autenticacion ha funcionado")
                OperationQueue.main.addOperation {
                    self.performSegue(withIdentifier: "showHomeScreen", sender: nil)
                }
            }
        }
    }
    
    @IBAction func authenticateWithPassword(){
        if emailTextField.text == "pablo@gmail.com" && passwordTextField.text == "1234" {
            performSegue(withIdentifier: "showHomeScreen", sender: nil)
        } else {
            //Shake
            loginView.transform = CGAffineTransform(translationX: 25, y: 0)
            UIView.animate(withDuration: 0.2, delay: 0.0, usingSpringWithDamping: 0.15, initialSpringVelocity: 0.3, options: .curveEaseInOut, animations: {
                self.loginView.transform = CGAffineTransform.identity
                }, completion: nil)
        }
    }
}
