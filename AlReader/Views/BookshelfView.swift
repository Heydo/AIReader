import SwiftUI
import UniformTypeIdentifiers

struct BookshelfView: View {
    @State private var books: [URL] = []
    @State private var isImporting: Bool = false // 控制文件选择器是否显示
    @State private var showAlert: Bool = false // 控制弹窗显示
    @State private var alertMessage: String = "" // 存储弹窗提示信息

    var body: some View {
        NavigationView {
            VStack {
                // 书架标题 + 导入按钮
                HStack {
                    Text("书架")
                        .font(.largeTitle)
                        .bold()

                    Spacer()

                    Button(action: {
                        isImporting = true // 打开文件选择器
                    }) {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                }
                .padding(.horizontal)
                .padding(.top)

                // 书籍列表
                List(books, id: \.self) { book in
                                NavigationLink(destination: ReaderView(bookURL: book)) {
                                    Text(book.lastPathComponent)
                                }
                            }
            }
            .onAppear {
                books = FileManagerHelper.shared.listBooks()
            }
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [UTType.plainText, UTType.epub],
                allowsMultipleSelection: false
            ) { result in
                handleFileImport(result: result)
                isImporting = false // ✅ 关闭选择器后重置状态
            }
            // 绑定 Alert
            .alert(isPresented: $showAlert) {
                Alert(title: Text("提示"), message: Text(alertMessage), dismissButton: .default(Text("确定")))
            }
        }
    }

    // 处理文件导入
    private func handleFileImport(result: Result<[URL], Error>) {
        do {
            let selectedFiles = try result.get()
            guard let selectedFile = selectedFiles.first else { return }

            // 尝试复制文件
            let success = FileManagerHelper.shared.copyBookToDocuments(from: selectedFile)

            // 如果失败，则弹出提示
            if !success {
                alertMessage = "文件已存在: \(selectedFile.lastPathComponent)"
                showAlert = true
            }

            // 重新加载书籍列表
            books = FileManagerHelper.shared.listBooks()
        } catch {
            print("❌ 文件导入失败: \(error.localizedDescription)")
        }
    }
}
