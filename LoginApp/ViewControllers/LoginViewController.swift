//
//  ViewController.swift
//  Lesson 2.6
//
//  Created by Artem on 3/21/25.
//

import UIKit


final class LoginViewController: UIViewController {

    @IBOutlet var userNameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    //Т.к. у нас есть логин и пароль логично иметь несколько пользователей для входа
    private let repo: UserRepository = MockDatabase()
    private var user: User?

    override func viewDidLoad() {
        fillInLoginPassword()
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard let username = userNameTextField.text else { return false }
        guard let password = passwordTextField.text else { return false }
        
        guard let user = getUser(username: username, password: password) else {
            showAllert(
                withTitle: "Invalid login or password",
                andMessage: "Please, enter correct login or password") {
                    self.passwordTextField.text = ""
            }
            return false
        }
        
        self.user = user
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tabBarVC = segue.destination as? TabBarViewController {
            tabBarVC.user = user
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
    
    @IBAction func unwind(for segue: UIStoryboardSegue) {
        userNameTextField.text = ""
        passwordTextField.text = ""
        user = nil
    }
    
    @IBAction func showHint(sender: UIButton) {
        let message = repo.allUsers.map {
            sender.tag == 11 ? "\($0.username): \($0.password)" : $0.username
        }.joined(separator: "\n")
        
        showAllert(withTitle: "Secret data", andMessage: message)
    }

    private func getUser(username: String, password: String) -> User? {
        guard !(username.isEmpty && password.isEmpty) else { return nil }
        
        guard let user = repo.allUsers.first(where: { $0.username == username }),
              user.password == password else { return nil }
        
        return user
    }
    
    private func showAllert(withTitle title: String, andMessage message: String, closure: (() -> Void)? = nil) {
        let action = UIAlertAction(title: "OK", style: .default) { _ in
            closure?()
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    private func fillInLoginPassword() {
        let user = repo.allUsers.randomElement()
        userNameTextField.text = user?.username
        passwordTextField.text = user?.password
    }
}

