import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sample_test_3/color_constants.dart';
import 'package:flutter_sample_test_3/data_provider.dart';
import 'package:flutter_sample_test_3/task.dart';
import 'package:flutter_sample_test_3/widgets/navigation_bar.dart';
import 'package:provider/provider.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class AddPage extends StatefulWidget {
  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final _formKey = GlobalKey<FormState>();
  var dateInputFormatter =
      MaskTextInputFormatter(mask: '##/##/##', filter: {"#": RegExp(r'[0-9]')});

  TextEditingController _categoryFieldController;
  TextEditingController _dateFieldController;

  bool _defaultToSticky;
  bool _suggestCategory;

  //The task to be added
  var task;

  @override
  void initState() {
    task = Task();
    _categoryFieldController = TextEditingController();

    //THis might cause issues with dates before 2000 :|
    DateTime _selectedDate = Provider.of<DataProvider>(context, listen: false).selectedDate;
    _defaultToSticky = Provider.of<DataProvider>(context, listen: false).defaultToSticky;
    _dateFieldController = TextEditingController(
        text: _defaultToSticky
            ? "Sticky"
            : "${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${(_selectedDate.year - 2000).toString().padLeft(2, '0')}");

    _suggestCategory = Provider.of<DataProvider>(context, listen: false).suggestCategory;

    super.initState();
  }

  @override
  void dispose() {
    _categoryFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<DataProvider, ColorConstants>(
        selector: (_, provider) => provider.colorConstants,
        builder: (_, colorConstants, __) => Scaffold(
              backgroundColor: colorConstants.background,
              body: SafeArea(
                child: Stack(
                  children: [
                    Positioned(
                      top: 0.0,
                      left: 0.0,
                      right: 0.0,
                      bottom: 0.0,
                      child: Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(12.0),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 12.0,
                              ),
                              CustomTextFormField(
                                validator: taskNameValidator,
                                labelText: "Task",
                                hintText: " Take a trip to Antarctic",
                              ),
                              SizedBox(
                                height: 32.0,
                              ),
                              CustomTextFormField(
                                  isCategory: true,
                                  controller: _categoryFieldController,
                                  suggestCategory: _suggestCategory,
                                  validator: categoryValidator,
                                  labelText: "Category",
                                  hintText: " Travel"),
                              SizedBox(
                                height: 32.0,
                              ),
                              CustomTextFormField(
                                controller: _dateFieldController,
                                validator: dateValidator,
                                labelText: "Date",
                                hintText: " DD/MM/YY",
                                inputFormatter: [dateInputFormatter],
                                keyBoardType: TextInputType.number,
                                isFinalInputField: true,
                                addTask: addTask,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0.0,
                      left: 0.0,
                      right: 0.0,
                      child: CustomBottomNavBar(
                        callback: addTask,
                      ),
                    ),
                  ],
                ),
              ),
            ));
  }

  String taskNameValidator(String text) {
    if (text == "" || text == null)
      return "Please type in a task";
    else
      task.name = text;
    return null;
  }

  String dateValidator(String text) {
    if (text.length == 0) return null;
    if (text.length < 8) return "Please enter a full date";
    try {
      var splitText = text.split(r"/");
      task.date = DateTime(
          2000 + int.parse(splitText[2]), int.parse(splitText[1]), int.parse(splitText[0]));
      return null;
    } catch (e) {
      return "Invalid Date";
    }
  }

  String categoryValidator(String text) {
    if (text != "")
      task.category = text.toLowerCase();
    else
      task.category = "others";
    return null;
  }

  ///Adds the Task associated with this page to the data-provider
  void addTask() {
    bool _valid = _formKey.currentState.validate();
    if (_valid) {
      Provider.of<DataProvider>(_formKey.currentState.context, listen: false).addTask(task);
      Scaffold.of(_formKey.currentContext).showSnackBar(const SnackBar(
        content: Text("Task Added"),
      ));
      resetScreen();
    }
  }

  void resetScreen() {
    task = Task();
    FocusScope.of(_formKey.currentState.context).unfocus();
    _formKey.currentState.reset();
  }
}

class CustomTextFormField extends StatelessWidget {
  @required
  final Function validator;
  @required
  final String labelText;
  @required
  final String hintText;
  final List<TextInputFormatter> inputFormatter;
  final TextInputType keyBoardType;
  final bool isFinalInputField;
  final Function addTask;
  final TextEditingController controller;
  final bool isCategory;
  final bool suggestCategory;

  CustomTextFormField(
      {this.validator,
      this.labelText,
      this.hintText,
      this.inputFormatter = const [],
      this.keyBoardType = TextInputType.text,
      this.isFinalInputField = false,
      this.addTask,
      this.controller,
      this.isCategory = false,
      this.suggestCategory = false});

  @override
  Widget build(BuildContext context) {
    return Selector<DataProvider, ColorConstants>(
        selector: (_, provider) => provider.colorConstants,
        builder: (_, colorConstants, __) => TypeAheadFormField(
            hideOnLoading: true,
            //Stops a split second white-box loading up when clicking on the field
            noItemsFoundBuilder: (_) => null,
            itemBuilder: (_, suggestion) {
              if (isCategory) {
                return Container(
                  color: colorConstants.secondaryBackgroundColor,
                  child: ListTile(
                    title: Text(
                      suggestion,
                      style: Theme.of(context)
                          .textTheme
                          .headline5
                          .copyWith(color: colorConstants.fontColor.withAlpha(130)),
                    ),
                  ),
                );
              } else
                return null;
            },
            onSuggestionSelected: (String suggestion) {
              if (isCategory) {
                controller.text = suggestion;
                FocusScope.of(context).unfocus();
              }
            },
            suggestionsCallback: (pattern) {
              //Include more ifs here to create suggestions for fields
              if (isCategory && controller.text != "" && suggestCategory) {
                return Provider.of<DataProvider>(context, listen: false)
                    .categoryStream
                    .categoryNames
                    .where((name) => name.contains(pattern.toLowerCase()))
                    .toList();
              } else
                return null;
            },
            validator: (text) => validator(text),
            textFieldConfiguration: TextFieldConfiguration(
              maxLines: 1,
              controller: controller,
              onSubmitted: isFinalInputField
                  ? (string) => addTask()
                  : (string) {
                      if (isCategory)
                        FocusScope.of(context).unfocus();
                      else
                        FocusScope.of(context).nextFocus();
                    },
              textInputAction: TextInputAction.next,
              cursorColor: ColorConstants.orange,
              style:
                  Theme.of(context).textTheme.headline5.copyWith(color: colorConstants.fontColor),
              inputFormatters: inputFormatter,
              keyboardType: keyBoardType,
              decoration: InputDecoration(
                errorStyle:
                    Theme.of(context).textTheme.headline6.copyWith(color: ColorConstants.pink),
                errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: ColorConstants.pink), gapPadding: 0.0),
                labelText: labelText,
                labelStyle: Theme.of(context)
                    .textTheme
                    .headline4
                    .copyWith(color: colorConstants.fontColor.withAlpha(200)),
                hintText: hintText,
                hintStyle: Theme.of(context)
                    .textTheme
                    .headline5
                    .copyWith(color: colorConstants.fontColor.withAlpha(100)),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colorConstants.widgetBackground)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colorConstants.secondaryWidgetBackground)),
                focusedErrorBorder:
                    OutlineInputBorder(borderSide: BorderSide(color: ColorConstants.seaweed)),
                focusColor: ColorConstants.orange,
              ),
            )));
  }
}
