//
//  EditField.swift
//  Sakentry
//
//  Created by Takao Shimizu on 2021/01/16.
//

import FirebaseAuth
import SwiftUI

struct EditField: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.presentationMode) var presentation
    
    let fieldIndex: Int
    let field: String
    let type: String
    @Binding var fieldValues: [String]
    @State var fieldValueLocal: String
    let language: String
    let genders: [String]
    @State var showTextField: Bool
    let regionData: NSDictionary?
    let country: String?
    
    init(fieldIndex: Int, fieldValues: Binding<[String]>) {
        let fields: [String] = [
            "firstName", "lastName", "displayName", "gender", "country", "region",
            "language", "bio" // edit fieldTypes accordingly
        ]
        self.fieldIndex = fieldIndex
        self.field = fields[fieldIndex]
        self._fieldValues = fieldValues
        self._fieldValueLocal = State(initialValue: fieldValues.wrappedValue[fieldIndex])
        
        let fieldTypes: [String] = [
            "type", "type", "type", "gender", "country", "region", "language", "type"
        ]
        let type: String = fieldTypes[fieldIndex]
        self.type = type
        self.genders = [
            "male", "female", "genderqueer", "other", "prefer not to say"
        ]
        if !genders.contains(fieldValues.wrappedValue[fieldIndex]) && fieldValues.wrappedValue[fieldIndex] != "" {
            self._showTextField = State(initialValue: true)
        } else {
            self._showTextField = State(initialValue: false)
        }
        
        if type == "region" {
            self.regionData = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "region", ofType:"plist")!)
            if let countryIndex = fields.firstIndex(where: { $0 == "country" }) {
                self.country = fieldValues.wrappedValue[countryIndex]
            } else {
                self.country = "JP"
            }
        } else {
            self.regionData = nil
            self.country = nil
        }
        
        if let languageIndex = fields.firstIndex(where: { $0 == "language" }) {
            self.language = fieldValues.wrappedValue[languageIndex]
        } else {
            self.language = "en"
        }
    }
    
    var body: some View {
        // if user type directly
        if self.type == "type" {
            VStack {
                TextField(NSLocalizedString("fill_the_field_here", lang: self.language), text: self.$fieldValueLocal)
                    .padding()
                    .disableAutocorrection(true)
                Spacer()
            }
            .navigationBarTitle(NSLocalizedString(self.field, lang: self.language))
            .navigationBarItems(trailing: Button(action: {
                self.fieldValues[self.fieldIndex] = self.fieldValueLocal
                self.presentation.wrappedValue.dismiss()
            }, label: {
                Text(NSLocalizedString("save", lang: self.language))
            }))
        }
        
        // if user is choosing their gender
        else if self.type ==  "gender" {
            List(self.genders, id: \.self) { gender in
                VStack(alignment: .leading) {
                    Button(action: {
                        if gender == "other" {
                            self.fieldValueLocal = ""
                            self.showTextField = true
                        } else {
                            self.showTextField = false
                            self.fieldValues[self.fieldIndex] = gender
                            self.presentation.wrappedValue.dismiss()
                        }
                    }, label: {
                        Text(NSLocalizedString(gender, lang: self.language))
                    })
                    if gender == "other" && self.showTextField {
                        TextField(NSLocalizedString("fill_the_field_here", lang: self.language), text: self.$fieldValueLocal)
                            .padding()
                            .disableAutocorrection(true)
                    }
                }
            }
            .navigationBarTitle(NSLocalizedString(self.field, lang: self.language))
            .navigationBarItems(trailing: Button(action: {
                self.fieldValues[self.fieldIndex] = self.fieldValueLocal
                self.presentation.wrappedValue.dismiss()
            }, label: {
                Text(NSLocalizedString("save", lang: self.language))
            }).disabled(!self.showTextField || self.fieldValueLocal == ""))
        }
        
        // if user is choosing a country they live in
        else if self.type == "country" {
            List (NSLocale.isoCountryCodes, id: \.self) { id in
                let name: String? = NSLocale(localeIdentifier: language)
                    .displayName(forKey: NSLocale.Key.countryCode, value: id)
                Button(action: {
                    self.fieldValues[self.fieldIndex] = id
                    self.presentation.wrappedValue.dismiss()
                }, label: {
                    Text(name ?? NSLocalizedString("no_country_found", lang: self.language))
                })
            }
            .navigationBarTitle(NSLocalizedString(self.field, lang: self.language))
        }
        
        // if user is choosing a regin they live in
        // currently this is only for Japan/US residents
        else if self.type == "region" {
            if let regionData = self.regionData {
                if countries.contains(self.country ?? "JP") {
                    let regions = regionData[self.country] as! Array<String>
                    List(regions, id: \.self) { region in
                        Button(action: {
                            self.fieldValues[self.fieldIndex] = region
                            self.presentation.wrappedValue.dismiss()
                        }, label: {
                            Text(NSLocalizedString(region, lang: language))
                        })
                    }
                    .navigationBarTitle(NSLocalizedString(self.field, lang: language))
                }
                else {
                    Text("SOMETHING WENT WRONG")
                }
            }
            else {
                Text("SOMETHING WENT WRONG")
            }
        }
        else if self.type == "language" {
            List(langs, id: \.self) { lang in
                Button(action: {
                    self.fieldValues[self.fieldIndex] = lang
                    self.presentation.wrappedValue.dismiss()
                }, label: {
                    Text(NSLocalizedString(lang, lang: authManager.user.language))
                })
            }
            .navigationBarTitle(NSLocalizedString(self.field, lang: self.language))
        }
        
        else {
            Text("SOMETHING WENT WRONG")
        }
    }
}
