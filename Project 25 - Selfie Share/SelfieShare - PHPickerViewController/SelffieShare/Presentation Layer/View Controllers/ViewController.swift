//
//  ViewController.swift
//  SelffieShare
//
//  Created by Pham Anh Tuan on 9/3/22.
//

import UIKit
import MultipeerConnectivity
import PhotosUI

private let reuseIdentifier = "ImageCell"

class ViewController: UICollectionViewController, UINavigationControllerDelegate, MCBrowserViewControllerDelegate, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate {
    
    var images = [UIImage]()
    let imageViewTag = 1000

    private let mcServiceType = "selfieshare"
    private var mcPeerID = MCPeerID(displayName: UIDevice.current.name)
    private var mcSession: MCSession?
    private var mcNearbyServiceAdvertiser: MCNearbyServiceAdvertiser?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        
        title = "Selfie Share"
        
        mcSession = MCSession(peer: mcPeerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession?.delegate = self
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(handleImageSelectionButtonTapped)),
            UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(handleSendMessageButtonTapped))
        ]
        
        navigationItem.leftBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleShowConnectionPromtButtonTapped)),
            UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(handleShowConnectionPeersButtonTapped))
        ]
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return images.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
        guard let imageView = cell.viewWithTag(imageViewTag) as? UIImageView else { return UICollectionViewCell() }
        
        imageView.image = images[indexPath.item]
    
        return cell
    }
    
    // MARK: - MCSession Delegate
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .notConnected:
            DispatchQueue.main.async { [weak self] in
                let ac = UIAlertController(title: "Disconnected!", message: "Device \(peerID.displayName) is disconnected", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .cancel))
                
                self?.present(ac, animated: true)
            }
        case .connecting:
            print("Connecting: \(peerID.displayName)")
        case .connected:
            print("Connected: \(peerID.displayName)")
        @unknown default:
            print("Unknown state: \(peerID.displayName)")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async { [weak self] in
            if let image = UIImage(data: data) {
                self?.images.insert(image, at: 0)
                self?.collectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
            } else if let message = String(data: data, encoding: .utf8) {
                let ac = UIAlertController(title: "Received", message: "Message: \(message)", preferredStyle: .alert)
                ac.addTextField { textField in
                    textField.placeholder = "Enter your response here"
                }
                ac.addAction(UIAlertAction(title: "Reply", style: .default, handler: { [weak ac, weak self] _ in
                    guard let message = ac?.textFields?[0].text else { return }
                    self?.sendMessageToOthers(message)
                }))
                ac.addAction(UIAlertAction(title: "Ignore", style: .cancel))
                
                self?.present(ac, animated: true)
            }
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // <#code#>
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        // <#code#>
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        // <#code#>
    }

    // MARK: - MCBrowserViewController Delegate
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    // MARK: - MCNearbyServiceAdvertiser Delegate

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {

        guard let mcSession = mcSession else { return }
        invitationHandler(true, mcSession)
    }
    
    // MARK: - Extra Funcs

    
    private func sendImageToPeers(_ image: UIImage) {
        guard
            let pngImage = image.pngData()
        else {
            return
        }
        
        sendDataToPeers(data: pngImage)
    }
    
    @objc private func handleShowConnectionPromtButtonTapped() {
        let ac = UIAlertController(title: "Connect ...", message: nil, preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "Host a session", style: .default, handler: hostASession))
        
        ac.addAction(UIAlertAction(title: "Join a session", style: .default, handler: joinASession))
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true, completion: nil)
    }
    
    @objc private func hostASession(_ action: UIAlertAction) {
        mcNearbyServiceAdvertiser = MCNearbyServiceAdvertiser(peer: mcPeerID, discoveryInfo: nil, serviceType: mcServiceType)
        mcNearbyServiceAdvertiser?.delegate = self
        mcNearbyServiceAdvertiser?.startAdvertisingPeer()
    }
    
    @objc private func joinASession(_ action: UIAlertAction) {
        guard let mcSession = mcSession else { return }
        
        let mcBrowser = MCBrowserViewController(serviceType: mcServiceType, session: mcSession)
        
        mcBrowser.delegate = self
        
        present(mcBrowser, animated: true, completion: nil)
    }
    
    @objc private func handleSendMessageButtonTapped(_ action: UIAlertAction) {
        let ac = UIAlertController(title: "Send a message", message: nil, preferredStyle: .alert)
        ac.addTextField { textField in
            textField.placeholder = "Enter your message here"
        }
        ac.addAction(UIAlertAction(title: "Send", style: .default, handler: { [weak self, weak ac] _ in
            guard let message = ac?.textFields?[0].text else { return }
            self?.sendMessageToOthers(message)
        }))
        
        present(ac, animated: true)
    }
    
    private func sendMessageToOthers(_ message: String) {
        sendDataToPeers(data: Data(message.utf8))
    }
    
    private func sendDataToPeers(data: Data) {
        guard
            let mcSession = mcSession
        else {
            return
        }
        
        let connectedPeers = mcSession.connectedPeers
        if connectedPeers.count > 0 {
            do {
                try mcSession.send(data, toPeers: connectedPeers, with: .reliable)
            } catch {
                let ac = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))

                present(ac, animated: true)
            }
        }
    }
    
    @objc private func handleShowConnectionPeersButtonTapped() {
        guard let mcSession = mcSession else {
            return
        }
        
        var peerNames = [String]()
        
        for eachPeer in mcSession.connectedPeers {
            peerNames.append(eachPeer.displayName)
        }
        
        var peerNameList = "No connected peer"
        
        if !peerNames.isEmpty {
            peerNameList = peerNames.joined(separator: ", ")
        }
        
        let ac = UIAlertController(title: "Connected Peers", message: peerNameList, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .cancel))
        
        present(ac, animated: true)
    }
}

extension ViewController: PHPickerViewControllerDelegate {
    
    // MARK: - PHPickerViewController Delegate
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        
        if results.count > 0 {
            for eachResult in results {
                let itemProvider = eachResult.itemProvider
                if itemProvider.canLoadObject(ofClass: UIImage.self) {
                    itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                        DispatchQueue.main.async {
                            self?.handleInsertingImageIntoCollectionView(image: image, error: error)
                        }
                    }
                }
            }
        }
    }
    
    @objc private func handleImageSelectionButtonTapped() {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        let newFilter = PHPickerFilter.images
        
        config.filter = newFilter
        config.preferredAssetRepresentationMode = .current
        config.selection = .ordered
        config.selectionLimit = 0

        let photoPicker = PHPickerViewController(configuration: config)
        photoPicker.delegate = self

        present(photoPicker, animated: true)
    }
    
    @objc private func handleInsertingImageIntoCollectionView(image: NSItemProviderReading?, error: Error? = nil) {
        if let image = image as? UIImage {
            images.insert(image, at: 0)
            collectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
            sendImageToPeers(image)
        }
    }
}
