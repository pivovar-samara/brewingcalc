import Foundation

func l(_ key: String) -> String {
    NSLocalizedString(key, comment: "")
}

let bcEmail = "brewingcalc@gmail.com"

var isRussian: Bool {
    Locale.current.language.languageCode?.identifier == "ru"
}
