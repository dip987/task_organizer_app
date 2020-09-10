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
import 'package:flushbar/flushbar.dart';

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

  DateTime _selectedDate;

  String _stickyDefaultText = "Sticky";

  List<String> allCategoryNames;

  //The task to be added
  var task;

  @override
  void initState() {
    task = Task();
    _categoryFieldController = TextEditingController();

    //THis might cause issues with dates before 2000 :|
    _selectedDate = Provider.of<DataProvider>(context, listen: false).selectedDate;
    _defaultToSticky = Provider.of<DataProvider>(context, listen: false).defaultToSticky;
    _dateFieldController = TextEditingController(
        text: _defaultToSticky
            ? _stickyDefaultText
            : "${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${(_selectedDate.year - 2000).toString().padLeft(2, '0')}");

    _suggestCategory = Provider.of<DataProvider>(context, listen: false).suggestCategory;

    allCategoryNames =
        Provider.of<DataProvider>(context, listen: false).categoryStream.categoryNames;

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
                                height: 32.0,
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
                                  allCategoryNames: allCategoryNames,
                                  suggestCategory: _suggestCategory,
                                  inputFormatter: [LengthLimitingTextInputFormatter(28)],
                                  validator: categoryValidator,
                                  labelText: "Category",
                                  hintText: " Travel"),
                              SizedBox(
                                height: 32.0,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomTextFormField(
                                      controller: _dateFieldController,
                                      validator: dateValidator,
                                      labelText: "Date",
                                      hintText: " DD/MM/YY",
                                      inputFormatter: [dateInputFormatter],
                                      keyBoardType: TextInputType.number,
                                      isFinalInputField: true,
                                      addTask: addTask,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.calendar_today,
                                      color: colorConstants.widgetBackground,
                                    ),
                                    onPressed: () => showCalendar(context, _dateFieldController,
                                        colorConstants.background, colorConstants.widgetBackground),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
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
    if (text == _stickyDefaultText) return null;
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
      task.category = text.toLowerCase().trim();
    else
      task.category = "others";
    return null;
  }

  ///Adds the Task associated with this page to the data-provider
  addTask() {
    bool _valid = _formKey.currentState.validate();
    if (_valid) {
      Provider.of<DataProvider>(_formKey.currentState.context, listen: false).addTask(task);
      Flushbar(
        messageText: Text(
          "Task Added",
          style:
              Theme.of(context).textTheme.headline6.copyWith(color: ColorConstants.whiteFontColor),
        ),
        padding: EdgeInsets.all(4.0),
        duration: Duration(seconds: 2),
        flushbarPosition: FlushbarPosition.TOP,
        backgroundColor: task.color,
      )..show(_formKey.currentState.context);
      if (!allCategoryNames.contains(task.category)) allCategoryNames.add(task.category);
      resetScreen();
    }
  }

  resetScreen() {
    task = Task();
    FocusScope.of(_formKey.currentState.context).unfocus();
    _formKey.currentState.reset();
  }

  showCalendar(BuildContext context, TextEditingController dateTextController, Color bgColor,
      Color fgColor) async {
    DateTime _datePicked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) => Theme(
        data: ThemeData(
            primarySwatch: MaterialColor(fgColor.value, {
          50: fgColor,
          100: fgColor,
          200: fgColor,
          300: fgColor,
          400: fgColor,
          500: fgColor,
          600: fgColor,
          700: fgColor,
          800: fgColor,
          900: fgColor
        })),
        child: child,
      ),
    );

    if (_datePicked != null)
      dateTextController.text =
          "${_datePicked.day.toString().padLeft(2, '0')}/${_datePicked.month.toString().padLeft(2, '0')}/${(_datePicked.year - 2000).toString().padLeft(2, '0')}";
  }
}

///Custom designed text input and for field with with suggestions options
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
  final List<String> allCategoryNames;

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
      this.suggestCategory = false,
      this.allCategoryNames = const []});

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
              if (isCategory && suggestCategory) {
                return allCategoryNames
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
