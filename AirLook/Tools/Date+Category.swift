//
//  Date+Category.swift
//  AirLook
//
//  Created by HeiKki on 2018/1/5.
//  Copyright © 2018年 XiaQi. All rights reserved.
//


let dateFormat = DateFormatter()
let calendar = Calendar.current

extension Date {
    static func timeStringToDate(timeString: String) -> Date {
        dateFormat.dateFormat = "EEE MMM dd HH:mm:ss zzz yyyy"
        dateFormat.locale = Locale(identifier: "en")
        return dateFormat.date(from: timeString)!
    }
    func dateToShowTime() -> String {
        if calendar.isDateInToday(self) {
            let timeInterval = Int(Date().timeIntervalSince(self))
            if timeInterval < 60 {
                return "刚刚"
            }
            if timeInterval < 60 * 60 {
                return "\(timeInterval / 60)分钟前"
            }
            return "\(timeInterval / 3600)小时前"
        }
        if calendar.isDateInYesterday(self) {
            dateFormat.dateFormat = "昨天 HH:mm "
        } else {
            let year = calendar.component(.year, from: self)
            let thisYear = calendar.component(.year, from: Date())
            if year == thisYear {
                dateFormat.dateFormat = "MM-dd HH:mm"
            } else {
                dateFormat.dateFormat = "yyyy-MM-dd HH:mm"
            }
        }
        dateFormat.locale = Locale(identifier: "en")
        return dateFormat.string(from: self)
    }
}

