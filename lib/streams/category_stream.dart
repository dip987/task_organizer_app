import 'package:flutter_sample_test_3/category.dart';
import 'package:flutter_sample_test_3/task.dart';
import 'package:rxdart/rxdart.dart';

class CategoryStream {
  BehaviorSubject<List<Category>> _subject;

  List<Category> _categoryList;
  CategoryColorGenerator _colorGen;

  CategoryStream() {
    _colorGen = CategoryColorGenerator();
    _categoryList = [Category(name: "all", completedTaskNumber: 0, totalTaskNumber: 0, color: _colorGen.getColor("all"))];

    _subject = BehaviorSubject<List<Category>>();
    _subject.add(_categoryList);

  }

  List<String> get categoryNames => _categoryList.map((category) => category.name).toList();

  ValueStream<List<Category>> get stream => _subject.stream;

  addTask(Task task) {
    //Add the task to all categories
    _categoryList[0].updateStatsWithTask(task: task, updateType: UpdateType.ADD, forceUpdate: true);

    //Add to the specific category
    _categoryList.firstWhere((category) => category.name == task.category, orElse: () {
          Category _category =
              Category(name: task.category, completedTaskNumber: 0, totalTaskNumber: 0, color: _colorGen.getColor(task.category));
          _categoryList.add(_category);
          return _category;
        }).updateStatsWithTask(task: task, updateType: UpdateType.ADD);

    //Update Color of the task based on category
    task.color = _colorGen.getColor(task.category);

    //Emit a new stream of categories
    _subject.add(_categoryList);
  }

  removeTask(Task task){
    //Remove the task from all the relevant categories
    _categoryList[0].updateStatsWithTask(task: task,  updateType: UpdateType.REMOVE, forceUpdate: true);
    _categoryList.firstWhere((cat) => cat.name == task.category).updateStatsWithTask(task: task, updateType: UpdateType.REMOVE);

    //If any category has no more tasks left, kick it from the category list
    _categoryList.removeWhere((cat) => cat.totalTaskNumber == 0);

    //Emit the updated category list after removal
    _subject.add(_categoryList);
  }

  toggleTask(Task task){
    //Toggle the task from all the relevant categories
    _categoryList[0].updateStatsWithTask(task: task,  updateType: UpdateType.TOGGLE, forceUpdate: true);
    _categoryList.firstWhere((cat) => cat.name == task.category).updateStatsWithTask(task: task, updateType: UpdateType.TOGGLE);

    //Emit the updated category list after removal
    _subject.add(_categoryList);
  }

  removeCategory(Category category){
    //Remove the category from list unless its "all"
    if (category.name != "all") {
      //Update the all tab with the completedTask and totalTask of the category being removed
      _categoryList[0].totalTaskNumber -= category.totalTaskNumber;
      _categoryList[0].completedTaskNumber -= category.completedTaskNumber;


      _categoryList.removeWhere((cat) => cat.name == category.name);

      //Emit the updated category list after removal
      _subject.add(_categoryList);
    }

  }

  dispose() {
    _subject.close();
  }
}
