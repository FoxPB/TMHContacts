//
//  LoginViewController.swift
//  TMHContacts
//
//  Created by Ricardo Caldeira on 13/07/19.
//  Copyright © 2019 Ricardo Caldeira. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var btnSignIn: UIButton!
    var auth: Auth!
    
    @IBAction func btnSignInAction(_ sender: Any) {
        
        do {
            try
            logar()
        } catch {
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Login automatico
        self.auth = Auth.auth()
        
        //Adicionar ouvinte de usuario autenticado
        self.auth.addStateDidChangeListener { (autenticacao, usuario) in
            
            if usuario != nil {
                self.performSegue(withIdentifier: "mapViewSegue", sender: nil)
            }
            
        }
        
    }
    
    private func logar(){
        
        //Recuperar dados digitados
        if let emailR = self.emailTextField.text {
            if let senhaR = self.passwordTextField.text {
                
                //Autenticar usuario no firebase
                auth = Auth.auth()
                auth.signIn(withEmail: emailR, password: senhaR) { (usuario, erro) in
                    
                    //tratar se tivemos erro
                    if erro == nil {//nao teve erro
                        
                        //tratando se temos um usuario com este login
                        if usuario == nil{
                            let alerta = Alerta(titulo: "Erro ao Autenticar", mensagem: "Problema ao realizar a autenticacao, tente novamente")
                            self.present(alerta.getAlerta(), animated: true, completion: nil)
                        }else{//se deu certo vai cair nesse else ai o ouvinte vai jogar na outra tela
                        
                        }
                        
                    }else{//houve erro
                        let alerta = Alerta(titulo: "Dados incorretos", mensagem: "Verifique os dados digitados e tente novamente")
                        self.present(alerta.getAlerta(), animated: true, completion: nil)
                        
                    }
                    
                }
            }
        }
        
    }
    
    //Metodo usado para fechar o teclado quando o usuario clica em outro lugar da tela que nao seja no TextField
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // esse metodo e chamado SEMRPE que a tela for apresentada ao usuario
    override func viewWillAppear(_ animated: Bool) {
        
        //com esse metodo a gente "esconde" a barra de navegacao da tela
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }


}
