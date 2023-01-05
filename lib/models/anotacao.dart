class Anotacao {
  int? id;
  String title;
  String descripition;
  String data;

  Anotacao(
      {required this.title, required this.descripition, required this.data});

  Map toMap() {
    Map<String, dynamic> map = {
      "titulo": title,
      "descricao": descripition,
      "data": data
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }
}
