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
    var resumeRecording: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pauseRecordingButton.isEnabled = false
        stopRecordingButton.isEnabled = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pauseRecordingButton.isEnabled = false
        stopRecordingButton.isEnabled = false
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
    
    func configureRecordingButton(isRecording: Bool, isPausing: Bool, message: String) {
        recordButton.isEnabled = !isRecording
        recordingLabel.text = message
        pauseRecordingButton.isEnabled = !isPausing
        stopRecordingButton.isEnabled = isRecording
    }
    
    @IBAction func recordAudio(_ sender: Any) {
        
        configureRecordingButton(isRecording: true, isPausing: false, message: "Record in progress")
        
        if !resumeRecording { // Initial recording
            recordPrep()
        }
        
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.record()
        
    }

    let audioSession = AVAudioSession.sharedInstance()
    
    @IBAction func stopRecording(_ sender: Any) {
        
        configureRecordingButton(isRecording: false, isPausing: false, message: "Tap to Record")
 
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    @IBAction func pauseRecording(_ sender: Any) {

        configureRecordingButton(isRecording: false, isPausing: true, message: "Tap to Resume")
        
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
    }
}

