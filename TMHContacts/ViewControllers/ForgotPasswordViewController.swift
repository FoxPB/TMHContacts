//
//  ForgotPasswordViewController.swift
//  TMHContacts
//
//  Created by Ricardo Caldeira on 13/07/19.
//  Copyright © 2019 Ricardo Caldeira. All rights reserved.
//

import UIKit
import FirebaseAuth

class ForgotPasswordViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var btnChangePassword: UIButton!
    
    @IBAction func btnChangePassword(_ sender: Any) {
        
        if let emailR = self.emailTextField.text {
            
            let autenticacao = Auth.auth()
            
            //envia um email para redefinicao de senha do usuario
            autenticacao.sendPasswordReset(withEmail: emailR) { (erro) in
                
                if erro != nil {
                    let alerta = Alerta(titulo: "Incorrect data", mensagem: "Check the data and re-enter")
                    self.present(alerta.getAlerta(), animated: true, completion: nil)
                }else{
                    self.performSegue(withIdentifier: "voltarEntrar", sender: nil)
                    
                    //descobrir depois porque so esta executando a primeira opcao depois do Else, ou ele envia para outra tela ou da o alert
                    let alerta = UIAlertController(title: "E-mail sent", message: "Check your email box to reset the password", preferredStyle: .alert)
                    
                    let cancelar = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                   
                    alerta.addAction(cancelar)
                    
                    self.present(alerta, animated: true, completion: nil)
                }
                
            }
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // esse metodo e chamado SEMRPE que a tela for apresentada ao usuario
    override func viewWillAppear(_ animated: Bool) {
        
        //com esse metodo a gente "esconde" a barra de navegacao da tela
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

}
