import SwiftUI
import UniformTypeIdentifiers // 添加导入语句

struct BookshelfView: View {
    @State private var books: [URL] = []
    @State private var isImporting: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

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
                        isImporting = true
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
                    NavigationLink(destination: getReaderView(for: book)) {
                        Text(book.lastPathComponent)
                    }
                }
            }
            .onAppear {
                books = FileManagerHelper.shared.listBooks()
            }
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [UTType.plainText, UTType.epub], // 使用 UTType
                allowsMultipleSelection: false
            ) { result in
                handleFileImport(result: result)
                isImporting = false
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("提示"), message: Text(alertMessage), dismissButton: .default(Text("确定")))
            }
        }
    }

    // 根据文件格式返回对应的阅读视图
    private func getReaderView(for fileURL: URL) -> some View {
        if fileURL.pathExtension == "txt" {
            return AnyView(TXTReaderView(fileURL: fileURL))
        } else if fileURL.pathExtension == "epub" {
            return AnyView(Text("EPUB 阅读功能待实现")) // 后续替换为 EPUBReaderView
        } else {
            return AnyView(Text("不支持的文件格式"))
        }
    }

    // 处理文件导入
    private func handleFileImport(result: Result<[URL], Error>) {
        do {
            let selectedFiles = try result.get()
            guard let selectedFile = selectedFiles.first else { return }

            let success = FileManagerHelper.shared.copyBookToDocuments(from: selectedFile)
            if !success {
                alertMessage = "文件已存在: \(selectedFile.lastPathComponent)"
                showAlert = true
            }

            books = FileManagerHelper.shared.listBooks()
        } catch {
            print("❌ 文件导入失败: \(error.localizedDescription)")
        }
    }
}
