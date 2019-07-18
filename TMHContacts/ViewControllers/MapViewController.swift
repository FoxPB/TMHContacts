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

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var descricaoEndereco: UILabel!
    
    
    var gerenciadorDeLocalizacao = CLLocationManager()
    let database = Database.database().reference()
    var auth: Auth!
    var nameUsuario: String!
    var urlImagemRecuperada: String!
    var contato = Contato()
    var localAlerta = CLLocationCoordinate2D()
    var tempoAux = 1
    var image = UIImageView()
    var address = "Address not found"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //aqui estamos dizendo que quem vai cuidar no mapa eh a propria classe, ja que ela ja herda de MKMap...
        map.delegate = self
        
        carregandoImagem()
        criandoAnotacao()

    }
    
    func criandoAnotacao(){
        
        
        
    }
    
    func carregandoImagem(){
        
        //Estamos apotando para a raiz do Storage no firebase
        let armazenamento = Storage.storage().reference()
        
        //Funciona parecido com o armazenamento da dados, so que aqui nao estamos criando um nó e sim uma pasta
        let imagesFolder = armazenamento.child("imagens")
        
        //recurepando o nome da imagem apara pegar url dela
        let imagesFile = imagesFolder.child("\(contato.ContatoId).jpg")
        
        //recuperando a url da imagem que foi upada
        imagesFile.downloadURL(completion: { (url, error) in
            
            if let urlR = url?.absoluteString {
                
                let url = URL(string: urlR)
                
                self.image.sd_setImage(with: url) { (image, erro, cache, url) in
                    
                    if let latitude = Double(self.contato.latitude) {
                        if let longitude = Double(self.contato.longitude) {
                            
                            self.localAlerta.latitude = latitude as CLLocationDegrees
                            self.localAlerta.longitude = longitude as CLLocationDegrees
                            
                            //Configurar area inicial do mapa
                            let regiao = MKCoordinateRegion(center: self.localAlerta, latitudinalMeters: 400, longitudinalMeters: 400 )
                            self.map.setRegion(regiao, animated: true)
                            
                            let anotacao = MKPointAnnotation()
                            anotacao.coordinate = self.localAlerta
                            anotacao.title = self.contato.nome
                            self.map.addAnnotation(anotacao)
                            
                            
                            self.descricaoEndereco.text = "Location \(self.contato.nome):  \(self.address)"
                            
                            let location = CLLocation(latitude: latitude, longitude: longitude)
                            
                            CLGeocoder().reverseGeocodeLocation(location) { (local, erro) in
                                
                                
                                if erro == nil {
                                    if let dadosLocal = local?.first {
                                        
                                        var street = ""
                                        if dadosLocal.thoroughfare != nil {
                                            street = dadosLocal.thoroughfare!
                                        }
                                        
                                        var number = ""
                                        if dadosLocal.subThoroughfare != nil {
                                            number = dadosLocal.subThoroughfare!
                                        }
                                        
                                        var neighborhood = ""
                                        if dadosLocal.subLocality != nil {
                                            neighborhood = dadosLocal.subLocality!
                                        }
                                        
                                        var city = ""
                                        if dadosLocal.locality != nil {
                                            city = dadosLocal.locality!
                                        }
                                        
                                        var cep = ""
                                        if dadosLocal.postalCode != nil {
                                            cep  = dadosLocal.postalCode!
                                        }
                                        
                                        var country = ""
                                        if dadosLocal.country != nil {
                                            country = dadosLocal.country!
                                            
                                        }
                                        
                                        self.address = "Location \(self.contato.nome):  \(street), nº\(number), \(neighborhood) - \(city) - \(cep), \(country)"
                                        
                                        self.descricaoEndereco.text = self.address
 
                                    }
                                }
                                
                            }
                            
                        }
                    }
                    
                }
                
            }
        })
        
    }
    
    
    // colocando imagens nas anotacoes
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let anotacaoView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
        
        // onde as anotacaoes ganha imagens em vez daquele pontinho
        anotacaoView.image = image.image
        
        var frame = anotacaoView.frame
        frame.size.height = 50
        frame.size.width = 50
        anotacaoView.frame = frame
        anotacaoView.clipsToBounds = true
        anotacaoView.layer.cornerRadius = 25
        
        
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

}
