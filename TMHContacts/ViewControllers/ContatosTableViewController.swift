//
//  ContatosTableViewController.swift
//  TMHContacts
//
//  Created by Ricardo Caldeira on 14/07/19.
//  Copyright © 2019 Ricardo Caldeira. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import SDWebImage
import FirebaseStorage
import MapKit

class ContatosTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    var contatos: [Contato] = []
    var emailContato: UITextField!
    var tempoAux = 1
    var usuario = Usuario()
    let auth = Auth.auth()
    var localizacao = Localizacao()
    var localizacoes: [Localizacao] = []
    let database = Database.database().reference()
    var gerenciadorDeLocalizacao = CLLocationManager()
    var localUsuario = CLLocationCoordinate2D()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //pegando o id de usuario logado
        if let idUsuarioLogado = auth.currentUser?.uid {
            
            let usuarios = self.database.child("usuarios")
            let contatos = usuarios.child(idUsuarioLogado).child("contatos")
            let usuario = usuarios.child(idUsuarioLogado)
            let perfil = usuario.child("perfil")
            
            //criar um ouvinte do Banco
            perfil.observeSingleEvent(of: DataEventType.value) { (snapshotUsuario) in
                
                let dadosUsuarioLogado = snapshotUsuario.value as? NSDictionary
                
                if let urlImagem: String = dadosUsuarioLogado?["urlImagem"] as? String{
                    self.usuario.urlImagem = urlImagem
                }
                
                self.usuario.nome = dadosUsuarioLogado?["nome"] as! String
            }
            
            //criar um ouvinte do Banco
            contatos.observe(DataEventType.childAdded, with: { (snapshotContato) in
                
                let dadosContato = snapshotContato.value as? NSDictionary
                
                print("Print dados do contatos: \(dadosContato as Any)")
                
                let contato = Contato()
                contato.ContatoId = snapshotContato.key
                contato.nome = dadosContato?["nome"] as! String
                contato.email = dadosContato?["email"] as! String
                contato.urlImagem = dadosContato?["urlImagem"] as! String
                
                self.contatos.append(contato)
                
                //atualizando a tabela... porque muito provalvelmente o firebase nao vai ter carregado os dados ainda
                self.tableView.reloadData()
                
            })
            
            //nesse IF descobrir se tem alerta daquele contato especifico
            if let idUsuarioLogado = auth.currentUser?.uid {
                
                let usuarios = self.database.child("usuarios")
                let usuario = usuarios.child(idUsuarioLogado)
                let localizacoesBanco = usuario.child("localizacoes")
                
                //criar um ouvinte do Banco
                localizacoesBanco.observe(DataEventType.childAdded, with: { (snapshotLocalizacao) in
                    
                    let dadosLocalizacao = snapshotLocalizacao.value as? NSDictionary
                    
                    print("Print dados da Localização: \(dadosLocalizacao as Any)")
                    
                    let localizacao = Localizacao()
                    localizacao.idlocalizacao = snapshotLocalizacao.key
                    localizacao.latitude = dadosLocalizacao?["coordenadasLatitude"] as! String
                    localizacao.longitude = dadosLocalizacao?["coordenadasLongitude"] as! String
                    
                    self.localizacoes.append(localizacao)
                    
                    print(self.localizacoes.count)
                    
                    //atualizando a tabela... porque muito provalvelmente o firebase nao vai ter carregado os dados ainda
                    self.tableView.reloadData()
                    
                })
                
            }
            
        }
        
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /*
    private func removerContato() {
        
        let autenticacao = Auth.auth()
        
        //pegando o id de usuario logado
        if let idUsuarioLogado = autenticacao.currentUser?.uid {
            
            let usuarios = database.child("usuarios")
            let contatos = usuarios.child(idUsuarioLogado).child("contatos")
            
            //Adicionar evento para item removido
            contatos.observe(DataEventType.childRemoved) { (snapshot) in
                
                var indice = 0
                
                for contato in self.contatos {
                    
                    if contato.ContatoId == snapshot.key {
                        self.contatos.remove(at: indice)
                    }
                    indice = indice + 1
                }
                
                self.tableView.reloadData()
            }
        }
        
    }*/

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let totalContatos = self.contatos.count
        
        if totalContatos == 0 {
            return 1
        }
        
        return totalContatos
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! ContatoCelula
        
        
        if contatos.count == 0 {//nao tem contatos
            cell.nameContato.text = "You have no contact :)"
        }else{//tem contatos
            //Configuração da celula
            let contato = self.contatos[indexPath.row]
            
            cell.nameContato.text = contato.nome
            cell.alertaContato.text = "No alert"
            
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
                        
                        cell.imageContato.sd_setImage(with: url) { (image, erro, cache, url) in
                            
                            //aqui a imagem é carregada
                            
                        }
                    
                }
                
            })
            
            for localizacao: Localizacao in localizacoes {
                
                if localizacao.idlocalizacao == contato.ContatoId {
                    contato.latitude = localizacao.latitude
                    contato.longitude = localizacao.longitude
                    cell.alertaContato.text = "click to see the alert"
                    cell.alertaContato.textColor = UIColor(displayP3Red: 1.000, green: 0.000, blue: 0.000, alpha: 1)
                }
                
            }
        
        }
        
        //Arredonda a imagem, da pra fazer tambem direto pela MainStroyboard usando Layer.conrnerRadius, e ativar a opcao "Clip Subviews"
        cell.imageContato.layer.cornerRadius = 29
        cell.imageContato.clipsToBounds = true
    
        return cell
    }
    
    //metodo que recupera o usuario selecionado para enviar a localização ou mostrar a localização ja enviada
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let contato = contatos[indexPath.row]
        
       
        var alerta = UIAlertController(title: "Não ha alerta", message: "There is no available alert for this contact for you.", preferredStyle: .alert)
        
        var cancelar = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        alerta.addAction(cancelar)
        
        if contato.latitude != "" {
            
            alerta = UIAlertController(title: "See alert", message: "See the alert it sent?", preferredStyle: .alert)
            
             cancelar = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            //Aqui enviamos o usuario para ver a anotacao no map
            let verAlerta = UIAlertAction(title: "See alert", style: .default) { (alertaConfigurações) in
                
                self.performSegue(withIdentifier: "segueMapView", sender: contato)
                
            }
            
            alerta.addAction(verAlerta)
        }
        
        self.present(alerta, animated: true, completion: nil)
        
    }
    
    
    //Metodo que envia os dados que queremos pela segue para a outra view no caso aqui a classe da view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //tratando se estamos usando a segue certa
        if segue.identifier == "segueMapView" {
            
            let mapViewController = segue.destination as! MapViewController
            
            mapViewController.contato = sender as! Contato
            
        }
    }
    

    
    //func para aparecer o botaao DELETE padrão
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        /*
        //Removendo item
        if editingStyle == UITableViewCell.EditingStyle.delete{
            
            self.contatos.remove(at: indexPath.row)
            
        */
          
    }
    

    func enviarLocalizacao(indexPath: IndexPath){
        
        if let coordenadas = self.gerenciadorDeLocalizacao.location?.coordinate {
            
            //criando um nó usuarios
            let usuarios = self.database.child("usuarios")
            
            //Nó do id do usuario onde vai ser salvo a localização
            let contato = usuarios.child(self.contatos[indexPath.row].ContatoId)
            
            //Criando um nó no banco chamado localizações
            let localizacoes = contato.child("localizacoes")
            
            //Criando um no com o id do usario que mandou a localizacao
            let localizacaoUsuario = localizacoes.child(self.auth.currentUser!.uid)
            
            //criando um dicionario pra setar os valores do usuario no banco
            let usuariosDados = [
                "coordenadasLatitude": coordenadas.latitude.description,
                "coordenadasLongitude": coordenadas.longitude.description,
            ]
            
            //salvando no banco
            localizacaoUsuario.setValue(usuariosDados)
            
            
        }
        
        
    }

}
