//
//  ViewController.swift
//  omnifit_brain_libsample
//
//  Created by 한광식 on 30/04/2019.
//  Copyright © 2019 한광식. All rights reserved.
//

import UIKit
import RxBluetoothKit
import RxSwift
import CoreBluetooth

import lib_sdk
import SnapKit

class ViewController: UIViewController {

    var Peripherals : [ScannedPeripheral] = [ScannedPeripheral]()
    var omnifitBrain : OmnifitBrain = OmnifitBrain()
    lazy var bleTableView: UITableView = {
        let tv = UITableView()
        tv.register(simpleBleCell.self, forCellReuseIdentifier: simpleBleCell.id)
        tv.dataSource = self
        tv.delegate = self
        tv.estimatedRowHeight = 200.0
        tv.rowHeight = UITableView.automaticDimension
        return tv
    }()
    
    
    @IBOutlet weak var viewTableBase: UIView!
    @IBOutlet weak var headsetName: UILabel!
    @IBOutlet weak var findStatus: UILabel!
    @IBOutlet weak var Headset_staus : UILabel!
    @IBOutlet weak var wearStatus: UILabel!
    @IBOutlet weak var batteryLevel: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var measureStatus: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.viewTableBase.addSubview(bleTableView)
        bleTableView.snp.makeConstraints { (make) in
            make.left.bottom.right.top.equalToSuperview()
        }
        // Do any additional setup after loading the view, typically from a nib.
        omnifitBrain.delegate = self
    }

    func findList(){
        Peripherals.removeAll()
        Peripherals = omnifitBrain.getScannedPeripheralList()
        for e in Peripherals {
            print("=====================================================")
            print("rssi : \(e.rssi)")
            print("localName : \(String(describing: e.advertisementData.localName))")
            print("isConnectable : \(String(describing: e.peripheral.isConnected))")
            //log.info("isConnectable : \(String(describing: e.advertisementData.isConnectable))")
            print("=====================================================")
        }
        self.bleTableView.reloadData()
    }
    
    @IBAction func find(_ sender: Any) {
        omnifitBrain.doFindDevice(scanTime: 2)
    }
    @IBAction func checkAudio(_ sender: Any) {
        if omnifitBrain.isConnectedAudioSet() == true {
            print("Audio Module is connected.")
        } else {
            omnifitBrain.openSystemBluetoothSetting()
        }
    }
    @IBAction func close(_ sender: Any) {
        omnifitBrain.doClose()
    }
    @IBAction func getList(_ sender: Any) {
        findList()
    }
    @IBAction func connect(_ sender: Any) {
        omnifitBrain.doConnectHeadset()
    }
    @IBAction func disConnect(_ sender: Any) {
        omnifitBrain.doDisconnectHeadset()
    }
    @IBAction func startMeasure(_ sender: Any) {
        omnifitBrain.doStartMeasure(measureTime: 90, isOpenEye: false)
    }
    @IBAction func stopMeasure(_ sender: Any) {
        omnifitBrain.doStopMeasure()
    }
    
    
    
    
}

extension ViewController : protocolOmnifitBrain{
    
    
    /** 신호안정화 상태(안정화 상태에서 받은 데이터만 신뢰할수 있는 데이터로 취급) **/
    /**
     측정 데이터는 2초 간격
     */
    func protocolMeasurementDataEvent(measureData: [Double]) {
        print("MEASURE DATA : \(measureData)")
    }
    
    /**
     측정 시간 상태 변화
     */
    func protocolTimeChangeEvent(remainingTime: Int) {
        print("remainingTime : \(remainingTime)")
        time.text = "Time : " + String(remainingTime)
    }
    /**
     베터리 변화
     */
    func protocolBatteryChangeEvent(batteryLevel : Int) {
        print("BatteryChangeEvent : \(batteryLevel)")
        self.batteryLevel.text = "Battery level : " + String(batteryLevel) + "%"
    }
    func protocolBatteryChangeEventLow(batteryLevel : Int) {
        print("BatteryChangeEvent (LOW) : \(batteryLevel)")
        self.batteryLevel.text = "Battery level : " + String(batteryLevel) + "%"
    }
    
    /** 장치 상태 변화 **/
    func protocolDeviceEvent(state: ConnectionStatus) {
        findList()
        switch state {
        case .CONNECTION_START:
            Headset_staus.text = "Headset staus : CONNECTION_START"
            print("DeviceEvent : CONNECTION_START")
        case .CONNECTED:
            Headset_staus.text = "Headset staus : CONNECTED"
            print("DeviceEvent : CONNECTED")
        case .ALREADY_CONNECTED:
            Headset_staus.text = "Headset staus : ALREADY_CONNECTED"
            print("DeviceEvent : ALREADY_CONNECTED")
        case .CONNECTION_COMPLETED:
            Headset_staus.text = "Headset staus : CONNECTION_COMPLETED"
            print("DeviceEvent : CONNECTION_COMPLETED")
        case .CONNECTION_FAILED:
            Headset_staus.text = "Headset staus : CONNECTION_FAILED"
            print("DeviceEvent : CONNECTION_FAILED")
        case .DISCONNECTED:
            Headset_staus.text = "Headset staus : DISCONNECTED"
            print("DeviceEvent : DISCONNECTED")
        case .INTENDED_DISCONNECTED:
            Headset_staus.text = "Headset staus : INTENDED_DISCONNECTED"
            print("DeviceEvent : INTENDED_DISCONNECTED")
        }
    }
    /** 헤드셋 써치 이벤트 **/
    func protocolHeadsetScanEvent(state: ScanState) {
        switch state {
        case .START:
            findStatus.text = "BLE Find Status : START"
            print("HeadsetScanEvent : START")
        case .FOUND:
            findStatus.text = "BLE Find Status : FOUND"
            print("HeadsetScanEvent : FOUND")
        case .FINISHED:
            findStatus.text = "BLE Find Status : FINISHED"
            //omnifitBrain.doConnectHeadset()
            print("HeadsetScanEvent : FINISHED")
            findStatus.text =  "BLE Find Status : FIND FINISHED"
            headsetName.text = "Headset Name : " + omnifitBrain.getScannedPeripheral()
        case .FAILED:
            findStatus.text = "BLE Find Status : FAILED"
            print("HeadsetScanEvent : FAILED")
        }
    }
    
    /**
     측정 상태 변화
     **/
    func protocolMeasurementEvent(status: MeasurementState) {
        switch status {
        case .STARTED:
            measureStatus.text = "MeasureStatus : STARTED"
            print("MeasurementEvent : STARTED")
        case .CANCELED:
            measureStatus.text = "MeasureStatus : CANCELED"
            print("MeasurementEvent : CANCELED")
        case .FORCE_STOP:
            measureStatus.text = "MeasureStatus : FORCE_STOP"
            print("MeasurementEvent : FORCE_STOP")
        case .COMPLETE:
            measureStatus.text = "MeasureStatus : COMPLETE"
            print("MeasurementEvent : COMPLETE")
        case .FAILED:
            measureStatus.text = "MeasureStatus : FAILED"
            print("MeasurementEvent : FAILED")
        case .ANALYSING:
            measureStatus.text = "MeasureStatus : ANALYSING"
            print("MeasurementEvent : ANALYSING")
        case .RESTARTED:
            measureStatus.text = "MeasureStatus : RESTARTED"
            print("MeasurementEvent : RESTARTED")
        case .REQUEST_START:
            measureStatus.text = "MeasureStatus : REQUEST_START"
            print("MeasurementEvent : REQUEST_START")
        case .REQUEST_STOP:
            measureStatus.text = "MeasureStatus : REQUEST_STOP"
            print("MeasurementEvent : REQUEST_STOP")
        case .STOPED:
            measureStatus.text = "MeasureStatus : STOPED"
            print("MeasurementEvent : STOPED")
        }
    }
    
    /**
     착용 상태 변화
     **/
    func protocolWearingEvent(portion: ElectrodePortion) {
        switch portion {
        case .ATTACHED:
            wearStatus.text = "Wear status : ATTACHED"
            print("WearingEvent : ATTACHED")
        case .DETACHED_ALL:
            wearStatus.text = "Wear status : DETACHED_ALL"
            print("WearingEvent : DETACHED_ALL")
        case .L_FOREHEAD:
            wearStatus.text = "Wear status : L_FOREHEAD"
            print("WearingEvent : L_FOREHEAD")
        case .R_FOREHEAD:
            wearStatus.text = "Wear status : R_FOREHEAD"
            print("WearingEvent : R_FOREHEAD")
        case .L_EAR:
            wearStatus.text = "Wear status : L_EAR"
            print("WearingEvent : L_EAR")
        case .R_EAR:
            wearStatus.text = "Wear status : R_EAR"
            print("WearingEvent : R_EAR")
        case .UNKNOWN:
            break
            //log.info("WearingEvent : UNKNOWN")
        }
    }
    
    
}






extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Peripherals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: simpleBleCell.id, for: indexPath)
        if let simpleBleCell = cell as? simpleBleCell {
            simpleBleCell.configure(with: Peripherals[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // eventService()?.onStartCommand(.REQUEST_CONNECT_HEADSET, peripheralsArray[indexPath.row])
        let data_resource : ScannedPeripheral = Peripherals[indexPath.row]
        omnifitBrain.doConnectHeadset(PeripheralName: data_resource.advertisementData.localName!)
    }
    
}

class simpleBleCell: UITableViewCell {
    
    static let id = "simpleBleCell"
    
    var peripheralNameLabel: UILabel = {
        let l = UILabel()
        l.numberOfLines = 0
        return l
    }()
    var RSSILabel: UILabel = {
        let l = UILabel()
        l.numberOfLines = 0
        return l
    }()
    var advertismentDataLabel: UILabel = {
        let l = UILabel()
        l.numberOfLines = 0
        return l
    }()
    
    func configure(with peripheral: ScannedPeripheral) {
        setupView()
        
        self.peripheralNameLabel.text =   "peripheralName : [" + (peripheral.advertisementData.localName ?? peripheral.peripheral.identifier.uuidString) + "]"
        self.RSSILabel.text =             "RSSI                     : [" + peripheral.rssi.stringValue + "]"
        self.advertismentDataLabel.text = "IsConnect           : [" + "\(peripheral.peripheral.isConnected ? "Connect" : "DisConnect")" + "]"
    }
    
    private func setupView() {
        self.addSubview(peripheralNameLabel)
        self.addSubview(RSSILabel)
        self.addSubview(advertismentDataLabel)
        
        
        peripheralNameLabel.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.33)
        }
        
        RSSILabel.snp.makeConstraints { (make) in
            make.top.equalTo(peripheralNameLabel.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.33)
        }
        
        advertismentDataLabel.snp.makeConstraints { (make) in
            make.top.equalTo(RSSILabel.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.33)
        }
    }
}



