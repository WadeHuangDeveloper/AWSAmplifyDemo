//
//  UserViewController.swift
//  AWSAmplifyDemo
//
//  Created by Huei-Der Huang on 2024/2/26.
//

import UIKit
import Amplify
import AWSCognitoAuthPlugin

class UserViewController: UIViewController {
    
    private var userAttributes: [AuthUserAttribute] = []
    private var userInfos = ["Email", "Phone Number"]

    @IBOutlet weak var userAttributeTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initializeUI()
        
        Task {
            await fetchAttributes()
        }
    }
    
    @IBAction func setting(_ sender: Any) {
    }
    
    private func initializeUI() {
        userAttributeTableView.dataSource = self
        userAttributeTableView.delegate = self
        userAttributeTableView.rowHeight = 80
    }
    
    private func moveToSignInViewController() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func fetchAttributes() async {
        do {
            let attributes = try await Amplify.Auth.fetchUserAttributes()
            print("User attributes - \(attributes)")
            self.userAttributes = attributes
            userAttributeTableView.reloadData()
            /*
            for attribute in attributes {
                switch attribute.key {
                case .email:
                    print("Email: \(attribute.value)")
                case .emailVerified:
                    print("Email verified: \(attribute.value)")
                case .phoneNumber:
                    print("Phone number: \(attribute.value)")
                case .phoneNumberVerified:
                    print("Phone number verified: \(attribute.value)")
                default:
                    break
                }
            }
            */
        } catch let error as AuthError{
            print("Fetching user attributes failed with error \(error)")
        } catch {
            print("Unexpected error: \(error)")
        }
    }
}

extension UserViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userInfos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "UserAttributeTableViewCell") as? UserAttributeTableViewCell,
           userAttributes.count > 0 {
            switch indexPath.row {
            case 0:
                if let userAttribute = userAttributes.first(where: { $0.key == .email }) {
                    cell.attributeTextField.text = userAttribute.value
                }
                if let userAttribute = userAttributes.first(where: { $0.key == .emailVerified }) {
                    cell.titleLabel.text = userAttribute.value == "true" ? "Email ✅" : "Email ❌"
                }
            case 1:
                if let userAttribute = userAttributes.first(where: { $0.key == .phoneNumber }) {
                    let visibleText = String(userAttribute.value.prefix(7))
                    let maskedText = String(repeating: "*", count: 6)
                    cell.attributeTextField.text = visibleText + maskedText
                }
                if let userAttribute = userAttributes.first(where: { $0.key == .phoneNumberVerified }) {
                    cell.titleLabel.text = userAttribute.value == "true" ? "Phone Number ✅" : "Phone Number ❌"
                }
            default:
                break
            }
            return cell
        }
        
        return UITableViewCell()
    }
    
    
}
