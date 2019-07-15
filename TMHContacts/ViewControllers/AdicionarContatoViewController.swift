//
//  AdicionarContatoViewController.swift
//  TMHContacts
//
//  Created by Ricardo Caldeira on 15/07/19.
//  Copyright © 2019 Ricardo Caldeira. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class AdicionarContatoViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var btnAdicionar: UIButton!
    
    var auth: Auth!
    let database = Database.database().reference()
    var emailR: String!
    
    @IBAction func btnAdicionarAction(_ sender: Any) {
        
        
    }
    
    private func AddContato() {
        
        //criando um nó usuarios
        let usuarios = self.database.child("usuarios")
        
        if emailTextField.text != nil {
            self.emailR = emailTextField.text
            
            
            
        }else{
            let alerta = Alerta(titulo: "Dados incorretos", mensagem: "Verifique os dados digitados e tente novamente")
            self.present(alerta.getAlerta(), animated: true, completion: nil)
        }
        
        /*
        //Recuperar Dados do usuario logado
        if let idUsuarioLogado = self.auth.currentUser?.uid {
            
            //Setando o iD do usuario no id da imagem
            self.idImagem = idUsuarioLogado
            
            let usuarioLogado = usuarios.child(idUsuarioLogado)
            
            //Fazendo a consulta no Banco apenas uma vez com (observeSingleEvent) ao inves de fica "escutando" sempre que tiver alteracao com (observe)
            usuarioLogado.observeSingleEvent(of: DataEventType.value) { (snapshot) in
                
                let dadosUsuarioLogado = snapshot.value as? NSDictionary
                self.name.text = dadosUsuarioLogado?["nome"] as? String
                self.email.text  = dadosUsuarioLogado?["email"] as? String
                self.urlImagemRecuperada  = dadosUsuarioLogado?["urlImagem"] as? String
                
            }
        }*/
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        auth = Auth.auth()

    }
    

}
