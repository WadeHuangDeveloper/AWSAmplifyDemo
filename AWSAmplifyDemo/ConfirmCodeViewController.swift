//
//  SignUpAuthViewController.swift
//  AWSAmplifyDemo
//
//  Created by Huei-Der Huang on 2024/2/23.
//

import UIKit
import Amplify

class ConfirmCodeViewController: UIViewController {

    private var username: String?
    private var password: String?
    private var alertController: UIAlertController?
    
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var requiredLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeUI()
    }
    
    @IBAction func confirmClicked(_ sender: Any) {
        view.endEditing(true)
        
        guard let username = username,
              password != nil,
              let code = codeTextField.text else {
            requiredLabel.isHidden = false
            return
        }
        
        Task {
            await confirmSignUp(for: username, with: code)
        }
        
    }
    
    // MARK: - Methods
    
    private func initializeUI() {
        codeTextField.text = ""
        codeTextField.delegate = self
        codeTextField.becomeFirstResponder()
        requiredLabel.isHidden = true
    }
    
    private func moveToSignInViewController() {
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController,
           let username = username,
           let password = password {
            controller.setUserInfo(username: username, password: password)
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    private func moveToUserViewController() {
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "UserViewController") as? UserViewController {
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    private func showAlert(message: String?) {
        alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        if let alertController = alertController {
            let action = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(action)
            present(alertController, animated: true)
        }
    }
    
    func setUserInfo(username: String, password: String) {
        self.username = username
        self.password = password
    }
    
    func confirmSignUp(for username: String, with confirmationCode: String) async {
        do {
            let confirmSignUpResult = try await Amplify.Auth.confirmSignUp(
                for: username,
                confirmationCode: confirmationCode
            )
            print("Confirm sign up result completed: \(confirmSignUpResult.isSignUpComplete)")
            // Next, sign in with username and password
            moveToSignInViewController()
        } catch let error as AuthError {
            print("An error occurred while confirming sign up \(error)")
            showAlert(message: error.errorDescription)
        } catch {
            print("Unexpected error: \(error)")
            showAlert(message: error.localizedDescription)
        }
    }
    
    func resendSignUpCode(username: String) async {
        do {
            let result = try await Amplify.Auth.resendSignUpCode(for: username)
            print("Resended sign up code, attributeKey: \(result.attributeKey.debugDescription), destination: \(result.destination)")
            moveToUserViewController()
        } catch let error as AuthError {
            print("An error occurred while resending sign up code \(error)")
            showAlert(message: error.errorDescription)
        } catch {
            print("Unexpected error: \(error)")
            showAlert(message: error.localizedDescription)
        }
    }
}

extension ConfirmCodeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
