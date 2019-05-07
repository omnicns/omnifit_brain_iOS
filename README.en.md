# omnifit_brain_iOS    
> Read this in other languages: [한국어](README.md), [ENGLISH](README.en.md)

> INTRO

This library is intended to help you create apps that can be serviced using devices that are part of the Omniped product's brain product line. The library's functions consist of scanning devices, scanning scanned device lists, connecting devices, disconnecting devices, measuring brain waves, and terminating brain waves.

# Specification

- File type: framework
- Program language used: swift 4.2
- File name: lib_sdk.framework
- Deployment Info  
  + Deploryment Target : 10.0  
  + Devices            : Universal
- Version: 0.5
- Library used
  + Alamofire       : 4.8.0  
  + RxAlamofire     : 4.3.0  
  + Realm           : 3.13.0  
  + RealmSwift      : 3.13.0  
  + RxAtomic        : 4.4.0  
  + RxBluetoothKit  : 4.0.2  
  + RxCocoa         : 4.4.0  
  + RxSwift         : 4.4.0  
  + XCGLogger       : 6.0.4


## Installation instructions and how to use the library

- Ready
  + 1 Creates and closes project
  + 2 Add a default library
      * lib_sdk.framework file (OmniLib directory in the provided project is called "Generated Project" -> General -> Embedded Binaries
         Add by dragging
  + 3 Add other associated libraries 
      * Method 1: Copy the supplied library (the Frameworks directory within the provided project) to a new project and add it as                         described in the "Adding a default library" instruction.
      * Method 2: Add Using Pod
                1 Open Terminal and navigate to the project directory and type sudo gem install cocoa pods
                2 After entering pod init, use ls command to check file list of directory (Podfile is created).
                3 vi Podfile (edit) Edit as follows.
               
             target 'the project name' do
                  # Comment the next line if you're not using Swift and do not want to use dynamic frameworks
                  use_frameworks!
 
                  pod 'RxSwift', '~ 4.0'
                  pod 'RxCocoa', '~ 4.0'
                  pod 'RealmSwift'
                  pod 'RxAlamofire'
                  pod 'RxBluetoothKit', '4.0.2'
                  pod 'XCGLogger', '~> 6.0.2'
 
                  # Pods for lib-sdk
 
                end
                Step 4 Close the edit window and type "pod install" in a terminal window
               
          4 Open the project as "project name.xcworkspace"
   Use + 4
       * 1 Library import: import lib_sdk
       * 2 Instance creation: var omnifitBrain: OmnifitBrain = OmnifitBrain ()
       * 3 Registering the delegate: omnifitBrain.delegate = self
       * 4 Registering the delegate function:
       `` `swift
   
        extension ViewController : protocolOmnifitBrain{
  
        // signal stabilization state (only the data received in the stabilization state is treated as reliable data)
        // Measurement data is callback at 2 second interval
        func protocolMeasurementDataEvent(measureData: [Double]) {
        }
  
       // Measuring time state change 
        func protocolTimeChangeEvent(remainingTime: Int) {
        }
 
        // Battery change
        func protocolBatteryChangeEvent(batteryLevel : Int) {
        }
        func protocolBatteryChangeEventLow(batteryLevel : Int) {
        }
    
       // Device state change
        func protocolDeviceEvent(state: ConnectionStatus) {
           findList()
           switch state {
              case .CONNECTION_START:
              case .CONNECTED:
              case .ALREADY_CONNECTED:
              case .CONNECTION_COMPLETED:
              case .CONNECTION_FAILED:
              case .DISCONNECTED:
              case .INTENDED_DISCONNECTED:
          }
        }
 
        // Headset search event ** /
        func protocolHeadsetScanEvent(state: ScanState) {
          switch state {
            case .START:
            case .FOUND:
            case .FINISHED:
            case .FAILED:
          }  
        }
    
        // change of measurement state
        func protocolMeasurementEvent(status: MeasurementState) {
          switch status {
            case .STARTED:
            case .CANCELED:
            case .FORCE_STOP:
            case .COMPLETE:
            case .FAILED:
            case .ANALYSING:
            case .RESTARTED:
            case .REQUEST_START:
            case .REQUEST_STOP:
            case .STOPED:
          }
        }
    
        // Wear state change
        func protocolWearingEvent(portion: ElectrodePortion) {
          switch portion {
            case .ATTACHED:
            case .DETACHED_ALL:
            case .L_FOREHEAD:
            case .R_FOREHEAD:
            case .L_EAR:
            case .R_EAR:
            case .UNKNOWN:
                break
          }
        }     
      }
      ``` 

## Function List and Description

  - Find your device
    + Function name: `doFindDevice (scanTime:" scan time ")`
    + Input: scanTime: "scan time"
    + Output: reply with protocolHeadsetScanEvent (state: ScanState)
  - Device connection
    + Function name: `doConnectHeadset (), doConnectHeadset (PeripheralName:" name of the device ex> OCW-H20 "XXXX") `
    + Input: If there is no - Omnifit headsets that have the highest signal strength will be automatically connected
             - PeripheralName: "Device name of exter- nal device" ex) OCW-H20 XXXX "
    + Output: The value of the event that is generated by multiple delegate functions is responded as shown below.
             protocolDeviceEvent (state: ConnectionStatus) - connection state
             protocolWearingEvent (portion: ElectrodePortion) - Headset worn state
             protocolBatteryChangeEvent (batteryLevel: Int). - Battery level of 15% or more
             protocolBatteryChangeEventLow (batteryLevel: Int) - Battery level less than 15%
 - Start EEG measurement
     + Function name: `doStartMeasure (measureTime:" measurement time ", isOpenEye:" open eye or close eye ")`
     + Input:
      * measureTime :  
         0 - continuous measurement without limit
         Integer of 0 or more - The unit of the integer is the unit of seconds.
      * isOpenEye   :  
        true  -Respond to EEG measurements of open eye (eye) state  
        False - Responses to measured EEG values in eyes with closed eyes
    + Print  :  
        protocolMeasurementDataEvent(measureData: [Double]). - Measured EEG array
        protocolTimeChangeEvent(remainingTime: Int)          - Measurement elapsed time response
  - Disconnect device
     + Function name: `doDisconnectHeadset ()`
     + Input: none
     + Output: responded with the same function as the response of the device connection
   - End of EEG measurement
     + Function name: `doStopMeasure ()`
     + Input: none
     + Output: Response with the same function as the response of EEG measurement start
   - Release Resources
     + Function name: `doClose ()`
     + Input: none
     + Output: response to function such as device connection, EEG start response
   - Output scanned device list
     + Function name: `getScannedPeripheralList ()`
     + Input: none
     + Output: output as function return value 
    ```swift
    Examples> 
         var Peripherals : [ScannedPeripheral] = [ScannedPeripheral]()
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
    ```
## license

    Copyright 2019 omniC&S

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.


  
