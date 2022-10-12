import 'dart:typed_data';
import 'package:dio/dio.dart' as diolib;
import 'package:flutter/material.dart';
import 'package:mirea_db_2/api/test_api.dart';
import 'package:mirea_db_2/model/pos_model.dart';
import 'package:image_picker/image_picker.dart';
import '../services/db_helper.dart';

class CardDetail extends StatefulWidget {
  final Pos? pos;

  const CardDetail({Key? key, this.pos}) : super(key: key);

  @override
  State<CardDetail> createState() => _CardDetailState();
}

class _CardDetailState extends State<CardDetail> {
  String titleBuffer = '';
  String descriptionBuffer = '';
  bool titleLanguageFlag = false;
  bool descriptionLanguageFlag = false;
  Uint8List? picture;
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (widget.pos != null) {
      //фикс цыганского бага
      titleController.text = titleController.text.isNotEmpty &&
              widget.pos!.title != titleController.text
          ? titleController.text
          : widget.pos!.title;
      descriptionController.text = descriptionController.text.isNotEmpty &&
              widget.pos!.description != descriptionController.text
          ? descriptionController.text
          : widget.pos!.description;
      picture = picture != widget.pos!.picture ? picture : widget.pos!.picture;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pos == null ? 'Добавить' : 'Редактировать'),
        centerTitle: true,
        backgroundColor: Color.fromARGB(200, 0, 0, 0),
      ),
      backgroundColor:Color.fromARGB(126, 87, 87, 87),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: TextFormField(
                controller: titleController,
                style: TextStyle(color:Color.fromARGB(255, 255, 255, 255)),
                maxLines: 1,
                decoration: InputDecoration(
                  //hintText: 'Введите название',
                  filled: true,
                  fillColor: Color.fromARGB(126, 87, 87, 87),
                  labelText: 'Название',
                  labelStyle: TextStyle(color:Color.fromARGB(255, 255, 255, 255)),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                      width: 0.75,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () => titleTranslator(),
                    icon: const Icon(Icons.language),
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            TextFormField(
              controller: descriptionController,
              style: TextStyle(color:Color.fromARGB(255, 255, 255, 255)),
              decoration: InputDecoration(
                //hintText: 'Введите описание',
                labelText: 'Описание',
                filled: true,
                fillColor: Color.fromARGB(126, 87, 87, 87),
                labelStyle: TextStyle(color:Color.fromARGB(255, 255, 255, 255)),
                border: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white,
                    width: 0.75,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                ),
                suffixIcon: IconButton(
                  onPressed: () => descriptionTranslator(),
                  icon: const Icon(Icons.language),
                  color: Colors.white,
                ),
              ),
              keyboardType: TextInputType.multiline,
              maxLines: 5,
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: ElevatedButton(
                style: ButtonStyle(
                    shape:
                        MaterialStateProperty.all(const RoundedRectangleBorder(
                            side: BorderSide(
                              color: Colors.white,
                              width: 0.75,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            )))),
                onPressed: () {
                  _getFromGallery();
                },
                child: const Text("Картинка"),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: SizedBox(
                height: 45,
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                    onPressed: () async {
                      final title = titleController.text;
                      final description = descriptionController.text;
                      if (title.isEmpty || description.isEmpty) {
                        return;
                      }

                      final Pos model = Pos(
                        title: title,
                        description: description,
                        id: widget.pos?.id,
                        picture: picture,
                      );
                      if (widget.pos == null) {
                        await DBHelper.addPos(model);
                      } else {
                        await DBHelper.updatePos(model);
                      }

                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                    },
                    style: ButtonStyle(
                        shape: MaterialStateProperty.all(
                            const RoundedRectangleBorder(
                                side: BorderSide(
                                  color: Colors.white,
                                  width: 0.75,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10.0),
                                )))),
                    child: Text(
                      widget.pos == null ? 'Сохранить' : 'Редактировать',
                      style: const TextStyle(fontSize: 20),
                    )),
              ),
            )
          ],
        ),
      ),
    );
  }

  _getFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    try {
      picture = await image!.readAsBytes();
      // ignore: empty_catches
    } catch (e) {}
  }

  titleTranslator() async {
    if (titleController.text.isNotEmpty) {
      titleLanguageFlag = !titleLanguageFlag;
      if (titleLanguageFlag) {
        titleBuffer = titleController.text;
        titleController.text = await fetchTranslate(titleController.text);
      } else {
        titleController.text = titleBuffer;
      }
    }
  }

  descriptionTranslator() async {
    if (descriptionController.text.isNotEmpty) {
      descriptionLanguageFlag = !descriptionLanguageFlag;
      if (descriptionLanguageFlag) {
        descriptionBuffer = descriptionController.text;
        descriptionController.text =
            await fetchTranslate(descriptionController.text);
      } else {
        descriptionController.text = descriptionBuffer;
      }
    }
  }
}
