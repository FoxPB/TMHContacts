//
//  ProfileViewController.swift
//  TMHContacts
//
//  Created by Ricardo Caldeira on 14/07/19.
//  Copyright © 2019 Ricardo Caldeira. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import SDWebImage

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var btnLogout: UIButton!
    @IBOutlet weak var imageProfile: UIImageView!
    @IBOutlet weak var btnSaveImage: UIButton!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    
    var auth: Auth!
    var urlImagemRecuperada: String!
    let database = Database.database().reference()
    var tempoAux = 2
    
    //instaciando o ImagePiker pra trabalhar com a camera e galeria
    var imagePiker = UIImagePickerController()
    
    //criamos um ID para o nome da imagem.
    var idImagem: String = ""
    
    //Estamos apotando para a raiz do Storage no firebase
    let armazenamento = Storage.storage().reference()
    
 
    @IBAction func btnSaveImageAction(_ sender: Any) {
        salvarImagem()
        self.btnSaveImage.isHidden = true
    }
    
    @IBAction func btnCameraAction(_ sender: Any) {
        selecionarImagem()
    }
    
    @IBAction func btnLogoutAction(_ sender: Any) {
        deslogar()
    }
    
    private func selecionarImagem() {
        
        //aqui selecionamos de onde queremos buscar as fotos, se da camera ou do album
        imagePiker.sourceType = .photoLibrary
        
        //o imagePiker funciona mais ou menos com um alert tem que chamar e apresentar ele
        present(imagePiker, animated: true, completion: nil)
        
    }
    
    private func salvarImagem(){
        
        //Funciona parecido com o armazenamento da dados, so que aqui nao estamos criando um nó e sim uma pasta
        let imagesFolder = armazenamento.child("imagens")
        
        //Aqui nos damos o nome a imagem que vai ser salva que no caso sera um ID, que sera o mesmo id do usuario
        let imagesFile = imagesFolder.child("\(self.idImagem).jpg")
        
        //Recuperar imagem para enviar para o Banco
        if let imagemSelecionada = self.imageProfile.image {
            
            //convertendo imagem de modo ao firebase entendela
            if let imagemDados = imagemSelecionada.jpegData(compressionQuality: 0.5){
                
                //enviando a imagem para o firebase
                imagesFile.putData(imagemDados, metadata: nil) { (metaDados, erro) in
                    
                    if erro == nil{//deu certo
                        
                        //recuperando a url da imagem que foi upada
                        imagesFile.downloadURL(completion: { (url, error) in
                            
                            if let urlR = url?.absoluteString {
                                self.urlImagemRecuperada = urlR
                                
                                //Aqui vamos salvar nos banco no ID do usuario o URL da imagem e o ID da imagem
                                //criando um nó usuarios
                                let usuarios = self.database.child("usuarios")
                                
                                //Recuperar Dados do usuario logado
                                if let idUsuarioLogado = self.auth.currentUser?.uid {
                                    
                                    let usuarioLogado = usuarios.child(idUsuarioLogado)
                                    
                                    let imagemDados = [
                                        "nome": self.name.text,
                                        "email": self.email.text,
                                        "urlImagem": self.urlImagemRecuperada,
                                    ]
                                    
                                    //em vez de salvar dado por dado... um a um... criamos um dicionario e passamos ele aqui para salvar.
                                    usuarioLogado.setValue(imagemDados)
                                    
                                }
                                
                            }
                            
                        })
                        
                    }else{//teve erro
                        let alerta = Alerta(titulo: "Upload falhou", mensagem: "Erro ao salvar o arquivo, tente novamente!")
                        self.present(alerta.getAlerta(), animated: true, completion: nil)
                    }
                    
                }
            }
        }
        
    }
    
    //com esse metodo (UIImagePickerController) conseguimos capturar qual image o usuario selecionou
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        //reperando a imagem que foi selecionada
        let imagemRecuperada = info[ UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        //setando a imagem recuperada no imageview
        self.imageProfile.image = imagemRecuperada
        
        //o dismiss pra sair da tela de selecao depois que o usuario selecionar a foto
        imagePiker.dismiss(animated: true, completion: nil)
        
         self.btnSaveImage.isHidden = false
        
    }
    
    
    private func deslogar(){
        
        do {
            //signOut desloga o usuario
            try self.auth.signOut()
            
            //dimiss volta para tela anterior que o usuario estava
            dismiss(animated: true, completion: nil)
            
        } catch  {
            let alerta = Alerta(titulo: "Não foi possivel deslogar", mensagem: "tente novamente mais tarde!")
            self.present(alerta.getAlerta(), animated: true, completion: nil)
        }//Fim da validacao de nome
        
    }
    
    func dadosUsuarioLogado(){
    
        //criando um nó usuarios
        let usuarios = self.database.child("usuarios")
        
        //Recuperar Dados do usuario logado
        if let idUsuarioLogado = self.auth.currentUser?.uid {
            
            self.idLabel.text = "ID: \(idUsuarioLogado)"
            
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
        }
    }
    
    private func carregarImagemProfile(){
        
        //Inicializar o Timer
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
            
            //Decrementar o tempo
            self.tempoAux = self.tempoAux - 1
            
            //caso o timer execute ate o 0, invalidar
            //E o usar o dismiss para fechar a tela
            if self.tempoAux == 0 {
                timer.invalidate()
                
                if self.urlImagemRecuperada != nil {
                    
                    let url = URL(string: self.urlImagemRecuperada)
                    
                    //Aqui é carregada a imagem
                    self.imageProfile.sd_setImage(with: url) { (image, erro, cache, url) in
                        
                       self.imageProfile.layer.cornerRadius = 65
                       self.imageProfile.clipsToBounds = true
                        
                    }
                }
                
            }
        })
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        auth = Auth.auth()
        dadosUsuarioLogado()
        imagePiker.delegate = self
        self.btnSaveImage.isHidden = true
        carregarImagemProfile()
    }

}
