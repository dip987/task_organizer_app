import 'package:flutter/material.dart';
import 'package:flutter_sample_test_3/color_constants.dart';
import 'package:flutter_sample_test_3/data_provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_sample_test_3/widgets/navigation_bar.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sample_test_3/task.dart';

class TaskStrip extends StatefulWidget {
  final Task task;
  final bool includeDate;

  TaskStrip(this.task, [this.includeDate = false]);

  @override
  _TaskStripState createState() => _TaskStripState();
}

class _TaskStripState extends State<TaskStrip> {
  static final height = 44.0;
  static final iconSize = 24.0;
  static final gap = 12.0;
  static final horizontalPadding = CustomBottomNavBar.borderRadius - 6.0;

  //This just works.. don't ask why
  static final verticalPadding = 8.0;

  bool isDone;
  String task;
  Color color;
  bool tapped = false;
  bool isActive = true;

  @override
  Widget build(BuildContext context) {
    isDone = widget.task.isDone;
    task = widget.task.name;
    color = widget.task.color;
    return Selector<DataProvider, ColorConstants>(
            selector: (_, provider) => provider.colorConstants,
            builder: (_, colorConstants, __) {
              return Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
                child: InkResponse(
                  borderRadius: BorderRadius.all(Radius.circular(height / 2)),
                  containedInkWell: true,
                  highlightShape: BoxShape.rectangle,
                  highlightColor: widget.task.color,
                  splashColor: widget.task.color,
                  onLongPress: () {
                    if (isDone) {
                      Provider.of<DataProvider>(context, listen: false).removeTask(widget.task);
                    }
                  },
                  onHighlightChanged: (highlighted) {
                    setState(() {
                      tapped = highlighted;
                    });
                  },
                  child: Container(
                    height: height,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: tapped ? Colors.transparent : colorConstants.secondaryBackgroundColor,
                      // boxShadow: [
                      //   BoxShadow(
                      //       blurRadius: 1.0,
                      //       color: ColorConstants.darkBackground.withAlpha(100))
                      // ],
                      borderRadius: BorderRadius.all(Radius.circular(height / 2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {setState(() {
                              widget.task.toggle();
                            });
                              Provider.of<DataProvider>(context, listen: false).updateTask(widget.task);
                            },
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(height / 2 - 4.0,
                                  (height - iconSize) / 2, gap, (height - iconSize) / 2),
                              child: isDone
                                  ? Icon(
                                      Icons.check_box,
                                      color: color,
                                      size: iconSize,
                                    )
                                  : Icon(Icons.check_box_outline_blank,
                                      color: color, size: iconSize),
                            )),
                        Expanded(
                          child: Text(
                            task,
                            style: Theme.of(context).textTheme.bodyText1.copyWith(
                                color: colorConstants.fontColor.withAlpha(200),
                                decoration:
                                    isDone ? TextDecoration.lineThrough : TextDecoration.none),
                          ),
                        ),
                        (widget.includeDate && widget.task.date != null)
                            ? Padding(
                                padding: EdgeInsets.only(right: height / 2, left: gap),
                                child: Text(
                                  "${DateFormat.MMMMd().format(widget.task.date)}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .copyWith(color: colorConstants.fontColor.withAlpha(200)),
                                  textAlign: TextAlign.end,
                                ),
                              )
                            : SizedBox(
                                width: height / 2 - 4.0,
                              ),
                      ],
                    ),
                  ),
                ),
              );
            });
  }
}

class TaskStripSliver extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
                  stream: Provider.of<DataProvider>(context).taskStream.homePageStream,
                  builder: (_, AsyncSnapshot<List<Task>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.active)
                      return SliverList(
                        delegate: SliverChildListDelegate.fixed(snapshot.data.map((e) => TaskStrip(e)).toList())
                      );
                    else
                      return SliverToBoxAdapter(
                        child: Container(),
                      );
                  },
                );
  }
}
