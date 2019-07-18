//
//  CreateAccountViewController.swift
//  TMHContacts
//
//  Created by Ricardo Caldeira on 13/07/19.
//  Copyright © 2019 Ricardo Caldeira. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class CreateAccountViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var passwordConfirmTextField: UITextField!
    
    @IBOutlet weak var btnSignUP: UIButton!
    let autenticacao = Auth.auth()
    let database = Database.database().reference()
    
    
    @IBAction func btnSignUPAction(_ sender: Any) {
        criarConta()
    }
    
    func criarConta() {
        
        //recuperando dados digitados
        if let emailR = self.emailTextField.text {
            if let nomeCompletoR = self.nameTextField.text {
                if let senhaR = self.passwordTextField.text {
                    if let senhaConfirmarR = self.passwordConfirmTextField.text {
                        
                        //validando as senhas iguais
                        if senhaR == senhaConfirmarR {
                            
                            if nomeCompletoR != "" {
                                
                                //criar conta no fireBase
                                
                                self.autenticacao.createUser(withEmail: emailR, password: senhaR) { (usuario, erro) in
                                    
                                    if erro == nil {
                                        
                                        if usuario == nil {
                                            //Usuario nulo retorna um alerta na tela do usuario
                                            let alerta = Alerta(titulo: "Erro ao Autenticar", mensagem: "Problema ao realizar a autenticacao, tente novamente")
                                            self.present(alerta.getAlerta(), animated: true, completion: nil)
                                        }else{
                                            
                                            //criando um nó usuarios
                                            let usuarios = self.database.child("usuarios")
                                            
                                            //criando um dicionario pra setar os valores do usuario no banco
                                            let usuariosDados = [
                                                "nome": nomeCompletoR,
                                                "email": emailR
                                            ]
                                            
                                            //Criando mais um nó de com ID do usuario e setando os valores nesse nó
                                            usuarios.child(usuario!.user.uid).setValue(usuariosDados)
                                            
                                        }
                                        
                                    }else{
                                        
                                        // tratando o erro de forma especial com a clasee NSError
                                        let erroR = erro! as NSError
                                        if let codigoErro = erroR.userInfo["error_name"] {
                                            
                                            let erroTexto = codigoErro as! String
                                            var mensagemErro = ""
                                            switch erroTexto {
                                                
                                            case "ERROR_INVALID_EMAIL" :
                                                mensagemErro = "E-mail inválido, digite um e-mail válido."
                                                break
                                                
                                            case "ERROR_WEAK_PASSWORD" :
                                                mensagemErro = "Senha precisa ter no minimo 6 caracteres, com letras e numeros"
                                                break
                                                
                                            case "ERROR_EMAIL_ALREADY_IN_USE" :
                                                mensagemErro = "E-mail já esta sendo ultilizado, crie sua conta com outro email."
                                                break
                                                
                                            default:
                                                mensagemErro = "Dados digitados estão incorretos."
                                            }
                                            
                                            let alerta = Alerta(titulo: "Dados inválidos", mensagem: mensagemErro)
                                            self.present(alerta.getAlerta(), animated: true, completion: nil)
                                            
                                            
                                        }
                                    }
                                }//Fim da validacao do FireBase
                                
                            }else{
                                let alerta = Alerta(titulo: "Dados incorretos", mensagem: "Digite seu nome para proseguir!")
                                self.present(alerta.getAlerta(), animated: true, completion: nil)
                            }//Fim da validacao de nome
                            
                        }else{
                            let alerta = Alerta(titulo: "Dados incorretos", mensagem: "As senhas não estão iguais digite novamente.")
                            self.present(alerta.getAlerta(), animated: true, completion: nil)
                        }//fim da validacao da senha
                        
                    }
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
