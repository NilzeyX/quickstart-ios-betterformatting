// Copyright 2020 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import FirebaseAuth
import UIKit

class LoginController: UIViewController {
  /// Delegate that gets notified when authentication events occur
  /// The delegate receives a callback when a user successfully logs in or creates an account
  weak var delegate: LoginDelegate?

  private var loginView: LoginView { view as! LoginView }

  private var email: String { loginView.emailTextField.text! }
  private var password: String { loginView.passwordTextField.text! }

  // Hides tab bar when view controller is presented
  override var hidesBottomBarWhenPushed: Bool { get { true } set {} }

  // MARK: - View Controller Lifecycle Methods

  override func loadView() {
    view = LoginView()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    configureNavigationBar()
    configureDelegatesAndHandlers()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setTitleColor(.label)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    view.endEditing(true)
    navigationController?.setTitleColor(.systemOrange)
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    navigationController?.popViewController(animated: false)
  }

  // MARK: - User Interaction Handling

  /**
   * Dismisses the keyboard when the user taps anywhere on the view.
   * This improves usability by providing an easy way to dismiss the keyboard
   * after entering text in either the email or password field.
   */
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    view.endEditing(true)
  }

  // MARK: - Firebase 🔥

  /**
   * Authenticates a user with Firebase using email and password
   *
   * - Parameters:
   *   - email: User's email address
   *   - password: User's password
   * - Note: On successful login, calls `delegate?.loginDidOccur()` to notify the delegate
   *         On failure, displays the error to the user
   */
  private func login(with email: String, password: String) {
    Auth.auth().signIn(withEmail: email, password: password) { _, error in
      guard error == nil else { return self.displayError(error) }
      // Notify delegate that login was successful
      self.delegate?.loginDidOccur()
    }
  }

  /**
   * Creates a new user account with Firebase using email and password
   *
   * - Parameters:
   *   - email: User's email address
   *   - password: User's password
   * - Note: On successful account creation, calls `delegate?.loginDidOccur()` to notify the delegate
   *         On failure, displays the error to the user
   */
  private func createUser(email: String, password: String) {
    Auth.auth().createUser(withEmail: email, password: password) { _, error in
      guard error == nil else { return self.displayError(error) }
      // Notify delegate that account creation was successful
      self.delegate?.loginDidOccur()
    }
  }

  // MARK: - Action Handlers

  @objc
  private func handleLogin() {
    login(with: email, password: password)
  }

  @objc
  private func handleCreateAccount() {
    createUser(email: email, password: password)
  }

  // MARK: - UI Configuration

  private func configureNavigationBar() {
    navigationItem.title = "Welcome"
    navigationItem.backBarButtonItem?.tintColor = .systemYellow
    navigationController?.navigationBar.prefersLargeTitles = true
  }

  private func configureDelegatesAndHandlers() {
    loginView.emailTextField.delegate = self
    loginView.passwordTextField.delegate = self
    loginView.loginButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
    loginView.createAccountButton.addTarget(
      self,
      action: #selector(handleCreateAccount),
      for: .touchUpInside
    )
  }

  override func viewWillTransition(to size: CGSize,
                                   with coordinator: UIViewControllerTransitionCoordinator)
  {
    super.viewWillTransition(to: size, with: coordinator)
    loginView.emailTopConstraint.constant = UIDevice.current.orientation.isLandscape ? 15 : 50
    loginView.passwordTopConstraint.constant = UIDevice.current.orientation.isLandscape ? 5 : 20
  }
}

// MARK: - UITextFieldDelegate

extension LoginController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if loginView.emailTextField.isFirstResponder, loginView.passwordTextField.text!.isEmpty {
      loginView.passwordTextField.becomeFirstResponder()
    } else {
      textField.resignFirstResponder()
    }
    return true
  }
}
