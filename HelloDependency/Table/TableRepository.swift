struct TableData {
    let title: String
}
protocol TableRepository {
    var dataCount: Int { get }
    func getData(for row: Int) -> TableData
}
class TableRepositoryImpl: TableRepository {
    private let data: [TableData] = [TableData(title: "title 0"),
                                     TableData(title: "title 1"),
                                     TableData(title: "title 2"),
                                     TableData(title: "title 3"),
                                     TableData(title: "title 4"),
                                     TableData(title: "title 5"),
                                     TableData(title: "title 6"),
                                     TableData(title: "title 7"),
                                     TableData(title: "title 8")]
    var dataCount: Int {
        return data.count
    }
    func getData(for row: Int) -> TableData {
        return data[row]
    }
}
