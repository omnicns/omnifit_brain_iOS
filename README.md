# omnifit_brain_iOS
> 다른 언어로 일기: [한국어](README.md), [ENGLISH](README.en.md)

> 개요

본 라이브러리는 옴니핏 제품의 브레인 제품군에 해당하는 장치를 사용하여 서비스를 제공 할수 있는 앱을 만들 수 있도록 지원 하기 위한 것입니다.
라이브러리의 제공되는 기능은 장치 스캔,스캔된 장치 목록 조회, 장치 연결, 장치 연결 해재, 뇌파 측정, 뇌파 측정 종료 로 구성 됩니다.

## 제원

- 파일 형태 : framework  
- 사용된 프로그램 언어 : swift 4.2  
- 파일명 : lib_sdk.framework  
- Deployment Info  
  + Deploryment Target : 10.0  
  + Devices            : Universal  
- Version : 0.5  
- 사용된 라이브러리  
  + Alamofire       : 4.8.0  
  + RxAlamofire     : 4.3.0  
  + Realm           : 3.13.0  
  + RealmSwift      : 3.13.0  
  + RxAtomic        : 4.4.0  
  + RxBluetoothKit  : 4.0.2  
  + RxCocoa         : 4.4.0  
  + RxSwift         : 4.4.0  
  + XCGLogger       : 6.0.4  


## 설치 방법 및 라이브러리 사용 설명 

- 준비
  + 1 프로젝트 생성 후 닫음  
  + 2 기본 라이브러리 추가  
      * lib_sdk.framework 파일(제공되는 프로젝트 내의 OmniLib 디렉토리을 “생성된 프로젝트” -> General -> Embedded Binaries 에 
        드레그 하여 추가  
  + 3 기타 연관 라이브러리 추가  
      * 방법1 : 같이 제공 되는 라이브러리(제공되는 프로젝트 내의 Frameworks 디렉토리)를 새 프로젝트에 복사 후 "기본 라이브러리 추가” 설명의 
               방법으로 추가  
      * 방법2 : Pod 을 이용한 추가    
               1 터미널을 열고 해당 프로젝트 디렉토리에 이동하여 sudo gem install cocoa pods 를 입력  
               2 pod init 입력 후 ls 명령으로 디렉토리의 파일 리스트를 확인 (Podfile 이 생성되어 있음.)  
               3 vi Podfile (편집) 아래와 같이 편집 합니다. 
               
              target ‘해당 프로젝트명' do
                 # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
                 use_frameworks!
 
                 pod 'RxSwift',    '~> 4.0'
                 pod 'RxCocoa',    '~> 4.0'
                 pod 'RealmSwift'
                 pod 'RxAlamofire'
                 pod 'RxBluetoothKit', '4.0.2'
                 pod 'XCGLogger', '~> 6.0.2'
 
                 # Pods for lib-sdk
 
               end  
               순서 4 편집창을 닫고 터미널 창에서 "pod install” 입력  
               
           4 프로젝트를 “해당 프로젝트명.xcworkspace” 으로 오픈
   + 4 사용
      * 1 라이브러리 import   : import lib_sdk
      * 2 인스턴스 생성       : var omnifitBrain : OmnifitBrain = OmnifitBrain()
      * 3 델리게이트 등록      : omnifitBrain.delegate = self
      * 4 델리게이트 함수 등록  : 
      ```swift  
   
        extension ViewController : protocolOmnifitBrain{
  
        //신호안정화 상태(안정화 상태에서 받은 데이터만 신뢰할수 있는 데이터로 취급)  
        //측정 데이터는 2초 간격으로 콜백
        func protocolMeasurementDataEvent(measureData: [Double]) {
        }
  
        //측정 시간 상태 변화 
        func protocolTimeChangeEvent(remainingTime: Int) {
        }
 
        //베터리 변화
        func protocolBatteryChangeEvent(batteryLevel : Int) {
        }
        func protocolBatteryChangeEventLow(batteryLevel : Int) {
        }
    
        //장치 상태 변화
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
 
        //헤드셋 써치 이벤트 **/
        func protocolHeadsetScanEvent(state: ScanState) {
          switch state {
            case .START:
            case .FOUND:
            case .FINISHED:
            case .FAILED:
          }  
        }
    
        //측정 상태 변화
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
    
        //착용 상태 변화
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

## 함수 목록 및 설명

  - 장치 찾기
    + 함수명 : `doFindDevice(scanTime: "스캔 시간”)`
    + 입력  : scanTime: "스캔 시간”
    + 출력  : protocolHeadsetScanEvent(state: ScanState) 으로 응답
  - 장치 연결
    + 함수명 : `doConnectHeadset() , doConnectHeadset(PeripheralName: “해당 기기의 이름 ex> OCW-H20 "XXXX” )`
    + 입력  : 없을 경우 - 겁색된 Omnifit 헤드셋 리스트 중 신호 세기가 가장 센 기기를 우선적으로 자동 연결 됨  
             있을 경우 - PeripheralName: "해당 기기의 이름 ex> OCW-H20 XXXX”와 같이 입력되는 장치 명의 기기가 연결 됨  
    + 출력  : 아래와 같이 다중의 델리게이트 함수로 발생되는 이벤트의 값이 응답 됨  
             protocolDeviceEvent(state: ConnectionStatus)      - 연결 상태  
             protocolWearingEvent(portion: ElectrodePortion)   - 헤드셋 착용 상태  
             protocolBatteryChangeEvent(batteryLevel : Int).   - 15% 이상의 베터리 레벨  
             protocolBatteryChangeEventLow(batteryLevel : Int) - 15% 이하의 베터리 레벨  
  - 뇌파 측정 시작
    + 함수명 : `doStartMeasure(measureTime: “측정시간", isOpenEye: “뜬 눈 or 감은 눈”)` 
    + 입력  :  
      * measureTime :  
        0 일 경우 - 제한 없는 연속 측정  
        0 이상의 정수 - 정수의 단위는 초 단위 이며, 입력된 시간만큼 뇌파를 측정  
      * isOpenEye   :  
        true  - 뜬 눈 (개안) 상태의 뇌파 측정 값을 응답  
        False - 감은 눈 (패안) 상태의 뇌파 측정 값을 응답
    + 출력  :  
        protocolMeasurementDataEvent(measureData: [Double]). - 측정된 뇌파값 배열  
        protocolTimeChangeEvent(remainingTime: Int)          - 측정 경과 시간 응답
  - 장치 연결 해제  
    + 함수명 : `doDisconnectHeadset()`
    + 입력  : 없음  
    + 출력  : 장치 연결 의 응답과 같은 함수로 응답됨
  - 뇌파 측정 종료
    + 함수명 : `doStopMeasure()`
    + 입력  : 없음
    + 출력  : 뇌파 측정 시작 의 응답과 같은 함수로 응답
  - 자원 해제  
    + 함수명 : `doClose()`
    + 입력  : 없음
    + 출력  : 장치 연결 , 뇌파 측정 시작 의 응답과 같은 함수로 응답
  - 스캔된 장치 리스트 출력  
    + 함수명 : `getScannedPeripheralList()`
    + 입력  : 없음
    + 출력  : 함수의 리턴 값으로 출력  
    ```swift
    사용 예 > 
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
## 라이센스

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


  
