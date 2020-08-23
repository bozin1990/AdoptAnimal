//
//  Adopt.swift
//  AdoptAnimal
//
//  Created by 陳博軒 on 2020/8/1.
//  Copyright © 2020 Bozin. All rights reserved.
//

import Foundation

struct Adopt: Decodable {
    var animalSubid: String               //動物的流水編號
    var animalKind: AnimalKind          //動物的類型 [貓 | 狗 | 鳥 ...]
    var animalSex: String?           //動物性別 [M | F | N](公、母、未輸入)
    var animalColour: String? = nil        //動物花色
    var animalAge: String           //動物年紀 [CHILD | ADULT](幼年、成年)
    var animalSterilization: String //是否絕育 [T | F | N](是、否、未輸入)
    var animalBacterin: String      //是否施打狂犬病疫苗 [T | F | N](是、否、未輸入)
    var animalFoundplace: String    //動物尋獲地(文字敘述)
    var animalStatus: String        //動物狀態 [NONE | OPEN | ADOPTED | OTHER | DEAD]
    //(未公告、開放認養、已認養、其他、死亡)
    var animalRemark: String
    var animalOpendate: String      //開放認養時間(起)
    var shelterName: String         //動物所屬收容所名稱
    var albumFile: String           //圖片名稱
    var cDate: String               //資料更新時間
    var shelterAddress: String? = nil      //地址
    var shelterTel: String             //連絡電話
    
    init(animalSubid: String, animalKind: AnimalKind, animalSex: String, animalColour: String, animalAge: String, animalSterilization: String, animalBacterin: String, animalFoundplace: String, animalStatus: String, animalRemark: String, animalOpendate: String, shelterName: String, albumFile: String, cDate: String, shelterAddress: String, shelterTel: String) {
        self.animalSubid = animalSubid
        self.animalKind = animalKind
        self.animalSex = animalSex
        self.animalColour = animalColour
        self.animalAge = animalAge
        self.animalSterilization = animalSterilization
        self.animalBacterin = animalBacterin
        self.animalFoundplace = animalFoundplace
        self.animalStatus = animalStatus
        self.animalRemark = animalRemark
        self.animalOpendate = animalOpendate
        self.shelterName = shelterName
        self.albumFile = albumFile
        self.cDate = cDate
        self.shelterAddress = shelterAddress
        self.shelterTel = shelterTel
    }
    
    enum CodingKeys: String, CodingKey {
        case animalSubid = "animal_subid"
        case animalKind = "animal_kind"
        case animalSex = "animal_sex"
        case animalColour = "animal_colour"
        case animalAge = "animal_age"
        case animalSterilization = "animal_sterilization"
        case animalBacterin = "animal_bacterin"
        case animalFoundplace = "animal_foundplace"
        case animalStatus = "animal_status"
        case animalRemark = "animal_remark"
        case animalOpendate = "animal_opendate"
        case shelterName = "shelter_name"
        case albumFile = "album_file"
        case cDate
        case shelterAddress = "shelter_address"
        case shelterTel = "shelter_tel"
    }
    
    enum AnimalKind: Decodable {
        case all
        case dog
        case cat
        case other
    }
}

extension Adopt.AnimalKind: CaseIterable { }

extension Adopt.AnimalKind: RawRepresentable {
    typealias RawValue = String
    
    init?(rawValue: RawValue) {
        switch rawValue {
        case "全部": self = .all
        case "狗": self = .dog
        case "貓": self = .cat
        case "其他": self = .other
        default: return nil
        }
    }
    
    var rawValue: RawValue {
        switch self {
        case .all: return "全部"
        case .dog: return "狗"
        case .cat: return "貓"
        case .other: return "其他"
        }
    }
}

