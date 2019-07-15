//
//  ProfileViewController.swift
//  TMHContacts
//
//  Created by Ricardo Caldeira on 14/07/19.
//  Copyright © 2019 Ricardo Caldeira. All rights reserved.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {

    @IBOutlet weak var btnLogout: UIButton!
    @IBOutlet weak var imageProfile: UIImageView!
    @IBOutlet weak var btnChange: UIButton!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var email: UILabel!
    var auth: Auth!
    
    @IBAction func btnChangeAction(_ sender: Any) {
        
    }
    
    @IBAction func btnLogoutAction(_ sender: Any) {
        deslogar()
    }
    
    private func deslogar(){
        
        self.auth = Auth.auth()
        
        do {
            //signOut desloga o usuario
            try auth.signOut()
            
            //dimiss volta para tela anterior que o usuario estava
            dismiss(animated: true, completion: nil)
            
        } catch  {
            let alerta = Alerta(titulo: "Não foi possivel deslogar", mensagem: "tente novamente mais tarde!")
            self.present(alerta.getAlerta(), animated: true, completion: nil)
        }//Fim da validacao de nome
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
