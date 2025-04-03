//
//  TXTReaderView.swift
//  AlReader
//
//  Created by 何玉栋 on 3/7/25.
//

import SwiftUI
import UIKit
import Combine

struct TXTReaderView: View {
    let fileURL: URL // 传入的 .txt 文件路径
    @State private var batteryLevel: Float = UIDevice.current.batteryLevel
    @State private var currentTime = Date()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            // 中间内容区域
            TextReaderViewControllerRepresentable(fileURL: fileURL)
            
            // 底部状态栏
            HStack {
                Text(currentTime, formatter: dateFormatter)
                Spacer()
                Text("电量: \(Int(batteryLevel * 100))%")
            }
            .padding()
            .frame(height: UIFont.preferredFont(forTextStyle: .body).pointSize * 1.5)
            .onReceive(timer) { _ in
                currentTime = Date()
                batteryLevel = UIDevice.current.batteryLevel
            }
        }
        .navigationTitle(fileURL.lastPathComponent)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
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
        textView.font = UIFont.preferredFont(forTextStyle: .body).withSize(18)
        
        // 设置段落样式
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6 // 行距
        paragraphStyle.paragraphSpacing = 12 // 段间距
        
        textView.typingAttributes = [
            .font: UIFont.preferredFont(forTextStyle: .body).withSize(18),
            .paragraphStyle: paragraphStyle
        ]
        textView.attributedText = NSAttributedString(string: textView.text ?? "", attributes: [
            .font: UIFont.preferredFont(forTextStyle: .body).withSize(18),
            .paragraphStyle: paragraphStyle
        ])
        
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
