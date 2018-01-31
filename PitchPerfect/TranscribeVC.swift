//
//  TranscribeVC.swift
//  PitchPerfect
//
//  Created by Yeontae Kim on 1/30/18.
//  Copyright © 2018 YTK. All rights reserved.
//

import UIKit
import Speech

class TranscribeVC: UIViewController {

    var recordedAudioURL: URL!
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.textView.isHidden = true
        self.transcribeFile(url: recordedAudioURL)
    }

    fileprivate func transcribeFile(url: URL) {
        
        guard let recognizer = SFSpeechRecognizer() else {
            print("Speech recognition not available for specified locale")
            return
        }
        
        if !recognizer.isAvailable {
            print("Speech recognition not currently available")
            return
        }
        
        updateUIForTranscriptionInProgress()
        
        let request = SFSpeechURLRecognitionRequest(url: url)
        
        recognizer.recognitionTask(with: request) {
            [unowned self] (result, error) in
            guard let result = result else {
                self.hideActivityIndicator(view: self.view)
                // TODO: Alert view to give error message
                
                return
            }
            
            if result.isFinal {
                self.updateUIWithCompletedTranscription(
                    result.bestTranscription.formattedString)
            }
        }
    }
    
    fileprivate func updateUIForTranscriptionInProgress() {
        DispatchQueue.main.async { [unowned self] in
            self.showActivityIndicator(view: self.view)
        }
    }
    
    fileprivate func updateUIWithCompletedTranscription(_ transcription: String) {
        DispatchQueue.main.async { [unowned self] in
            self.textView.text = transcription
            self.hideActivityIndicator(view: self.view)
            self.textView.isHidden = false
        }
    }
    
    
    fileprivate func showActivityIndicator(view: UIView) {
        
        let container: UIView = UIView()
        let loadingView: UIView = UIView()
        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
        var loadingLabel = UILabel()
        
        container.frame = view.frame
        container.center = CGPoint(x: self.view.bounds.size.width / 2, y: self.view.bounds.size.height / 2)
        container.backgroundColor = UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 0.3)
        container.tag = 1
        
        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = CGPoint(x: self.view.bounds.size.width / 2, y: self.view.bounds.size.height / 2)
        loadingView.backgroundColor = UIColor(red: 68.0 / 255.0, green: 68.0 / 255.0, blue: 68.0 / 255.0, alpha: 0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        activityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: 25.0, height: 25.0)
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        activityIndicator.center = CGPoint(x: loadingView.frame.size.width / 2, y: 30)
        activityIndicator.tag = 2
        
        loadingLabel = UILabel(frame: CGRect(x: 0, y: 55, width: 80, height: 15))
        loadingLabel.text = "Loading"
        loadingLabel.font = UIFont(name: "AvenirNextCondensed-DemiBold", size: 15)!
        loadingLabel.textColor = UIColor.lightGray
        loadingLabel.textAlignment = .center
        
        loadingView.addSubview(activityIndicator)
        loadingView.addSubview(loadingLabel)
        container.addSubview(loadingView)
        view.addSubview(container)
        activityIndicator.startAnimating()
    }
    
    fileprivate func hideActivityIndicator(view: UIView) {
        
        let container = view.viewWithTag(1)
        let acvitityIndicator = view.viewWithTag(2) as? UIActivityIndicatorView
        acvitityIndicator?.stopAnimating()
        container?.removeFromSuperview()
    }

}
