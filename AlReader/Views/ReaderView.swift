import SwiftUI

struct ReaderView: View {
    let bookURL: URL
    @State private var bookPages: [String] = []
    @State private var currentPage: Int = 0
    @State private var isLoading = true // 记录加载状态

    var body: some View {
        ZStack {
            TabView(selection: $currentPage) {
                ForEach(0..<bookPages.count, id: \.self) { index in
                    Text(bookPages[index])
                        .padding()
                        .font(.system(size: 18))
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .navigationTitle(bookURL.lastPathComponent)
            .onAppear {
                loadBookContent()
                restoreReadingProgress()
            }
            .onDisappear {
                saveReadingProgress()
            }

            // 显示加载指示器
            if isLoading {
                ProgressView("加载中...")
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }

    /// **异步加载书籍**
    private func loadBookContent() {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let content = try String(contentsOf: bookURL, encoding: .utf8)
                let pages = paginateText(content)
                
                DispatchQueue.main.async {
                    bookPages = pages
                    isLoading = false
                }
            } catch {
                print("❌ 无法读取书籍内容: \(error.localizedDescription)")
            }
        }
    }

    /// **按需分页，避免卡顿**
    private func paginateText(_ text: String) -> [String] {
        let maxCharsPerPage = 1000 // 适当增加单页字符数，减少分页计算压力
        var pages: [String] = []
        var start = text.startIndex

        while start < text.endIndex {
            let end = text.index(start, offsetBy: maxCharsPerPage, limitedBy: text.endIndex) ?? text.endIndex
            let pageText = text[start..<end]

            // 确保分页不会截断单词
            if let lastSpace = pageText.lastIndex(of: " ") {
                pages.append(String(text[start..<lastSpace]))
                start = text.index(after: lastSpace)
            } else {
                pages.append(String(pageText))
                start = end
            }
        }
        return pages
    }

    /// **保存阅读进度**
    private func saveReadingProgress() {
        UserDefaults.standard.set(currentPage, forKey: bookURL.lastPathComponent)
    }

    /// **恢复阅读进度**
    private func restoreReadingProgress() {
        if let savedPage = UserDefaults.standard.value(forKey: bookURL.lastPathComponent) as? Int {
            currentPage = savedPage
        }
    }
}
