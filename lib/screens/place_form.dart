import 'dart:math';

import 'package:f3_lugares/utils/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../components/recommendation_modal.dart';
import '../data/my_data.dart';
import '../models/place.dart';

class PlaceForm extends StatefulWidget {
  @override
  State<PlaceForm> createState() => _PlaceFormState();
}

class _PlaceFormState extends State<PlaceForm> {
  final _titleController = TextEditingController();
  final _rateController = TextEditingController();
  final _averageCostController = TextEditingController();
  final _imgURLController = TextEditingController();

  late FocusNode titleNode;
  late FocusNode avgCostNode;
  late FocusNode rateNode;
  late FocusNode imgUrlNode;

  List<String> countries = [];
  String title = '';
  String rate = '';
  String avgCost = '';
  String imageURL = '';
  bool isRateValid = false;
  bool isAvgCostValid = false;
  bool isTitleValid = false;
  bool isPlaceAdded = false;
  bool isUrlEmpty = true;
  List<String> recommendations = [];

  static const snackBarCountryError = SnackBar(
    content: Text('Selecione pelo menos 1 país'),
    duration: const Duration(seconds: 1),
  );
  static const snackBarRecommendationError = SnackBar(
    content: Text('Cadastre pelo menos 1 recomendação'),
    duration: const Duration(seconds: 1),
  );

  @override
  void initState() {
    titleNode = FocusNode();
    avgCostNode = FocusNode();
    rateNode = FocusNode();
    imgUrlNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    titleNode.dispose();
    avgCostNode.dispose();
    rateNode.dispose();
    imgUrlNode.dispose();
    super.dispose();
  }

  void _validateForm() {
    if (countries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(snackBarCountryError);
      return;
    }
    if (recommendations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(snackBarRecommendationError);
      return;
    }
    if (!isTitleValid) {
      FocusScope.of(context).requestFocus(titleNode);
      return;
    } else if (!isRateValid) {
      FocusScope.of(context).requestFocus(rateNode);
      return;
    } else if (!isAvgCostValid) {
      FocusScope.of(context).requestFocus(avgCostNode);
      return;
    } else if (isUrlEmpty) {
      FocusScope.of(context).requestFocus(imgUrlNode);
      return;
    } else {
      final newPlace = Place(
          id: Random().nextInt(100).toString(),
          paises: countries,
          titulo: title,
          imagemUrl: imageURL,
          recomendacoes: recommendations,
          avaliacao: double.parse(rate),
          custoMedio: double.parse(avgCost));
      DUMMY_PLACES.add(newPlace);
      isPlaceAdded = true;
      Navigator.of(context)
          .popAndPushNamed(AppRoutes.HOME, result: isPlaceAdded);
    }
  }

  void _validateRate() {
    setState(() {
      rate = _rateController.text;
      if (_rateErrorText == null) {
        isRateValid = true;
      } else {
        isRateValid = false;
      }
    });
  }

  void _validateCost() {
    setState(() {
      avgCost = _averageCostController.text;
      if (_avgCostErrorText == null) {
        isAvgCostValid = true;
      } else {
        isAvgCostValid = false;
      }
    });
  }

  void _countriesHandler(String id) {
    if (countries.contains(id)) {
      setState(() {
        countries.remove(id);
      });
    } else {
      setState(() {
        countries.add(id);
      });
    }
  }

  String? get _titleErrorText {
    if (_titleController.text == '') {
      return 'Insira um valor';
    }
    return null;
  }

  String? get _rateErrorText {
    double? rateDouble = double.tryParse(_rateController.text);
    if (_rateController.text.isEmpty) {
      return 'Insira um valor';
    }
    if (rateDouble != null) {
      if (rateDouble < 0 || rateDouble > 5) {
        return 'Valor inválido ';
      }
    }
    return null;
  }

  String? get _avgCostErrorText {
    double? avgCostDouble = double.tryParse(_averageCostController.text);
    if (_averageCostController.text.isEmpty) {
      return 'Insira um valor';
    }
    if (avgCostDouble != null) {
      if (avgCostDouble < 0) {
        return 'Valor inválido ';
      }
    }
    return null;
  }

  String? get _imgErrorText {
    if (_imgURLController.text.isEmpty) {
      return 'Insira uma url da imagem';
    }
    return null;
  }

  DropdownMenuItem<String> buildMenuItem(String item) {
    return DropdownMenuItem(
      child: Text(item),
      value: item,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context)
                .popAndPushNamed(AppRoutes.HOME, result: false),
          ),
          title: Text(
            'New Place',
          )),
      body: Container(
        padding: EdgeInsets.all(25),
        child: SingleChildScrollView(
          child: Form(
              child: Column(
            children: [
              TextField(
                  controller: _titleController,
                  autofocus: true,
                  focusNode: titleNode,
                  decoration: InputDecoration(
                      labelText: 'Título', errorText: _titleErrorText),
                  onChanged: (_) {
                    setState(() {
                      title = _titleController.text;
                      if (_titleErrorText == null) {
                        isTitleValid = true;
                      } else {
                        isTitleValid = false;
                      }
                    });
                  }),
              TextField(
                controller: _rateController,
                focusNode: rateNode,
                decoration: InputDecoration(
                    labelText: 'Nota',
                    hintText: 'Insira uma nota entre 0 e 5. Ex.: 3.5',
                    errorText: _rateErrorText),
                keyboardType: TextInputType.number,
                onChanged: (_) => _validateRate(),
              ),
              TextField(
                controller: _averageCostController,
                focusNode: avgCostNode,
                decoration: InputDecoration(
                    labelText: 'Custo médio',
                    hintText: 'Insira um valor em reais',
                    errorText: _avgCostErrorText),
                keyboardType: TextInputType.number,
                onChanged: (_) => _validateCost(),
              ),
              SizedBox(
                height: 20,
              ),
              Divider(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Selecione o país'),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    child: Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        children: DUMMY_COUNTRIES
                            .map(
                              (country) => FilterChip(
                                label: Text(country.title),
                                onSelected: (_) =>
                                    _countriesHandler(country.id),
                                backgroundColor:
                                    Theme.of(context).colorScheme.tertiary,
                                selectedColor:
                                    Theme.of(context).colorScheme.primary,
                                selected: countries.contains(country.id),
                              ),
                            )
                            .toList()),
                  ),
                  Divider(),
                  SizedBox(
                    width: 20,
                  ),
                  TextField(
                      enableInteractiveSelection: true,
                      controller: _imgURLController,
                      focusNode: imgUrlNode,
                      decoration: InputDecoration(
                          labelText: 'Link da imagem',
                          errorText: _imgErrorText),
                      onChanged: (_) => setState(() {
                            if (_imgErrorText == null) {
                              isUrlEmpty = false;
                              imageURL = _imgURLController.text;
                            } else {
                              isUrlEmpty = true;
                            }
                          })),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(child: Text('Recomendações')),
                      TextButton(
                          onPressed: () {
                            showModalBottomSheet(
                                context: context,
                                builder: (BuildContext context) {
                                  return RecommendationModal(recommendations);
                                });
                          },
                          child: Text('Gerenciar recomendações'))
                    ],
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  child: Text('Confirmar'),
                  onPressed: _validateForm,
                ),
              ),
            ],
          )),
        ),
      ),
    );
  }
}
