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

protocol IsEditable {
    var isEditing: Bool { get }
}

struct Settings: IsEditable {
    var isEditing: Bool = false

    var hotspot = Hotspot()

    //Amount & Currency Cells
    var emptyAmountCell = AmountCell.empty
    var emptyHasErrorAmountCell = AmountCell.emptyHasError
    var hasFocusAmountCell = AmountCell.hasFocus
    var hasValueAmountCell = AmountCell.hasValue

    var hotspotEnabled: String {
        return hotspot.isEnabled ? "On" : "Off"
    }

    var amountCellAmountAmountColor: UIColor {
        return isEditing ? .black : .red
    }
}

struct AmountCell {
    var amount: Amount
    var currency: Currency

    var hasError: Bool

    var isCurrencyEnabled: Bool
    var isCurrencyVisible: Bool
    var isVisible: Bool

    var validationMessages: [String]
}

extension AmountCell {
    init(amount: Amount, currency: Currency) {
        self.init(
            amount: amount,
            currency: currency,
            hasError: false,
            isCurrencyEnabled: true,
            isCurrencyVisible: true,
            isVisible: true,
            validationMessages: []
        )
    }
}

extension AmountCell {
    var icon: UIImage {
       return UIImage(named: "amountIcon")!
    }

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

//Variations
extension AmountCell {
    static var empty: AmountCell {
        return AmountCell(
            amount: .empty,
            currency: .newZealandDollar,
            hasError: false,
            isCurrencyEnabled: true,
            isCurrencyVisible: true,
            isVisible: true,
            validationMessages: []
        )
    }

    static var emptyHasError: AmountCell {
        return AmountCell(
            amount: .empty,
            currency: .newZealandDollar,
            hasError: true,
            isCurrencyEnabled: true,
            isCurrencyVisible: true,
            isVisible: true,
            validationMessages: ["Error related to this cell"]
        )
    }

    static var hasFocus: AmountCell {
        return AmountCell(
            amount: Amount(value: ""),
            currency: .austrailianDollar,
            hasError: false,
            isCurrencyEnabled: true,
            isCurrencyVisible: true,
            isVisible: true,
            validationMessages: []
        )
    }

    static var hasValue: AmountCell {
        return AmountCell(
            amount: Amount(value: "25.00"),
            currency: .austrailianDollar,
            hasError: false,
            isCurrencyEnabled: true,
            isCurrencyVisible: true,
            isVisible: true,
            validationMessages: []
        )
    }
}

struct Amount {
    var value: String?
}

extension Amount {
    var amountColor: UIColor {
        return .black
    }

    var amountPlaceholderValue: String {
        return "0.00"
    }

    var amountPlaceholderColor: UIColor {
        return .gray
    }
}

//Variations
extension Amount {
    static var empty: Amount {
        return Amount(value: nil)
    }
}

struct Currency {
    var currencyCode: String
}

extension Currency {
    var currencyColor: UIColor {
        return .gray
    }
}

extension Currency {
    static var newZealandDollar: Currency {
        return Currency(currencyCode: "NZD")
    }

    static var austrailianDollar: Currency {
        return Currency(currencyCode: "AUD")
    }
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

let emptyAmountCellConfig: AmountCellConfig<Settings> =
    AmountCellConfig<Settings>(
        icon: UIImage(named: "amountIcon")!,
        isEditingKeyPath: \.isEditing,
        isVisibleKeyPath: \.emptyAmountCell.isVisible,
        amountValueKeyPath: \.emptyAmountCell.amount.value,
        amountColorKeyPath: \.emptyAmountCell.amount.amountColor,
        amountPlaceholderValueKeyPath: \.emptyAmountCell.amount.amountPlaceholderValue,
        amountPlaceholderColorKeyPath: \.emptyAmountCell.amount.amountPlaceholderColor,
        isCurrencyEnabledKeyPath: \.emptyAmountCell.isCurrencyEnabled,
        isCurrencyVisibleKeyPath: \.emptyAmountCell.isCurrencyVisible,
        currencyValueKeyPath: \.emptyAmountCell.currency.currencyCode,
        currencyColorKeyPath: \.emptyAmountCell.currency.currencyColor,
        isErrorMessageVisibleKeyPath: \.emptyAmountCell.isErrorMessageVisible,
        errorMessageKeyPath: \.emptyAmountCell.errorMessage,
        errorMessageColorKeyPath: \.emptyAmountCell.errorMessageColor,
        validationMessages: \.emptyAmountCell.validationMessages
)

let emptyHasErrorAmountCellConfig: AmountCellConfig<Settings> =
    AmountCellConfig<Settings>(
        icon: UIImage(named: "amountIcon")!,
        isEditingKeyPath: \.isEditing,
        isVisibleKeyPath: \.emptyHasErrorAmountCell.isVisible,
        amountValueKeyPath: \.emptyHasErrorAmountCell.amount.value,
        amountColorKeyPath: \.emptyHasErrorAmountCell.amount.amountColor,
        amountPlaceholderValueKeyPath: \.emptyHasErrorAmountCell.amount.amountPlaceholderValue,
        amountPlaceholderColorKeyPath: \.emptyHasErrorAmountCell.amount.amountPlaceholderColor,
        isCurrencyEnabledKeyPath: \.emptyHasErrorAmountCell.isCurrencyEnabled,
        isCurrencyVisibleKeyPath: \.emptyHasErrorAmountCell.isCurrencyVisible,
        currencyValueKeyPath: \.emptyHasErrorAmountCell.currency.currencyCode,
        currencyColorKeyPath: \.emptyHasErrorAmountCell.currency.currencyColor,
        isErrorMessageVisibleKeyPath: \.emptyHasErrorAmountCell.isErrorMessageVisible,
        errorMessageKeyPath: \.emptyHasErrorAmountCell.errorMessage,
        errorMessageColorKeyPath: \.emptyHasErrorAmountCell.errorMessageColor,
        validationMessages: \.emptyHasErrorAmountCell.validationMessages
)

let hasFocusAmountCellConfig: AmountCellConfig<Settings> =
    AmountCellConfig<Settings>(
        icon: UIImage(named: "amountIcon")!,
        isEditingKeyPath: \.isEditing,
        isVisibleKeyPath: \.hasFocusAmountCell.isVisible,
        amountValueKeyPath: \.hasFocusAmountCell.amount.value,
        amountColorKeyPath: \.hasFocusAmountCell.amount.amountColor,
        amountPlaceholderValueKeyPath: \.hasFocusAmountCell.amount.amountPlaceholderValue,
        amountPlaceholderColorKeyPath: \.hasFocusAmountCell.amount.amountPlaceholderColor,
        isCurrencyEnabledKeyPath: \.hasFocusAmountCell.isCurrencyEnabled,
        isCurrencyVisibleKeyPath: \.hasFocusAmountCell.isCurrencyVisible,
        currencyValueKeyPath: \.hasFocusAmountCell.currency.currencyCode,
        currencyColorKeyPath: \.hasFocusAmountCell.currency.currencyColor,
        isErrorMessageVisibleKeyPath: \.hasFocusAmountCell.isErrorMessageVisible,
        errorMessageKeyPath: \.hasFocusAmountCell.errorMessage,
        errorMessageColorKeyPath: \.hasFocusAmountCell.errorMessageColor,
        validationMessages: \.hasFocusAmountCell.validationMessages
)

//func foo() {
//    let settingsKp = \Settings.isEditing
//    
//}


//return { context in
//    let nestedContext = RenderingContext<NestedState>(state: context.state[keyPath: keyPath], change: { nestedChange in
//        context.change { state in
//            nestedChange(&state[keyPath: keyPath])
//        }
//    }, pushViewController: context.pushViewController, popViewController: context.popViewController)
//    let sections = form(nestedContext)
//    return RenderedElement<[Section], State>(element: sections.element, strongReferences: sections.strongReferences, update: { state in
//        sections.update(state[keyPath: keyPath])
//    })
//}

//func bind<State, NestedState>(cell: @escaping Form<NestedState>, to keyPath: WritableKeyPath<State, NestedState>) -> Form<State> {
//    return { context in
//        let nestedContext = RenderingContext<NestedState>(state: context.state[keyPath: keyPath], change: { nestedChange in
//            context.change { state in
//                nestedChange(&state[keyPath: keyPath])
//            }
//        }, pushViewController: context.pushViewController, popViewController: context.popViewController)
//        let sections = form(nestedContext)
//        return RenderedElement<[Section], State>(element: sections.element, strongReferences: sections.strongReferences, update: { state in
//            sections.update(state[keyPath: keyPath])
//        })
//    }
//}

//func amountCellConfigFactory<State: IsEditable>(state: State, keyPath: WritableKeyPath<State, AmountCell>) -> AmountCellConfig<AmountCell> {
////    let nestedState = state[keyPath: keyPath]
////    let state: KeyPath = \State.isEditing
////
////    let kp2: KeyPath = \State.isEditing
//
//    return AmountCellConfig<AmountCell>(
//        icon: UIImage(named: "amountIcon")!,
//        isEditingKeyPath: \.isVisible,
//        isVisibleKeyPath: \.isVisible,
//        amountValueKeyPath: \.amount.value,
//        amountColorKeyPath: \.amount.amountColor,
//        amountPlaceholderValueKeyPath: \.amount.amountPlaceholderValue,
//        amountPlaceholderColorKeyPath: \.amount.amountPlaceholderColor,
//        isCurrencyEnabledKeyPath: \.isCurrencyEnabled,
//        isCurrencyVisibleKeyPath: \.isCurrencyVisible,
//        currencyValueKeyPath: \.currency.currencyCode,
//        currencyColorKeyPath: \.currency.currencyColor,
//        isErrorMessageVisibleKeyPath: \.isErrorMessageVisible,
//        errorMessageKeyPath: \.errorMessage,
//        errorMessageColorKeyPath: \.errorMessageColor,
//        validationMessages: \.validationMessages
//    )
//
//
//}

//let amountCell1: Element<FormCell, Settings> = amountCell(
//    AmountCellConfig<Settings>(
//        icon: UIImage(named: "amountIcon")!,
//        isEditingKeyPath: \Settings.isEditing,
//        isVisibleKeyPath: \.hasFocusAmountCell.isVisible,
//        amountValueKeyPath: \.hasFocusAmountCell.amount.value,
//        amountColorKeyPath: \.hasFocusAmountCell.amount.amountColor,
//        amountPlaceholderValueKeyPath: \.hasFocusAmountCell.amount.amountPlaceholderValue,
//        amountPlaceholderColorKeyPath: \.hasFocusAmountCell.amount.amountPlaceholderColor,
//        isCurrencyEnabledKeyPath: \.hasFocusAmountCell.isCurrencyEnabled,
//        isCurrencyVisibleKeyPath: \.hasFocusAmountCell.isCurrencyVisible,
//        currencyValueKeyPath: \.hasFocusAmountCell.currency.currencyCode,
//        currencyColorKeyPath: \.hasFocusAmountCell.currency.currencyColor,
//        isErrorMessageVisibleKeyPath: \.hasFocusAmountCell.isErrorMessageVisible,
//        errorMessageKeyPath: \.hasFocusAmountCell.errorMessage,
//        errorMessageColorKeyPath: \.hasFocusAmountCell.errorMessageColor,
//        validationMessages: \.hasFocusAmountCell.validationMessages
//    )
//    )

//let amountCell1: Element<FormCell, Settings> =
//    controlCell(title: "Test", control: textField(keyPath: \Settings.emptyAmountCell.currency.currencyCode), leftAligned: true)
//
//let stackView: Element<UIView, AmountCell> =
//    uiStackView(elements: [
//            uiImageView(keyPath: \.icon),
//            uiLabel(keyPath: \.currency.currencyCode),
//            uiLabel(keyPath: \.currency.currencyCode),
//            uiLabel(keyPath: \.errorMessage)
//        ], axis: .horizontal, spacing: 10)
//
//let amountCellWithStackView: Element<FormCell, Settings> =
//    stackViewCell(control: stackView, isEditing: \Settings.isEditing)

let settingsForm: Form<Settings> =
    sections([
        section([
            controlCell(title: "Is Editing", control: uiSwitch(keyPath: \.isEditing)),
//            controlCell(title: "Is Error", control: uiSwitch(keyPath: \.emptyAmountCell.hasError)),
            ]),
        section([
            detailTextCell(title: "Personal Hotspot", keyPath: \Settings.hotspotEnabled, isEditing:  \Settings.isEditing, form: bind(form: hotspotForm, to: \.hotspot))
            ]),
        section([
            amountCell(emptyAmountCellConfig),
            amountCell(emptyHasErrorAmountCellConfig),
            amountCell(hasFocusAmountCellConfig),
            //hasValueAmountCellConfig
            amountCell(
                AmountCellConfig<Settings>(
                    icon: UIImage(named: "amountIcon")!,
                    isEditingKeyPath: \.isEditing,
                    isVisibleKeyPath: \.hasValueAmountCell.isVisible,
                    amountValueKeyPath: \.hasValueAmountCell.amount.value,
                    amountColorKeyPath: \.hasValueAmountCell.amount.amountColor,
                    amountPlaceholderValueKeyPath: \.hasValueAmountCell.amount.amountPlaceholderValue,
                    amountPlaceholderColorKeyPath: \.hasValueAmountCell.amount.amountPlaceholderColor,
                    isCurrencyEnabledKeyPath: \.hasValueAmountCell.isCurrencyEnabled,
                    isCurrencyVisibleKeyPath: \.hasValueAmountCell.isCurrencyVisible,
                    currencyValueKeyPath: \.hasValueAmountCell.currency.currencyCode,
                    currencyColorKeyPath: \.hasValueAmountCell.currency.currencyColor,
                    isErrorMessageVisibleKeyPath: \.hasValueAmountCell.isErrorMessageVisible,
                    errorMessageKeyPath: \.hasValueAmountCell.errorMessage,
                    errorMessageColorKeyPath: \.hasValueAmountCell.errorMessageColor,
                    validationMessages: \.hasValueAmountCell.validationMessages
                )
            ),
            //Itemized Empty
            amountCell(
                AmountCellConfig<Settings>(
                    icon: UIImage(named: "amountIcon")!,
                    isEditingKeyPath: \.isEditing,
                    isVisibleKeyPath: \.hasValueAmountCell.isVisible,
                    amountValueKeyPath: \.hasValueAmountCell.amount.value,
                    amountColorKeyPath: \.hasValueAmountCell.amount.amountColor,
                    amountPlaceholderValueKeyPath: \.hasValueAmountCell.amount.amountPlaceholderValue,
                    amountPlaceholderColorKeyPath: \.hasValueAmountCell.amount.amountPlaceholderColor,
                    isCurrencyEnabledKeyPath: \.hasValueAmountCell.isCurrencyEnabled,
                    isCurrencyVisibleKeyPath: \.hasValueAmountCell.isCurrencyVisible,
                    currencyValueKeyPath: \.hasValueAmountCell.currency.currencyCode,
                    currencyColorKeyPath: \.hasValueAmountCell.currency.currencyColor,
                    isErrorMessageVisibleKeyPath: \.hasValueAmountCell.isErrorMessageVisible,
                    errorMessageKeyPath: \.hasValueAmountCell.errorMessage,
                    errorMessageColorKeyPath: \.hasValueAmountCell.errorMessageColor,
                    validationMessages: \.hasValueAmountCell.validationMessages
                    )
                ),
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


