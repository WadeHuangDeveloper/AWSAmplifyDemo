//
//  SettingsViewController.swift
//  AWSAmplifyDemo
//
//  Created by Huei-Der Huang on 2024/2/29.
//

import UIKit
import Amplify
import AWSCognitoAuthPlugin

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func signOutLocallyClicked(_ sender: Any) {
        Task {
            await signOutLocally()
        }
    }
    
    @IBAction func signOutGloballyClicked(_ sender: Any) {
        Task {
            await signOutGlobally()
        }
    }
    
    @IBAction func deleteAccount(_ sender: Any) {
        Task {
            await deleteUser()
        }
    }
    
    private func moveToSignInViewController() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func signOutLocally() async {
        let result = await Amplify.Auth.signOut()
        guard let signOutResult = result as? AWSCognitoSignOutResult else {
            print("Signout failed")
            return
        }

        print("Local signout successful: \(signOutResult.signedOutLocally)")
        switch signOutResult {
        case .complete:
            // Sign Out completed fully and without errors.
            print("Signed out successfully")

        case let .partial(revokeTokenError, globalSignOutError, hostedUIError):
            // Sign Out completed with some errors. User is signed out of the device.
            
            if let hostedUIError = hostedUIError {
                print("HostedUI error \(hostedUIError.error.errorDescription)")
            }

            if let globalSignOutError = globalSignOutError {
                // Optional: Use escape hatch to retry revocation of globalSignOutError.accessToken.
                print("GlobalSignOut error  \(globalSignOutError.error.errorDescription)")
            }

            if let revokeTokenError = revokeTokenError {
                // Optional: Use escape hatch to retry revocation of revokeTokenError.accessToken.
                print("Revoke token error  \(revokeTokenError.error.errorDescription)")
            }

        case .failed(let error):
            // Sign Out failed with an exception, leaving the user signed in.
            print("SignOut failed with \(error)")
        }
        moveToSignInViewController()
    }
    
    func signOutGlobally() async {
        let result = await Amplify.Auth.signOut(options: .init(globalSignOut: true))
        guard let signOutResult = result as? AWSCognitoSignOutResult else {
            print("Signout failed")
            return
        }

        print("Local signout successful: \(signOutResult.signedOutLocally)")
        switch signOutResult {
        case .complete:
            // handle successful sign out
            print("Successful sign out")        
        case .failed(let error):
            // handle failed sign out
            print("Failed sign out with \(error)")
        case let .partial(revokeTokenError, globalSignOutError, hostedUIError):
            // handle partial sign out
            print("Partial sign out with")
            print("revokeTokenError \(revokeTokenError.debugDescription)")
            print("globalSignOutError \(globalSignOutError.debugDescription)")
            print("hostedUIError \(hostedUIError.debugDescription)")
        }
        moveToSignInViewController()
    }
    
    func deleteUser() async {
        do {
            try await Amplify.Auth.deleteUser()
            print("Successfully deleted user")
        } catch let error as AuthError {
            print("Delete user failed with error \(error)")
        } catch {
            print("Unexpected error: \(error)")
        }
        
        moveToSignInViewController()
    }
}
