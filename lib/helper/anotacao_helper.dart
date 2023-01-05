import 'package:minhas_anotacoes/models/anotacao.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class AnotacaoHelper {
  static final AnotacaoHelper _anotacaoHelper = AnotacaoHelper._internal();

  Database? _db;

  static const String nomeTabela = "anotacao";

  Future<int> saveAnotacao(Anotacao anotacao) async {
    var bancoDados = await db;

    int id = await bancoDados.insert(nomeTabela, anotacao.toMap());
    return id;
  }

  factory AnotacaoHelper() {
    return _anotacaoHelper;
  }

  AnotacaoHelper._internal();

  get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await inicialiaDB();
      return _db;
    }
  }

  _onCreate(Database db, int version) async {
    String sql = "CREATE TABLE $nomeTabela"
        " (id INTEGER PRIMARY KEY AUTOINCREMENT"
        ", titulo VARCHAR"
        ", descricao TEXT"
        ", data DATETIME )";
    await db.execute(sql);
  }

  inicialiaDB() async {
    final caminhoBancoDados = await getDatabasesPath();
    final localBancoDados =
        p.join(caminhoBancoDados, "banco_minhas_anotacoes.db");
    var db =
        await openDatabase(localBancoDados, version: 1, onCreate: _onCreate);
    return db;
  }

  recuperarAnotacoes() async {
    var bancoDados = await db;
    String sql = "SELECT * FROM $nomeTabela ORDER BY data DESC";
    List anotacoes = await bancoDados.rawQuery(sql);
    return anotacoes;
  }

  Future<int> atualizarAnotacao(Anotacao anotacao) async {
    Database bancoDados = await db;
    Map<String, dynamic> map = {
      'id': anotacao.id,
      'titulo': anotacao.title,
      'descricao': anotacao.descripition,
      'data': anotacao.data
    };
    int registrosUp = await bancoDados
        .update(nomeTabela, map, where: "id = ?", whereArgs: [anotacao.id]);

    return registrosUp;
  }

  Future<int> removerAnotacao(int? id) async {
    Database bancoDados = await db;
    int resultado =
        await bancoDados.delete(nomeTabela, where: "id = ?", whereArgs: [id]);
    return resultado;
  }
}
