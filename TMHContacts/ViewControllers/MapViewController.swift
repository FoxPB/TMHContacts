//
//  MapViewController.swift
//  TMHContacts
//
//  Created by Ricardo Caldeira on 13/07/19.
//  Copyright © 2019 Ricardo Caldeira. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import SDWebImage
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var map: MKMapView!
    var gerenciadorDeLocalizacao = CLLocationManager()
    var localUsuario = CLLocationCoordinate2D()
    let database = Database.database().reference()
    var auth: Auth!
    var nameUsuario: String!
    var urlImagemRecuperada: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configuraGerenciadorLocalizacao()
        auth = Auth.auth()
        dadosUsuarioLogado()

        
    }

    
    //tudo oque é preciso para iniciar o monitoramento da localizacao do usuario
    func configuraGerenciadorLocalizacao(){
        
        //dessa forma estamos dizendo que o nosso obj gerenciadorLocalizacao sera gerencia pela nossa propria ViewController
        gerenciadorDeLocalizacao.delegate = self
        
        //configurando a precisão da localização
        gerenciadorDeLocalizacao.desiredAccuracy = kCLLocationAccuracyBest
        
        //solicitando a autorizacao do usuario para obter sua localizacao
        gerenciadorDeLocalizacao.requestWhenInUseAuthorization()
        
        //Vai atualizar a localizando do usuario, caso ele comece a andar por exemplo
        gerenciadorDeLocalizacao.startUpdatingLocation()
        
    }
    
    //funcao ultilizada para abrir o mapa no local que o usuario esta na hora de adicionar um local, e toda vez que ele se movimentar nos receberemos a nova localizacao
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let coordenadas = gerenciadorDeLocalizacao.location?.coordinate{
            
            self.localUsuario = coordenadas
            
            let regiao = MKCoordinateRegion(center: coordenadas, latitudinalMeters: 400, longitudinalMeters: 400 )
            
            map.setRegion(regiao, animated: true)
            
            //remove anotacoes antes mesmo de criar
            map.removeAnnotations(map.annotations)
            
            //Cria uma anotacao para o local do usuario
            let anotacaoUsuario = MKPointAnnotation()
            anotacaoUsuario.coordinate = coordenadas
            anotacaoUsuario.title = "My location"
            
            map.addAnnotation( anotacaoUsuario )
            
            
        }
        
    }
    
    // colocando imagens nas anotacoes
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let anotacaoView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
        
        // onde as anotacaoes ganha imagens em vez daquele pontinho
        if annotation is MKUserLocation {
            //anotacaoView.image = self.imageProfile
        }else{
            
            //let contato = (annotation as! ContatoAnotacao).contato
            
            //Aqui vamos retorna a UIImage do contato
            //anotacaoView.image = UIImage(named: contato.nomeImagem!)
        }
        
        var frame = anotacaoView.frame
        frame.size.height = 40
        frame.size.width = 40
        
        anotacaoView.frame = frame
        
        return anotacaoView
    }
    
    // funcao para saber se o usuario autorizou o uso do gps dele, isso é bastante feito pelo apps profissionais tipo da google, apple, facebook, Uber, Waze....
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status != .authorizedWhenInUse && status != .notDetermined{
            
            // um alerta para que o usuario habilite o gps caso ele tenho negado anteriormente
            let alertaController = UIAlertController(title: "Location Accuracy",
                                                     message: "For a good operation of the app we need your location !!!, please enable", preferredStyle: .alert)
            
            // configurando o botao configurar do alerta, e dentro dele usamos um Closure*
            let acaoConfiguracoes = UIAlertAction(title: "Open settings", style: .default, handler: { (alertaConfigurações) in
                
                //nesse if temos a chamada da configuraçoes do sistema atrasvez de uma URL
                if let configuracoes = NSURL(string: UIApplication.openSettingsURLString) {
                    
                    UIApplication.shared.open(configuracoes as URL)
                }
                
            })
            
            // configurando o botao cancelar do alerta.
            let acaoCancelar = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            
            //adicionando os botoes ao alerta
            alertaController.addAction(acaoConfiguracoes)
            alertaController.addAction(acaoCancelar)
            
            //Dando show no alerta
            present(alertaController, animated: true, completion: nil)
        }
    }
    
    // esse metodo e chamado SEMRPE que a tela for apresentada ao usuario
    override func viewWillAppear(_ animated: Bool) {
        
        //com esse metodo a gente "esconde" a barra de navegacao da tela
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func dadosUsuarioLogado(){
        
        //criando um nó usuarios
        let usuarios = self.database.child("usuarios")
        
        //Recuperar Dados do usuario logado
        if let idUsuarioLogado = self.auth.currentUser?.uid {
            
            let usuarioLogado = usuarios.child(idUsuarioLogado)
            
            //Fazendo a consulta no Banco apenas uma vez com (observeSingleEvent) ao inves de fica "escutando" sempre que tiver alteracao com (observe)
            usuarioLogado.observeSingleEvent(of: DataEventType.value) { (snapshot) in
                
                let dadosUsuarioLogado = snapshot.value as? NSDictionary
                self.nameUsuario = dadosUsuarioLogado?["nome"] as? String
                self.urlImagemRecuperada  = dadosUsuarioLogado?["urlImagem"] as? String
                
            }
        }
    }

}
