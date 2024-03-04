//
//  SignInViewController.swift
//  AWSAmplifyDemo
//
//  Created by Huei-Der Huang on 2024/2/23.
//

import UIKit
import Amplify

class SignInViewController: UIViewController {
    
    private var username: String?
    private var password: String?
    private var alertController: UIAlertController?
    
    // MARK: -IBOutlets
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet var requiredLabels: [UILabel]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeUI()
        
        Task {
            await fetchCurrentAuthSession()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let username = username, let password = password else {
            return
        }
        
        Task {
            await signIn(username: username, password: password)
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func signInClicked(_ sender: Any) {
        guard let username = usernameTextField.text,
              let password = passwordTextField.text else {
            return
        }
        
        requiredLabels[0].isHidden = username != "" ? true : false
        requiredLabels[1].isHidden = password != "" ? true : false
        
        if requiredLabels.first(where: { $0.isHidden == false }) == nil {
            Task {
                await signIn(username: username, password: password)
            }
        }
    }
    
    @IBAction func signUpClicked(_ sender: Any) {
        moveToSignUpViewController()
    }
    
    // MARK: - Methods
    
    private func initializeUI() {
        usernameTextField.text = ""
        usernameTextField.delegate = self
        passwordTextField.text = ""
        passwordTextField.isSecureTextEntry = true
        passwordTextField.delegate = self
        
        requiredLabels.forEach { $0.isHidden = true }
    }
    
    private func showAlert(message: String?) {
        alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        if let alertController = alertController {
            let action = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(action)
            present(alertController, animated: true)
        }
    }
    
    private func showLoadingAlert() {
        alertController = UIAlertController(title: "Please wait..", message: nil, preferredStyle: .alert)
        if let alertController = alertController {
            let activityIndicator = UIActivityIndicatorView(style: .large)
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            activityIndicator.isUserInteractionEnabled = false
            activityIndicator.startAnimating()
            alertController.view.addSubview(activityIndicator)
            activityIndicator.leadingAnchor.constraint(equalTo: alertController.view.leadingAnchor, constant: 20).isActive = true
            activityIndicator.centerYAnchor.constraint(equalTo: alertController.view.centerYAnchor).isActive = true
            present(alertController, animated: true)
        }
    }
    
    private func dismissLoadingAlert() {
        alertController?.dismiss(animated: true)
    }
    
    private func fetchCurrentAuthSession() async {
        do {
            let session = try await Amplify.Auth.fetchAuthSession()
            print("Is user signed in - \(session.isSignedIn)")
            
            if session.isSignedIn == true {
                moveToUserViewController()
            }
        } catch let error as AuthError {
            print("Fetch session failed with error \(error)")
        } catch {
            print("Unexpected error: \(error)")
        }
    }
    
    private func moveToSignUpViewController() {
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController {
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    private func moveToConfirmCodeViewController() {
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmCodeViewController") as? ConfirmCodeViewController,
            let username = username,
            let password = password {
            controller.setUserInfo(username: username, password: password)
            Task {
                await controller.resendSignUpCode(username: username)
            }
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    private func moveToUserViewController() {
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "UserViewController") as? UserViewController {
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func setUserInfo(username: String, password: String) {
        self.username = username
        self.password = password
    }
    
    func signIn(username: String, password: String) async {
        showLoadingAlert()
        
        do {
            let signInResult = try await Amplify.Auth.signIn(
                username: username,
                password: password
                )
            dismissLoadingAlert()
            switch signInResult.nextStep {
                case .confirmSignInWithSMSMFACode(let deliveryDetails, let info):
                    print("SMS code send to \(deliveryDetails.destination)")
                    print("Additional info \(String(describing: info))")

                    // Prompt the user to enter the SMSMFA code they received
                    // Then invoke `confirmSignIn` api with the code

                case .confirmSignInWithTOTPCode:
                    print("Received next step as confirm sign in with TOTP code")

                    // Prompt the user to enter the TOTP code generated in their authenticator app
                    // Then invoke `confirmSignIn` api with the code
                
                case .continueSignInWithTOTPSetup(let setUpDetails):
                    print("Received next step as continue sign in by setting up TOTP")
                    print("Shared secret that will be used to set up TOTP in the authenticator app \(setUpDetails.sharedSecret)")
                    
                    // Prompt the user to enter the TOTP code generated in their authenticator app
                    // Then invoke `confirmSignIn` api with the code

                case .continueSignInWithMFASelection(let allowedMFATypes):
                    print("Received next step as continue sign in by selecting MFA type")
                    print("Allowed MFA types \(allowedMFATypes)")
                    
                    // Prompt the user to select the MFA type they want to use
                    // Then invoke `confirmSignIn` api with the MFA type
                
                case .confirmSignInWithCustomChallenge(let info):
                    print("Custom challenge, additional info \(String(describing: info))")
                    
                    // Prompt the user to enter custom challenge answer
                    // Then invoke `confirmSignIn` api with the answer
                
                case .confirmSignInWithNewPassword(let info):
                    print("New password additional info \(String(describing: info))")
                    
                    // Prompt the user to enter a new password
                    // Then invoke `confirmSignIn` api with new password
                
                case .resetPassword(let info):
                    print("Reset password additional info \(String(describing: info))")
                    
                    // User needs to reset their password.
                    // Invoke `resetPassword` api to start the reset password
                    // flow, and once reset password flow completes, invoke
                    // `signIn` api to trigger signin flow again.
                
                case .confirmSignUp(let info):
                    print("Confirm signup additional info \(String(describing: info))")
                    
                    // User was not confirmed during the signup process.
                    // Invoke `confirmSignUp` api to confirm the user if
                    // they have the confirmation code. If they do not have the
                    // confirmation code, invoke `resendSignUpCode` to send the
                    // code again.
                    // After the user is confirmed, invoke the `signIn` api again.
                    setUserInfo(username: username, password: password)
                    moveToConfirmCodeViewController()
                case .done:
                    
                    // Use has successfully signed in to the app
                    print("Signin complete")
            }
            if signInResult.isSignedIn {
                print("Sign in succeeded")
                setUserInfo(username: username, password: password)
                moveToUserViewController()
            }
        } catch let error as AuthError {
            print("Sign in failed \(error)")
            dismissLoadingAlert()
            showAlert(message: error.errorDescription)
        } catch {
            print("Unexpected error: \(error)")
            dismissLoadingAlert()
        }
    }

}

extension SignInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
