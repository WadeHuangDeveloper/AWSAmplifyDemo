//
//  AuthenticationViewController.swift
//  AWSAmplifyDemo
//
//  Created by Huei-Der Huang on 2024/2/23.
//

import UIKit
import Amplify

class SignUpViewController: UIViewController {
    
    private var alertController: UIAlertController?
    
    // MARK: -IBOutlets
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet var requiredLabels: [UILabel]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initializeUI()
    }
    
    // MARK: - IBActions
    
    @IBAction func signUpClicked(_ sender: Any) {
        guard let username = usernameTextField.text,
              let password = passwordTextField.text,
              let email = emailTextField.text else {
            return
        }
        
        requiredLabels[0].isHidden = username != "" ? true : false
        requiredLabels[1].isHidden = password != "" ? true : false
        requiredLabels[2].isHidden = email != "" ? true : false
        
        if requiredLabels.first(where: { $0.isHidden == false }) == nil {
            Task {
                await signUp(username: username, password: password, email: email)
            }
        }
    }
    
    // MARK: - Methods
    
    private func initializeUI() {
        usernameTextField.text = ""
        usernameTextField.delegate = self
        passwordTextField.text = ""
        passwordTextField.isSecureTextEntry = true
        passwordTextField.delegate = self
        emailTextField.text = ""
        emailTextField.delegate = self
        
        requiredLabels.forEach({ $0.isHidden = true })
    }
    
    private func moveToSignInViewController() {
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController {
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    private func moveToConfirmCodeViewController() {
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmCodeViewController") as? ConfirmCodeViewController,
           let username = usernameTextField.text,
           let password = passwordTextField.text {
            controller.setUserInfo(username: username, password: password)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    private func moveToUserViewController() {
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "UserViewController") as? UserViewController {
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    private func showAlert(message: String) {
        alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        if let alertController = alertController {
            let action = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(action)
            present(alertController, animated: true)
        }
    }
    
    private func dismissLoadingAlert() {
        alertController?.dismiss(animated: true)
    }
    
    func signUp(username: String, password: String, email: String) async {
        let userAttributes = [AuthUserAttribute(.phoneNumber, value: username), AuthUserAttribute(.email, value: email)]
        let options = AuthSignUpRequest.Options(userAttributes: userAttributes)
        do {
            let signUpResult = try await Amplify.Auth.signUp(
                username: username,
                password: password,
                options: options
            )
            if case let .confirmUser(deliveryDetails, additionalInfo, userId) = signUpResult.nextStep {
                print("Delivery details \(String(describing: deliveryDetails)), additionalInfo: \(additionalInfo?.description ?? "") for userId: \(String(describing: userId))")
                
                // Next, Confirm sign up with confirm code in your Email
                moveToConfirmCodeViewController()
            } else {
                print("SignUp Complete")
                moveToSignInViewController()
            }
        } catch let error as AuthError {
            print("An error occurred while registering a user \(error)")
            showAlert(message: error.errorDescription)
        } catch {
            print("Unexpected error: \(error)")
            showAlert(message: error.localizedDescription)
        }
    }
}

extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
