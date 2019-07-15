//
//  Contato.swift
//  TMHContacts
//
//  Created by Ricardo Caldeira on 13/07/19.
//  Copyright © 2019 Ricardo Caldeira. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class Contato {
    
    var nome: String
    var ContatoId: String
    var email: String
    
    init(nome: String, ContatoId: String, email: String ) {
        self.nome = nome
        self.ContatoId = ContatoId
        self.email = email
    }
}

class ContatoAnotacao: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var contato: Contato
    
    init(coordenadas: CLLocationCoordinate2D, contato: Contato){
        self.coordinate = coordenadas
        self.contato = contato
    }
    
}
