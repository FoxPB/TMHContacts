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
    
   
    @IBOutlet weak var idContact: UITextField!
    @IBOutlet weak var btnAdicionar: UIButton!
    
    var auth: Auth!
    let database = Database.database().reference()
    var IDRecuperado: String!
    
    @IBAction func btnAdicionarAction(_ sender: Any) {
        
        AddContato()

    }
    
    private func AddContato() {
        
        //criando um nó usuarios
        let usuarios = self.database.child("usuarios")
        
        if idContact.text != "" {
          
            self.IDRecuperado = idContact.text
            
            let usuarioParaAdicionar = usuarios.child(self.IDRecuperado).child("perfil")
                
            //Fazendo a consulta no Banco apenas uma vez com (observeSingleEvent) ao inves de fica "escutando" sempre que tiver alteracao com (observe)
            usuarioParaAdicionar.observeSingleEvent(of: DataEventType.value) { (snapshot) in
                
                if snapshot != nil {
                    
                    let dadosUsuarioParaAdiconar = snapshot.value as? NSDictionary
                    
                    //criando um nó usuarios
                    let usuarios = self.database.child("usuarios")
                    
                    //Recuperar Dados do usuario logado
                    if let idUsuarioLogado = self.auth.currentUser?.uid {
                        
                        let usuarioLogado = usuarios.child(idUsuarioLogado)
                        let contatosUsuarioLogado = usuarioLogado.child("contatos")
                        
                        let dados = [
                            "nome" : dadosUsuarioParaAdiconar?["nome"],
                            "email" : dadosUsuarioParaAdiconar?["email"],
                            "urlImagem" : dadosUsuarioParaAdiconar?["urlImagem"]
                        ]
                        
                        //Salvando o id do contato no nó contatos
                        contatosUsuarioLogado.child(self.IDRecuperado).setValue(dados)
                        
                        self.performSegue(withIdentifier: "segueContatos", sender: nil)
                        
                    }
                    
                }else{//ID digitado não existe
                    let alerta = Alerta(titulo: "Incorrect data", mensagem: "Confirm with your contact his id")
                    self.present(alerta.getAlerta(), animated: true, completion: nil)
                }
                
            }
            
        }else{
            let alerta = Alerta(titulo: "Incorrect data", mensagem: "Please check your typed data and try again")
            self.present(alerta.getAlerta(), animated: true, completion: nil)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        auth = Auth.auth()

    }

}
