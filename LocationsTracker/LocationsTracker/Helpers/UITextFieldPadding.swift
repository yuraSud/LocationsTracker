//
//  UITextFieldPadding.swift
//  Movies
//
//  Created by Olga Sabadina on 05.01.2024.
//

import UIKit
import Combine

class UITextFieldPadding: UITextField {
    
    let padding = UIEdgeInsets(top: 20, left: 16, bottom: 5, right: 70)
    var rightStack = UIStackView()
    let clearButton = UIButton(type: .system)
    let eyeButton = UIButton(type: .system)
    let emailImage = UIImageView()
    var isSequreText = true
    var placeHolderCustomLabel = UILabel()
    var activityIndicator: UIActivityIndicatorView?
    @Published var isClearText = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupRightStack()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    func configureCustomPlaceholder(text: String, frame: CGRect) {
        self.addSubview(placeHolderCustomLabel)
        placeHolderCustomLabel.frame = frame
        placeHolderCustomLabel.text = text
        placeHolderCustomLabel.textColor = .lightGray
        placeHolderCustomLabel.font = .systemFont(ofSize: 15)
        
        self.autocapitalizationType = .none
        self.autocorrectionType = .no
    }
    
    func configureFrameCustomPlaceHolder(frame: CGRect) {
        placeHolderCustomLabel.frame = frame
    }
    
    func emailIsExists(isExists: Bool) {
        if isExists {
            emailImage.image = ImageConstants.emailOk
            emailImage.tintColor = .systemMint
            self.layer.borderColor = UIColor.green.cgColor
            placeHolderCustomLabel.textColor = .systemMint
            placeHolderCustomLabel.text = "Your email is correct"
        } else {
            emailImage.image = ImageConstants.emailOk
            emailImage.tintColor = .lightGray
            self.layer.borderColor = UIColor.gray.cgColor
            placeHolderCustomLabel.textColor = .lightGray
            placeHolderCustomLabel.text = TitleConstants.email
        }
    }
    
    func addEmailImageAndClearButton() {
        rightStack.addArrangedSubview(emailImage)
        rightStack.addArrangedSubview(clearButton)
    }
    
    func addSequreAndClearButtons() {
        self.isSecureTextEntry = isSequreText
        rightStack.addArrangedSubview(eyeButton)
        rightStack.addArrangedSubview(clearButton)
    }
    
    func setActivityIndicator() {
        activityIndicator = UIActivityIndicatorView()
        guard let activityIndicator = activityIndicator else { return }
        addSubview(activityIndicator)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
        activityIndicator.color = .blue
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        activityIndicator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -70).isActive = true
    }
    
    @objc func clearText() {
        self.text = ""
        self.isClearText.toggle()
    }
    
    @objc private func changeSequreText() {
        isSequreText.toggle()
        let imageButtonSequre = isSequreText ? ImageConstants.closeEye : ImageConstants.openEye
        eyeButton.setImage(imageButtonSequre, for: .normal)
        self.isSecureTextEntry = isSequreText
    }
    
    private func setupRightStack() {
        let rightView = UIView(frame: CGRect(x: 0, y: 15, width: 65, height: 25))
        rightStack.frame = .init(x: 0, y: 0, width: 55, height: 25)
        rightStack.tintColor = .gray
        rightStack.spacing = 5
        rightStack.distribution = .fillEqually
        rightView.addSubview(rightStack)
        self.rightView = rightView
        self.rightViewMode = .whileEditing
        
        clearButton.addTarget(self, action: #selector(clearText), for: .touchUpInside)
        clearButton.setImage(ImageConstants.clear, for: .normal)
        clearButton.widthAnchor.constraint(equalTo: clearButton.heightAnchor).isActive = true
        eyeButton.setImage(ImageConstants.closeEye, for: .normal)
        eyeButton.addTarget(self, action: #selector(changeSequreText), for: .touchUpInside)
        eyeButton.widthAnchor.constraint(equalTo: eyeButton.heightAnchor).isActive = true
    }
}

