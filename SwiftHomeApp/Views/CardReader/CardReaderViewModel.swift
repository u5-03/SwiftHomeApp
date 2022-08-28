//
//  CardReaderViewModel.swift
//  SwiftHomeApp
//
//  Created by yugo.sugiyama on 2022/08/28.
//

import Foundation
import CoreNFC
import TRETJapanNFCReader_FeliCa
import TRETJapanNFCReader_FeliCa_TransitIC
import SwiftHomeCredentials
import SwiftHomeCore
import Alamofire

final class CardReaderViewModel: NSObject, ObservableObject {
    @Published private(set) var suicaId = ""
    private var reader: TransitICReader!
    private var transitICCardData: TransitICCardData?
    private let serverConfig: ServerConfiguration = .localHost

    override init() {
        super.init()
        reader = TransitICReader(delegate: self)
    }

    func readCard() {
        reader.get(itemTypes: TransitICCardItemType.allCases)
    }

    func postCardId() {
        guard !suicaId.isEmpty else { return }
        let encoder = JSONEncoder()
        let model = NfcIdModel(nfcId: suicaId)
        let parameters = try! model.asDictionary(using: encoder)
        let basicAuthentication = SwiftHomeCredentials.basicAuthentication
        let plainString = "\(basicAuthentication.id):\(basicAuthentication.password)".data(using: String.Encoding.utf8)
        let credential = plainString?.base64EncodedString(options: [])
        let headers: Alamofire.HTTPHeaders = [
            "Authorization": "Basic \(credential!)"
        ]
        let urlString = "\(serverConfig.URLString(type: .api))/\(EndPointKind.nfcId.endPoint)"
        AF.request(urlString,
                   method: .post,
                   parameters: parameters,
                   headers: headers)
        // If 'emptyResponseCodes' is not specified, an error will occur if the response is empty.
        .responseDecodable(of: Empty.self, emptyResponseCodes: [200]) { response in
            switch response.result {
            case .success:
                print("Success")
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension CardReaderViewModel: FeliCaReaderSessionDelegate {
    func feliCaReaderSession(didRead feliCaCardData: FeliCaCardData, pollingErrors: [FeliCaSystemCode : Error?]?, readErrors: [FeliCaSystemCode : [FeliCaServiceCode : Error]]?) {
        let suicaId = feliCaCardData.primaryIDm
        print(suicaId)
        DispatchQueue.main.async {
            self.suicaId = suicaId
        }
    }

    func feliCaReaderSession(didInvalidateWithError pollingErrors: [FeliCaSystemCode : Error?]?, readErrors: [FeliCaSystemCode : [FeliCaServiceCode : Error]]?) {
    }

    func japanNFCReaderSession(didInvalidateWithError error: Error) {
    }
}
