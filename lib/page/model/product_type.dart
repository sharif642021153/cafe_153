class ListProductType {
  int? value;
  String? name;

  ListProductType(this.value, this.name);

  static List<ListProductType> getListProductType() {
    return [
      ListProductType(1, 'กาแฟ'),
      ListProductType(2, 'ชา'),
      ListProductType(3, 'นม'),
    ];
  }
}