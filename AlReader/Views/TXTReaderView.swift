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
    
    // 初始化时开启电池监控
    init(fileURL: URL) {
        self.fileURL = fileURL
        UIDevice.current.isBatteryMonitoringEnabled = true
    }
    
    var body: some View {
        VStack {
            // 中间内容区域
            TextReaderViewControllerRepresentable(fileURL: fileURL)
            
            // 底部状态栏
            HStack {
                Text(currentTime, formatter: dateFormatter)
                Spacer()
                Text(batteryStatusText) // 使用计算属性处理显示逻辑
            }
            .padding()
            .frame(height: UIFont.preferredFont(forTextStyle: .body).pointSize * 1.5)
            .onReceive(timer) { _ in
                currentTime = Date()
                updateBatteryLevel()
            }
        }
        .navigationTitle(fileURL.lastPathComponent)
        .navigationBarTitleDisplayMode(.inline)
    }
    // 安全更新电量
    private func updateBatteryLevel() {
        batteryLevel = UIDevice.current.isBatteryMonitoringEnabled ? 
            UIDevice.current.batteryLevel : 
            -1 // 用-1表示不可用
    }
    
    // 电量显示文本逻辑
    private var batteryStatusText: String {
        guard UIDevice.current.isBatteryMonitoringEnabled else {
            return "电量: 不可用"
        }
        
        let level = Int(batteryLevel * 100)
        return batteryLevel < 0 ? "电量: 读取中..." : "电量: \(level)%"
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

    private var errorMessage: String? {
        didSet {
            updateErrorDisplay()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextView()

        setupErrorLabel()
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

    private func setupErrorLabel() {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .systemRed
        label.textAlignment = .center
        label.isHidden = true
        label.tag = 999 // 用于后续查找
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func updateErrorDisplay() {
        guard let label = view.viewWithTag(999) as? UILabel else { return }
        
        if let message = errorMessage {
            label.text = "⚠️ 加载失败\n\(message)"
            label.isHidden = false
            textView.isHidden = true
        } else {
            label.isHidden = true
            textView.isHidden = false
        }
    }

    // 加载 .txt 文件内容
    func loadText(from fileURL: URL) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            do {
                let text = try String(contentsOf: fileURL, encoding: .utf8)
                
                // 验证文件内容是否为空
                guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                    throw NSError(domain: "TXTReaderError", code: 2, userInfo: [
                        NSLocalizedDescriptionKey: "文件内容为空"
                    ])
                }
                
                DispatchQueue.main.async {
                    self?.errorMessage = nil
                    self?.textView.text = text
                }
            } catch {
                let errorMessage: String
                
                switch (error as NSError).code {
                case NSFileReadNoSuchFileError:
                    errorMessage = "文件不存在"
                case NSFileReadNoPermissionError:
                    errorMessage = "无权限访问文件"
                case NSFileReadUnknownStringEncodingError:
                    errorMessage = "不支持的文本编码（请使用UTF-8格式）"
                default:
                    errorMessage = error.localizedDescription
                }
                
                DispatchQueue.main.async {
                    self?.errorMessage = errorMessage
                }
            }
        }
    }

    deinit {
        // 清理时关闭电池监控（如果是全局单例需要更复杂的处理）
        UIDevice.current.isBatteryMonitoringEnabled = false
    }
}
