//
//  LoginViewController.swift
//  TMHContacts
//
//  Created by Ricardo Caldeira on 13/07/19.
//  Copyright © 2019 Ricardo Caldeira. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // esse metodo e chamado SEMRPE que a tela for apresentada ao usuario
    override func viewWillAppear(_ animated: Bool) {
        
        //com esse metodo a gente "esconde" a barra de navegacao da tela
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }


}
