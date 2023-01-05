import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:minhas_anotacoes/helper/anotacao_helper.dart';
import 'package:minhas_anotacoes/models/anotacao.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _titleControler = TextEditingController();
  final TextEditingController _descriptionControler = TextEditingController();

  List<Anotacao> _anotacoes = [];

  final _db = AnotacaoHelper();

  _removerAnotacao(int? id) async {
    if (id != null) {
      await _db.removerAnotacao(id);
      _recuperarAnotacoes();
    }
  }

  _dialogExcluir(int? id) {
    showDialog(
        context: context,
        builder: ((context) {
          return AlertDialog(
            title: const Text("Deseja Ecluir a anotação"),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    _removerAnotacao(id);

                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("SIM")),
              ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("NÃO"))
            ],
          );
        }));
  }

  _recuperarAnotacoes() async {
    List anotacoesRecuperadas = await _db.recuperarAnotacoes();
    _anotacoes.clear();
    for (var item in anotacoesRecuperadas) {
      Anotacao anotacao = Anotacao(
          title: item['titulo'],
          descripition: item['descricao'],
          data: item['data']);
      anotacao.id = item['id'];
      _anotacoes.add(anotacao);
    }

    setState(() {
      _anotacoes = _anotacoes;
    });
  }

  _salvarAtualizarAnotacao({Anotacao? anotacaoSelecionada}) async {
    String titulo = _titleControler.text;
    String descricao = _descriptionControler.text;

    if (anotacaoSelecionada == null) {
      Anotacao anotacao = Anotacao(
          title: titulo,
          descripition: descricao,
          data: DateTime.now().toString());

      if (titulo.isNotEmpty || descricao.isNotEmpty) {
        await _db.saveAnotacao(anotacao);
      }
    } else {
      anotacaoSelecionada.title = titulo;
      anotacaoSelecionada.descripition = descricao;
      anotacaoSelecionada.data = DateTime.now().toString();
      await _db.atualizarAnotacao(anotacaoSelecionada);
    }

    _titleControler.clear();
    _descriptionControler.clear();
  }

  _screenCad({Anotacao? anotacao}) {
    String textoSalvarAtualizar = "";
    if (anotacao == null) {
      _titleControler.clear();
      _descriptionControler.clear();
      textoSalvarAtualizar = "Salvar";
    } else {
      _titleControler.text = anotacao.title;
      _descriptionControler.text = anotacao.descripition;
      textoSalvarAtualizar = "Atualizar";
    }

    showDialog(
        context: context,
        builder: ((context) {
          return AlertDialog(
            title: Text("$textoSalvarAtualizar Anotação"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleControler,
                  autofocus: true,
                  decoration: const InputDecoration(
                      labelText: "titulo", hintText: "Digite o título..."),
                ),
                TextField(
                  controller: _descriptionControler,
                  decoration: const InputDecoration(
                      labelText: "descrição",
                      hintText: "Digite a descrição..."),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    _salvarAtualizarAnotacao(anotacaoSelecionada: anotacao);
                    _recuperarAnotacoes();
                    Navigator.pop(context);
                  },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: Text(textoSalvarAtualizar)),
              ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("Cancelar")),
            ],
          );
        }));
  }

  @override
  void initState() {
    super.initState();
    _recuperarAnotacoes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Anotações")),
      body: Column(children: [
        Expanded(
            child: ListView.builder(
                itemCount: _anotacoes.length,
                itemBuilder: ((context, index) {
                  final item = _anotacoes[index];
                  String date = DateFormat('dd/MM/yyyy HH:mm')
                      .format(DateTime.parse(item.data));
                  return Card(
                    child: ListTile(
                      title: Text(item.title),
                      subtitle: Text("$date"
                          " - ${item.descripition}"),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        GestureDetector(
                          onTap: () {
                            _screenCad(anotacao: item);
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(right: 16),
                            child: Icon(
                              Icons.edit,
                              color: Colors.green,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _dialogExcluir(item.id);
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Icon(
                              Icons.remove_circle,
                              color: Colors.red,
                            ),
                          ),
                        )
                      ]),
                    ),
                  );
                })))
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _screenCad();
        },
        child: const Icon(
          Icons.add,
          size: 40,
        ),
      ),
    );
  }
}
