//
//  TXTReaderView.swift
//  AlReader
//
//  Created by 何玉栋 on 3/7/25.
//

import SwiftUI
import UIKit

struct TXTReaderView: View {
    let fileURL: URL // 传入的 .txt 文件路径

    var body: some View {
        TextReaderViewControllerRepresentable(fileURL: fileURL)
            .edgesIgnoringSafeArea(.all)
    }
}

// 使用 UIViewControllerRepresentable 包装 UIKit 的 UITextView
struct TextReaderViewControllerRepresentable: UIViewControllerRepresentable {
    let fileURL: URL

    func makeUIViewController(context: Context) -> TextReaderViewController {
        let viewController = TextReaderViewController()
        viewController.loadText(from: fileURL)
        return viewController
    }

    func updateUIViewController(_ uiViewController: TextReaderViewController, context: Context) {}
}

// 使用 TextKit 2 实现文本阅读
class TextReaderViewController: UIViewController {
    private let textView = UITextView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextView()
    }

    private func setupTextView() {
        textView.isEditable = false
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.backgroundColor = .systemBackground
        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)

        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textView.topAnchor.constraint(equalTo: view.topAnchor),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // 加载 .txt 文件内容
    func loadText(from fileURL: URL) {
        do {
            let text = try String(contentsOf: fileURL, encoding: .utf8)
            textView.text = text
        } catch {
            print("❌ 加载文本失败: \(error.localizedDescription)")
        }
    }
}
