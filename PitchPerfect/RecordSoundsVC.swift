//
//  RecordSoundsVC.swift
//  PitchPerfect
//
//  Created by Yeontae Kim on 4/3/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsVC: UIViewController, AVAudioRecorderDelegate {
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var stopRecordingButton: UIButton!
    @IBOutlet weak var pauseRecordingButton: UIButton!
    @IBOutlet weak var transcribeButton: UIButton!
    
    var resumeRecording: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureRecordingButton(isRecording: false, isPaused: false, message: "Tap to Record")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureRecordingButton(isRecording: false, isPaused: false, message: "Tap to Record")
    }
    
    var audioRecorder: AVAudioRecorder!

    func recordPrep() -> AVAudioRecorder { // Initial setting for recording
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord, with:AVAudioSessionCategoryOptions.defaultToSpeaker)
        
        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        
        audioRecorder.prepareToRecord()
        
        return audioRecorder
    }
    
    func configureRecordingButton(isRecording: Bool, isPaused: Bool, message: String) {
        recordButton.isEnabled = !isRecording
        recordingLabel.text = message
        pauseRecordingButton.isEnabled = isRecording && !isPaused
        stopRecordingButton.isEnabled = isRecording
        transcribeButton.isEnabled = isRecording
        
        if isRecording {
            transcribeButton.alpha = 1.0
        } else {
            transcribeButton.alpha = 0.5
        }
    }
    
    @IBAction func recordAudio(_ sender: Any) {
        
        configureRecordingButton(isRecording: true, isPaused: false, message: "Record in progress")
        
        if !resumeRecording { // Initial recording
            recordPrep()
        }
        
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.record()
        
    }

    let audioSession = AVAudioSession.sharedInstance()
    
    @IBAction func stopRecording(_ sender: Any) {
        
        configureRecordingButton(isRecording: false, isPaused: false, message: "Tap to Record")
 
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    @IBAction func pauseRecording(_ sender: Any) {

        configureRecordingButton(isRecording: false, isPaused: true, message: "Tap to Resume")
        
        resumeRecording = true
        audioRecorder.pause()
    }
    
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
        } else {
            print("recording was not successful")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "stopRecording" {
            let playSoundsVC = segue.destination as! PlaySoundsVC
            let recordedAudioURL = sender as! URL
            playSoundsVC.recordedAudioURL = recordedAudioURL
        }
        
        if segue.identifier == "transcribing" {
            let transcribeVC = segue.destination as! TranscribeVC
            let recordedAudioURL = sender as! URL
            transcribeVC.recordedAudioURL = recordedAudioURL
        }
    }
}

extension UIView {
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
}


