//
//  Forms.swift
//  FormsSample
//
//  Created by Chris Eidhof on 26.03.18.
//  Copyright © 2018 objc.io. All rights reserved.
//

import UIKit

class Section: Equatable {
    let cells: [FormCell]
    var previouslyVisibleCells: [FormCell] = []
    var visibleCells: [FormCell] {
        return cells.filter({ $0.isVisible })
    }
    var footerTitle: String?
    var isVisible: Bool
    init(cells: [FormCell], footerTitle: String?, isVisible: Bool) {
        self.cells = cells
        self.footerTitle = footerTitle
        self.isVisible = isVisible
        previouslyVisibleCells = visibleCells
    }

    static func ==(lhs: Section, rhs: Section) -> Bool {
        return lhs === rhs
    }
}

class FormCell: UITableViewCell {
    var shouldHighlight = false
    var didSelect: (() -> ())?
    var isVisible: Bool = true
}

class FormViewController: UITableViewController {
    var sections: [Section] = []
    var previouslyVisibleSections: [Section] = []
    var visibleSections: [Section] {
        return sections.filter { $0.isVisible }
    }
    var firstResponder: UIResponder?

    func reloadSections() {
//        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        for index in sections.indices {
            let section = sections[index]
            let newIndex = visibleSections.index(of: section)
            let oldIndex = previouslyVisibleSections.index(of: section)
            switch (newIndex, oldIndex) {
            case (nil, nil), (.some, .some): break
            case let (newIndex?, nil):
                tableView.insertSections([newIndex], with: .fade)
            case let (nil, oldIndex?):
                tableView.deleteSections([oldIndex], with: .fade)
            }

            reloadRowsInSection(index)

            let footer = tableView.footerView(forSection: index)
            footer?.textLabel?.text = tableView(tableView, titleForFooterInSection: index)
            footer?.setNeedsLayout()

        }
        tableView.endUpdates()
//        UIView.setAnimationsEnabled(true)

        previouslyVisibleSections = visibleSections
    }

    func reloadRowsInSection(_ sectionIndex: Int) {
        let section = sections[sectionIndex]
        for index in section.cells.indices {
            let cell = section.cells[index]
            let newIndex = section.visibleCells.index(of: cell)
            let oldIndex = section.previouslyVisibleCells.index(of: cell)
            switch (newIndex, oldIndex) {
            case (nil, nil), (.some, .some): break
            case let (newIndex?, nil):
                let indexPaths = [IndexPath(row: newIndex, section: sectionIndex)]
                tableView.insertRows(at: indexPaths, with: .fade)
            case let (nil, oldIndex?):
                let indexPaths = [IndexPath(row: oldIndex, section: sectionIndex)]
                tableView.deleteRows(at: indexPaths, with: .fade)
            }
        }

        section.previouslyVisibleCells = section.visibleCells
    }

    init(sections: [Section], title: String, firstResponder: UIResponder? = nil) {
        self.firstResponder = firstResponder
        self.sections = sections
        super.init(style: .grouped)
        previouslyVisibleSections = visibleSections
        navigationItem.title = title
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        firstResponder?.becomeFirstResponder()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return visibleSections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visibleSections[section].visibleCells.count
    }

    func cell(for indexPath: IndexPath) -> FormCell {
        return visibleSections[indexPath.section].visibleCells[indexPath.row]
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cell(for: indexPath)
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return cell(for: indexPath).shouldHighlight
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return visibleSections[section].footerTitle
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cell(for: indexPath).didSelect?()
    }

}

class FormDriver<State> {
    var formViewController: FormViewController!
    var rendered: RenderedElement<[Section], State>!

    var state: State {
        didSet {
            print(state)
            rendered.update(state)
            formViewController.reloadSections()
        }
    }

    init(initial state: State, build: (RenderingContext<State>) -> RenderedElement<[Section], State>) {
        self.state = state
        let context = RenderingContext(state: state, change: { [unowned self] f in
            f(&self.state)
            }, pushViewController: { [unowned self] vc in
                self.formViewController.view.endEditing(false)
                self.formViewController.navigationController?.pushViewController(vc, animated: true)
            }, popViewController: {
                self.formViewController.navigationController?.popViewController(animated: true)
        })
        self.rendered = build(context)
        rendered.update(state)
        formViewController = FormViewController(sections: rendered.element, title: "Personal Hotspot Settings")
    }
}

final class TargetAction {
    let execute: () -> ()
    init(_ execute: @escaping () -> ()) {
        self.execute = execute
    }
    @objc func action(_ sender: Any) {
        execute()
    }
}

struct RenderedElement<Element, State> {
    var element: Element
    var strongReferences: [Any]
    var update: (State) -> ()
}

struct RenderingContext<State> {
    let state: State
    let change: ((inout State) -> ()) -> ()
    let pushViewController: (UIViewController) -> ()
    let popViewController: () -> ()
}

struct NestedRenderingContext<State, Parent> {
    let state: State
    let change: ((inout State, inout Parent) -> ()) -> ()
    let pushViewController: (UIViewController) -> ()
    let popViewController: () -> ()
}

struct AmountCellConfig<State> {
    let icon: UIImage

    let isEditingKeyPath: KeyPath<State, Bool>
    let isVisibleKeyPath: KeyPath<State, Bool>

    //Amount
    let amountValueKeyPath: WritableKeyPath<State, String>
    let amountColorKeyPath: KeyPath<State, UIColor>
    let amountPlaceholderValueKeyPath: KeyPath<State, String>
    let amountPlaceholderColorKeyPath: KeyPath<State, UIColor>

    //Currency
    let isCurrencyEnabledKeyPath: KeyPath<State, Bool>
    let isCurrencyVisibleKeyPath: KeyPath<State, Bool>
    let currencyValueKeyPath: WritableKeyPath<State, String>
    let currencyColorKeyPath: KeyPath<State, UIColor>

    //Error Message
    let isErrorMessageVisibleKeyPath: KeyPath<State, Bool>
    let errorMessageKeyPath: KeyPath<State, String>
    let errorMessageColorKeyPath: KeyPath<State, UIColor>

    //Validation Message
    let validationMessages: WritableKeyPath<State, [String]>
}

struct TextFieldConfig<State> {
    let isEditingKeyPath: KeyPath<State, Bool>
    let valueKeyPath: WritableKeyPath<State, String>
    let colorKeyPath: KeyPath<State, UIColor>
    let font: UIFont
    let placeholderValueKeyPath: KeyPath<State, String>?
    let placeholderColorKeyPath: KeyPath<State, UIColor>?
}

func amountCell<State>(_ config: AmountCellConfig<State>) -> Element<FormCell, State> {
    return { context in
        let cell = FormCell()
        let iconPadding: CGFloat = 15

        let imageView = UIImageView(image: config.icon)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        cell.contentView.addSubview(imageView)
        cell.contentView.addConstraints([
            imageView.heightAnchor.constraint(equalToConstant: iconPadding),
            imageView.widthAnchor.constraint(equalToConstant: iconPadding),
            imageView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: iconPadding),
            imageView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 21.0)
            ])

        let textFieldConfig: TextFieldConfig<State> =
            TextFieldConfig(
                isEditingKeyPath: config.isEditingKeyPath,
                valueKeyPath: config.amountValueKeyPath,
                colorKeyPath: config.amountColorKeyPath,
                font: UIFont.systemFont(ofSize: 26.0, weight: .regular),
                placeholderValueKeyPath: config.amountPlaceholderValueKeyPath,
                placeholderColorKeyPath: config.amountPlaceholderColorKeyPath
            )

        let amountTextField = textField(textFieldConfig)
        let renderedTextField = amountTextField(context)

        let errorMessageLabel = uiLabel(keyPath: config.errorMessageKeyPath)
        let renderedErrorMessageLabel = errorMessageLabel(context)

        let stackView = UIStackView(arrangedSubviews: [renderedTextField.element])
        stackView.axis = .vertical
        stackView.spacing = 0.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .horizontal)

        cell.contentView.addSubview(stackView)
        cell.contentView.addConstraints([
            stackView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: iconPadding),
            stackView.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
        ])

        let currencySeparatorView = UIView()
        currencySeparatorView.backgroundColor = UIColor.gray
        currencySeparatorView.translatesAutoresizingMaskIntoConstraints = false

        cell.contentView.addSubview(currencySeparatorView)
        cell.contentView.addConstraints([
            currencySeparatorView.leadingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: iconPadding),
            currencySeparatorView.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            currencySeparatorView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
            currencySeparatorView.widthAnchor.constraint(equalToConstant: 1.0)
            ])

        let currencyButton = UIButton(type: .custom)
        currencyButton.translatesAutoresizingMaskIntoConstraints = false

        cell.contentView.addSubview(currencyButton)
        cell.contentView.addConstraints([
            currencyButton.leadingAnchor.constraint(equalTo: currencySeparatorView.trailingAnchor),
            currencyButton.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            currencyButton.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
            currencyButton.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
            currencyButton.widthAnchor.constraint(equalToConstant: 60.0)
            ])

        cell.contentView.addConstraints([
            cell.contentView.heightAnchor.constraint(equalToConstant: 56.0)
            ])

        return RenderedElement(element: cell, strongReferences: renderedTextField.strongReferences + renderedErrorMessageLabel.strongReferences, update: { (state) in
            renderedTextField.update(state)
            renderedErrorMessageLabel.update(state)
//            cell.isVisible = state[keyPath: config.isVisibleKeyPath]
            currencyButton.setTitle(state[keyPath: config.currencyValueKeyPath], for: .normal)
            currencyButton.setTitleColor(state[keyPath: config.currencyColorKeyPath], for: .normal)
            cell.accessoryType = state[keyPath: config.isEditingKeyPath] ? .disclosureIndicator : .none

            if state[keyPath: config.isErrorMessageVisibleKeyPath] {
                stackView.addArrangedSubview(renderedErrorMessageLabel.element)
            } else if stackView.arrangedSubviews.contains(renderedErrorMessageLabel.element) {
                stackView.removeArrangedSubview(renderedErrorMessageLabel.element)
                renderedErrorMessageLabel.element.removeFromSuperview()
            }
        })
    }
}


func uiStackView<State>(elements: [Element<UIView, State>], axis: NSLayoutConstraint.Axis = .horizontal, spacing: CGFloat = 10) -> Element<UIView, State> {
    return { context in
        let renderedElements = elements.map { $0(context) }
        let strongReferences = renderedElements.flatMap { $0.strongReferences }

        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = axis
        stackView.spacing = spacing
        for renderedElement in renderedElements {
            stackView.addArrangedSubview(renderedElement.element)
        }

        let update: (State) -> () = { state in
            for c in renderedElements {
                c.update(state)
            }
        }
        
        return RenderedElement(element: stackView, strongReferences: strongReferences, update: update)
    }
}

func uiImageView<State>(keyPath: KeyPath<State, UIImage>) -> Element<UIView, State> {
    return { context in
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false

        return RenderedElement(element: imageView, strongReferences: [], update: { (state) in
            imageView.image = state[keyPath: keyPath]
        })
    }
}

func uiLabel<State>(keyPath: KeyPath<State, String>) -> Element<UIView, State> {
    return { context in
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false

        return RenderedElement(element: label, strongReferences: [], update: { (state) in
            label.text = state[keyPath: keyPath]
        })
    }
}

func uiSwitch<State>(keyPath: WritableKeyPath<State, Bool>) -> Element<UIView, State> {
    return { context in
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        let toggleTarget = TargetAction {
            context.change { $0[keyPath: keyPath] = toggle.isOn }
        }
        toggle.addTarget(toggleTarget, action: #selector(TargetAction.action(_:)), for: .valueChanged)
        return RenderedElement(element: toggle, strongReferences: [toggleTarget], update: { state in
            toggle.isOn = state[keyPath: keyPath]
        })
    }
}

class FormTextFieldDelegate: NSObject, UITextFieldDelegate {
    let callback: (String) -> ()

    init(_ callback: @escaping (String) -> ()) {
        self.callback = callback
        print("init")
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let textFieldString = textField.text,
            let swtRange = Range(range, in: textFieldString) {
            callback(textFieldString.replacingCharacters(in: swtRange, with: string))
        }

        return true
    }

    deinit {
        print("Deallocating")
    }
}

func textField<State>(keyPath: WritableKeyPath<State, String>) -> Element<UIView, State> {
    return { context in
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        let didEnd = TargetAction {
            context.change { $0[keyPath: keyPath] = textField.text ?? "" }
        }
        let didExit = TargetAction {
            context.change { $0[keyPath: keyPath] = textField.text ?? "" }
            context.popViewController()
        }

        textField.addTarget(didEnd, action: #selector(TargetAction.action(_:)), for: .editingDidEnd)
        textField.addTarget(didExit, action: #selector(TargetAction.action(_:)), for: .editingDidEndOnExit)
        return RenderedElement(element: textField, strongReferences: [didEnd, didExit], update: { state in
            textField.text = state[keyPath: keyPath]
        })
    }
}

func textField<State>(_ config: TextFieldConfig<State>) -> Element<UIView, State> {
    return { context in
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = config.font

        let didEnd = TargetAction {
            context.change {
                $0[keyPath: config.valueKeyPath] = textField.text ?? ""
            }
        }

        let didExit = TargetAction {
            context.change {
                $0[keyPath: config.valueKeyPath] = textField.text ?? ""
            }
        }

        let delegate = FormTextFieldDelegate({ (newString) in
//            context.change {
//                print(newString)
//                $0[keyPath: config.valueKeyPath] = newString
//            }
        })

        textField.delegate = delegate

        textField.addTarget(didEnd, action: #selector(TargetAction.action(_:)), for: .editingDidEnd)
        textField.addTarget(didExit, action: #selector(TargetAction.action(_:)), for: .editingDidEndOnExit)
        return RenderedElement(element: textField, strongReferences: [didEnd, didExit, delegate], update: { state in
            textField.isUserInteractionEnabled = state[keyPath: config.isEditingKeyPath]
            textField.text = state[keyPath: config.valueKeyPath]
            textField.textColor = state[keyPath: config.colorKeyPath]

            //Placeholder
            if  let placeholderValueKeyPath = config.placeholderValueKeyPath,
                let placeholderColorKeyPath = config.placeholderColorKeyPath {
                textField.attributedPlaceholder = NSAttributedString(string: state[keyPath: placeholderValueKeyPath],
                                                                     attributes: [NSAttributedStringKey.foregroundColor: state[keyPath: placeholderColorKeyPath]])
            } else if let placeholderValueKeyPath = config.placeholderValueKeyPath {
                textField.placeholder = state[keyPath: placeholderValueKeyPath]
            }

        })
    }
}

func controlCell<State>(title: String, control: @escaping Element<UIView, State>, leftAligned: Bool = false, isVisible: KeyPath<State, Bool>? = nil) -> Element<FormCell, State> {
    return { context in
        let cell = FormCell(style: .value1, reuseIdentifier: nil)
        let renderedControl = control(context)
        cell.textLabel?.text = title
        cell.contentView.addSubview(renderedControl.element)
        cell.contentView.addConstraints([
            renderedControl.element.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            renderedControl.element.trailingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.trailingAnchor)
            ])
        if leftAligned {
            cell.contentView.addConstraint(
                renderedControl.element.leadingAnchor.constraint(equalTo: cell.textLabel!.trailingAnchor, constant: 20))
        }

        let update: (State) -> () = { state in
            renderedControl.update(state)

            if let iv = isVisible {
                cell.isVisible = state[keyPath: iv]
            }
        }

        return RenderedElement(element: cell, strongReferences: renderedControl.strongReferences, update: update)
    }
}

func stackViewCell<State>(control: @escaping Element<UIView, State>, isVisible: KeyPath<State, Bool>? = nil, isEditing: KeyPath<State, Bool>? = nil) -> Element<FormCell, State> {
    return { context in
        let cell = FormCell()
        let renderedControl = control(context)

        cell.contentView.addSubview(renderedControl.element)
        cell.contentView.addConstraints([
            renderedControl.element.leadingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.leadingAnchor),
            renderedControl.element.topAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.topAnchor),
            renderedControl.element.trailingAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.trailingAnchor),
            renderedControl.element.bottomAnchor.constraint(equalTo: cell.contentView.layoutMarginsGuide.bottomAnchor)
        ])

        let update: (State) -> () = { state in
            renderedControl.update(state)

            if let iv = isVisible {
                cell.isVisible = state[keyPath: iv]
            }

            if let isEditingKeyPath = isEditing {
                cell.accessoryType = state[keyPath: isEditingKeyPath] ? .disclosureIndicator : .none
                cell.shouldHighlight = state[keyPath: isEditingKeyPath]
            }
        }

        return RenderedElement(element: cell, strongReferences: renderedControl.strongReferences, update: update)
    }
}

func detailTextCell<State>(title: String, keyPath: KeyPath<State, String>, isEditing: KeyPath<State, Bool>? = nil, form: @escaping Form<State>) -> Element<FormCell, State> {
    return { context in
        let cell = FormCell(style: .value1, reuseIdentifier: nil)
        cell.textLabel?.text = title
        let rendered = form(context)
        let nested = FormViewController(sections: rendered.element, title: title)
        cell.didSelect = {
            context.pushViewController(nested)
        }

        let update: (State) -> () = { state in
            if let isEditingKeyPath = isEditing {
                cell.accessoryType = state[keyPath: isEditingKeyPath] ? .disclosureIndicator : .none
                cell.shouldHighlight = state[keyPath: isEditingKeyPath]
            } else {
                cell.accessoryType = .disclosureIndicator
                cell.shouldHighlight = true
            }

            cell.detailTextLabel?.text = state[keyPath: keyPath]
            rendered.update(state)
            nested.reloadSections()
        }

        return RenderedElement(element: cell, strongReferences: rendered.strongReferences, update: update)
    }
}

func bind<State, NestedState>(form: @escaping Form<NestedState>, to keyPath: WritableKeyPath<State, NestedState>) -> Form<State> {
    return { context in
        let nestedContext = RenderingContext<NestedState>(state: context.state[keyPath: keyPath], change: { nestedChange in
            context.change { state in
                nestedChange(&state[keyPath: keyPath])
            }
        }, pushViewController: context.pushViewController, popViewController: context.popViewController)
        let sections = form(nestedContext)
        return RenderedElement<[Section], State>(element: sections.element, strongReferences: sections.strongReferences, update: { state in
            sections.update(state[keyPath: keyPath])
        })
    }
}

func section<State>(_ cells: [Element<FormCell, State>], footer keyPath: KeyPath<State, String?>? = nil, isVisible: KeyPath<State, Bool>? = nil) -> Element<Section, State> {
    return { context in
        let renderedCells = cells.map { $0(context) }
        let strongReferences = renderedCells.flatMap { $0.strongReferences }
        let section = Section(cells: renderedCells.map { $0.element }, footerTitle: nil, isVisible: true)
        let update: (State) -> () = { state in
            for c in renderedCells {
                c.update(state)
            }
            if let kp = keyPath {
                section.footerTitle = state[keyPath: kp]
            }
            if let iv = isVisible {
                section.isVisible = state[keyPath: iv]
            }
        }
        return RenderedElement(element: section, strongReferences: strongReferences, update: update)
    }
}

// todo DRY
func sections<State>(_ sections: [Element<Section, State>]) -> Form<State> {
    return { context in
        let renderedSections = sections.map { $0(context) }
        let strongReferences = renderedSections.flatMap { $0.strongReferences }
        let update: (State) -> () = { state in
            for c in renderedSections {
                c.update(state)
            }
        }
        return RenderedElement(element: renderedSections.map { $0.element }, strongReferences: strongReferences, update: update)
    }
}

func nestedTextField<State>(title: String, keyPath: WritableKeyPath<State, String>) -> Element<FormCell, State> {
    let nested: Form<State> =
        sections([section([controlCell(title: title, control: textField(keyPath: keyPath), leftAligned: true)])])
    return detailTextCell(title: title, keyPath: keyPath, form: nested)
}


typealias Element<El, A> = (RenderingContext<A>) -> RenderedElement<El, A>
typealias Form<A> = Element<[Section], A>

func optionCell<Input: Equatable, State>(title: String, option: Input, keyPath: WritableKeyPath<State, Input>) -> Element<FormCell, State> {
    return { context in
        let cell = FormCell(style: .value1, reuseIdentifier: nil)
        cell.textLabel?.text = title
        cell.shouldHighlight = true
        cell.didSelect = {
            context.change { $0[keyPath: keyPath] = option }
        }
        return RenderedElement(element: cell, strongReferences: [], update: { state in
            cell.accessoryType = state[keyPath: keyPath] == option ? .checkmark : .none
        })
    }
}
