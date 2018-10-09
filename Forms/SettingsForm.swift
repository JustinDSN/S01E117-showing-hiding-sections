//
//  ViewController.swift
//  FormsSample
//
//  Created by Chris Eidhof on 22.03.18.
//  Copyright © 2018 objc.io. All rights reserved.
//

import UIKit

enum ShowPreview {
    case always
    case never
    case whenUnlocked

    static let all: [ShowPreview] = [.always, .whenUnlocked, .never]

    var text: String {
        switch self {
        case .always: return "Always"
        case .whenUnlocked: return "When Unlocked"
        case .never: return "Never"
        }
    }
}

struct Hotspot {
    var isEnabled: Bool = false
    var isReallyEnabled: Bool = false
    var password: String = "hello"
    var networkName: String = "my network"
    var showPreview: ShowPreview = .always
}

struct Settings {
    var isEditing: Bool = false

    var hotspot = Hotspot()
    var amountCell = AmountCell()

    var hotspotEnabled: String {
        return hotspot.isEnabled ? "On" : "Off"
    }

    var amountCellAmountAmountColor: UIColor {
        return isEditing ? .black : .red
    }
}

struct AmountCell {
    var hasError: Bool = false
    var isVisible: Bool = true
    var icon: UIImage = UIImage(named: "amountIcon")!
    var amount: Amount = Amount()
    var currency: Currency = Currency()
    var validationMessages: [String] = ["helo", "world"]

    var isCurrencyEnabled: Bool {
        return true
    }

    var isCurrencyVisible: Bool {
        return true
    }
}

extension AmountCell {
    var isErrorMessageVisible: Bool {
        return hasError  //TODO: IsEditing
    }

    var errorMessage: String {
        return validationMessages.joined(separator: ", ")
    }

    var errorMessageColor: UIColor {
        return .red
    }
}

struct Amount {
    var amountValue: String = "123.00"
    var amountColor: UIColor = .black
    var amountPlaceholderValue: String = "0.00"
    var amountPlaceholderColor: UIColor = .gray
}

struct Currency {
    var currencyCode: String = "NZD"
    var currencyColor: UIColor = .gray
}

extension Hotspot {
    var enabledSectionTitle: String? {
        return isEnabled ? "Personal Hotspot Enabled" : nil
    }
}

let showPreviewForm: Form<Hotspot> =
    sections([
        section(
            ShowPreview.all.map { option in
                optionCell(title: option.text, option: option, keyPath: \.showPreview)
            }
        )
    ])


//let stackView: Element<UIView, Settings> =
//    uiStackView(elements: [
//            uiImageView(keyPath: \Settings.amountCell.icon),
//            uiLabel(keyPath: \Settings.amountCell.amount.amountValue),
//            uiLabel(keyPath: \Settings.amountCell.currency.currencyCode),
//            uiLabel(keyPath: \Settings.amountCell.errorMessage)
//        ], axis: .horizontal, spacing: 10)
//
//let amountCell: Element<FormCell, Settings> =
//    stackViewCell(control: stackView, isEditing: \Settings.isEditing)

let amountCellConfig: AmountCellConfig<Settings> =
    AmountCellConfig<Settings>(
        icon: UIImage(named: "amountIcon")!,
        isEditingKeyPath: \.isEditing,
        isVisibleKeyPath: \.amountCell.isVisible,
        amountValueKeyPath: \.amountCell.amount.amountValue,
        amountColorKeyPath: \.amountCell.amount.amountColor,
        amountPlaceholderValueKeyPath: \.amountCell.amount.amountPlaceholderValue,
        amountPlaceholderColorKeyPath: \.amountCell.amount.amountPlaceholderColor,
        isCurrencyEnabledKeyPath: \.amountCell.isCurrencyEnabled,
        isCurrencyVisibleKeyPath: \.amountCell.isCurrencyVisible,
        currencyValueKeyPath: \.amountCell.currency.currencyCode,
        currencyColorKeyPath: \.amountCell.currency.currencyColor,
        isErrorMessageVisibleKeyPath: \.amountCell.isErrorMessageVisible,
        errorMessageKeyPath: \.amountCell.errorMessage,
        errorMessageColorKeyPath: \.amountCell.errorMessageColor,
        validationMessages: \.amountCell.validationMessages
    )

let amountCell1: Element<FormCell, Settings> = amountCell(amountCellConfig)

let settingsForm: Form<Settings> =
    sections([
        section([
            controlCell(title: "Is Editing", control: uiSwitch(keyPath: \.isEditing)),
            controlCell(title: "Is Error", control: uiSwitch(keyPath: \.amountCell.hasError)),
        ]),
        section([
            detailTextCell(title: "Personal Hotspot", keyPath: \Settings.hotspotEnabled, isEditing:  \Settings.isEditing, form: bind(form: hotspotForm, to: \.hotspot))
        ]),
        section([
            amountCell(amountCellConfig)
        ]),
        section([
            nestedTextField(title: "Your Amount", keyPath: \Settings.amountCell.amount.amountValue)
        ])
    ]
)

let hotspotForm: Form<Hotspot> =
    sections([
        section([
            controlCell(title: "Personal Hotspot", control: uiSwitch(keyPath: \.isEnabled)),
            controlCell(title: "Is Really Enabled", control: uiSwitch(keyPath: \.isReallyEnabled), isVisible: \.isEnabled)
            ], footer: \.enabledSectionTitle),
        section([
            detailTextCell(title: "Notification", keyPath: \.showPreview.text, form: showPreviewForm)
            ], isVisible: \.isReallyEnabled),
        section([
            nestedTextField(title: "Password", keyPath: \.password),
            nestedTextField(title: "Network Name", keyPath: \.networkName)
            ], isVisible: \.isReallyEnabled)
        ])


