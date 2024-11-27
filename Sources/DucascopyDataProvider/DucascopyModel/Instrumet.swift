//
//  Instrumet.swift
//  Ducascopy
//
//  Created by Vitali Kurlovich on 17.11.24.
//

import Foundation

public struct Instrumet: Decodable {
    public let title: String
    public let name: String
    public let description: String
    public let historical_filename: String?
    public let special: Bool
    public let pipValue: Double

    public let base_currency: String
    public let quote_currency: String

    public let tag_list: [String]

    public let history_start_tick: String
    public let history_start_10sec: String
    public let history_start_60sec: String
    public let history_start_60min: String
    public let history_start_day: String

    public let unit: String?
}

/*

 "title": "0027.HK/HKD",
 "special": false,
 "name": "0027.HK/HKD",
 "description": "Galaxy Entertainment Group",
 "historical_filename": "0027HKHKD",
 "pipValue": 0.01,
 "base_currency": "0027.HK",
 "quote_currency": "HKD",
 "commodities_per_contract": null,
 "tag_list": [
   "CFD_INSTRUMENTS",
   "GLOBAL_ACCOUNTS"
 ],
 "history_start_tick": "1514854800158",
 "history_start_10sec": "1537925400000",
 "history_start_60sec": "1514854800000",
 "history_start_60min": "1514854800000",
 "history_start_day": "0",
 "unit": null,

 */
