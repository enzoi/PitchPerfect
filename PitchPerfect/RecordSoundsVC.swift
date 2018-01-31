//
//  RecordSoundsVC.swift
//  PitchPerfect
//
//  Created by Yeontae Kim on 4/3/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import UIKit
import AVFoundation
import Speech

class RecordSoundsVC: UIViewController, AVAudioRecorderDelegate {
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var stopRecordingButton: UIButton!
    @IBOutlet weak var pauseRecordingButton: UIButton!
    
    var audioRecorder: AVAudioRecorder!
    var recordingSession: AVAudioSession!
    var resumeRecording: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordingSession = AVAudioSession.sharedInstance()
        

        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            
            SFSpeechRecognizer.requestAuthorization {
                [unowned self] (authStatus) in
                switch authStatus {
                case .authorized:
                    print("Authorized")
                case .denied:
                    print("Speech recognition authorization denied")
                case .restricted:
                    print("Not available on this device")
                case .notDetermined:
                    print("Not determined")
                }
            }
            
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.configureRecordingButton(isRecording: false, isPaused: false, message: "Tap to Record")
                    } else {
                        // TODO: Alert view controller to show error
                    }
                }
            }
        } catch {
            // TODO: Alert view controller to show error
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureRecordingButton(isRecording: false, isPaused: false, message: "Tap to Record")
    }

    func record() -> AVAudioRecorder { // Initial setting for recording
        
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.isMeteringEnabled = true
            audioRecorder.record()
            
        } catch {
            // TODO: error message
        }
        
        return audioRecorder
    }
    
    func configureRecordingButton(isRecording: Bool, isPaused: Bool, message: String) {
        recordButton.isEnabled = !isRecording
        recordingLabel.text = message
        pauseRecordingButton.isEnabled = isRecording && !isPaused
        stopRecordingButton.isEnabled = isRecording
    }
    
    @IBAction func recordAudio(_ sender: Any) {
        
        configureRecordingButton(isRecording: true, isPaused: false, message: "Record in progress")
        
        if !resumeRecording { // Initial recording
            let _ = record()
        }
        
    }
    
    @IBAction func stopRecording(_ sender: Any) {
        
        configureRecordingButton(isRecording: false, isPaused: false, message: "Tap to Record")
 
        audioRecorder.stop()
        try! recordingSession.setActive(false)
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
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "stopRecording" {
            let playSoundsVC = segue.destination as! PlaySoundsVC
            let recordedAudioURL = sender as! URL
            playSoundsVC.recordedAudioURL = recordedAudioURL
        }
    }
}


