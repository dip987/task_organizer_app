import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sample_test_3/category.dart';
import 'package:flutter_sample_test_3/color_constants.dart';
import 'package:flutter_sample_test_3/data_provider.dart';
import 'package:flutter_sample_test_3/streams/task_stream.dart';
import 'package:flutter_sample_test_3/task.dart';
import 'package:flutter_sample_test_3/widgets/task_widgets.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  static double cardHeight = 160.0;
  static double cardWidth = 140.0;
  static double borderRadius = 28.0;
  static double verticalSpacing = 8.0;
  static double iconPadding = 8.0;
  static double horizontalMargin = 4.0;
  static double verticalMargin = 0.0;
  static double iconSize = (borderRadius - iconPadding - verticalSpacing) * 2;

  CategoryCard(this.category);

  @override
  Widget build(BuildContext context) {
    return Selector<DataProvider, ColorConstants>(
      selector: (_, provider) => provider.colorConstants,
      builder: (_, colorConstants, __) => Container(
        width: cardWidth,
        height: cardHeight,
        decoration: BoxDecoration(
          color: category.color,
          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        ),
        child: Align(
          alignment: Alignment(-0.2, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: verticalSpacing),
              Container(
                padding: EdgeInsets.all(iconPadding),
                decoration: BoxDecoration(
                  color: colorConstants.background.withAlpha(100),
                  borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
                ),
                child: Icon(
                  category.iconData,
                  size: iconSize,
                  color: ColorConstants.whiteFontColor,
                ),
              ),
              SizedBox(height: verticalSpacing * 3),
              Text(
                category.displayName,
                style: Theme.of(context).textTheme.headline6.copyWith(
                    color: ColorConstants.whiteFontColor.withAlpha(220)),
              ),
              SizedBox(height: verticalSpacing),
              ProgressBar(
                totalTaskNumber: category.totalTaskNumber,
                completedTaskNumber: category.completedTaskNumber,
              ),
              SizedBox(height: verticalSpacing),
              Text(
                "${category.totalTaskNumber - category.completedTaskNumber} Remaining",
                style: Theme.of(context).textTheme.bodyText2.copyWith(
                    color: ColorConstants.whiteFontColor.withAlpha(255)),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ProgressBar extends StatefulWidget {
  @required
  final int totalTaskNumber;
  @required
  final int completedTaskNumber;

  static double totalWidthFactor = 0.8;
  static double barHeight = 4.0;

  ProgressBar({this.totalTaskNumber, this.completedTaskNumber});

  @override
  _ProgressBarState createState() => _ProgressBarState();
}

class _ProgressBarState extends State<ProgressBar> {
  double completedWidthFactor;

  @override
  Widget build(BuildContext context) {
    completedWidthFactor = (widget.totalTaskNumber != 0)
        ? widget.completedTaskNumber /
            widget.totalTaskNumber *
            ProgressBar.totalWidthFactor
        : ProgressBar.totalWidthFactor;
    return Stack(
      children: [
        FractionallySizedBox(
          widthFactor: ProgressBar.totalWidthFactor,
          child: Container(
            height: ProgressBar.barHeight,
            decoration: BoxDecoration(
              color: ColorConstants.darkBackground,
              borderRadius:
                  BorderRadius.all(Radius.circular(ProgressBar.barHeight)),
            ),
          ),
        ),
        FractionallySizedBox(
          widthFactor: completedWidthFactor,
          child: AnimatedContainer(
            duration: Duration(seconds: 1),
            height: ProgressBar.barHeight,
            decoration: BoxDecoration(
              color: ColorConstants.lightBackground,
              borderRadius:
                  BorderRadius.all(Radius.circular(ProgressBar.barHeight)),
            ),
          ),
        ),
      ],
    );
  }
}

class CategoryCardList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: CategoryCard.cardHeight,
      child: StreamBuilder(
        stream: Provider.of<DataProvider>(context).categoryStream.stream,
        builder: (context, AsyncSnapshot<List<Category>>snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Container();
          else if (snapshot.connectionState == ConnectionState.active){
            return ListView(
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              children: snapshot.data.map((category) => Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: CategoryCard.horizontalMargin,
                    vertical: CategoryCard.verticalMargin),
                child: OpenContainerCategoryCard(category),
              )) .toList(),);}
            else return Container();
        },
      ));
  }
}

class OpenContainerCategoryCard extends StatelessWidget {
  final Category category;

  OpenContainerCategoryCard(this.category);

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (_, provider, __) => OpenContainer(
          closedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(CategoryCard.borderRadius))),
          closedColor: category.color,
          closedBuilder: (BuildContext context, _) =>
              CategoryCard(category),
          openBuilder: (context, __) {
            return ExpandedCategoryCard(category, provider.taskStream);
        }),
    );
  }
}

class ExpandedCategoryCard extends StatefulWidget {
  final Category category;
  final TaskStream taskStream;

  ExpandedCategoryCard(this.category, this.taskStream);

  @override
  _ExpandedCategoryCardState createState() => _ExpandedCategoryCardState();
}

class _ExpandedCategoryCardState extends State<ExpandedCategoryCard> {
  final double iconSize = CategoryCard.iconSize;
  final double borderRadius = CategoryCard.borderRadius;
  final double iconPadding = CategoryCard.iconPadding;

  @override
  void initState() {
    widget.taskStream.openCard(widget.category);
    super.initState();
  }

  @override
  void dispose() {
    widget.taskStream.closeCard();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<DataProvider, Tuple2<ColorConstants, TaskStream>>(
      selector: (_, provider) => Tuple2(provider.colorConstants, provider.taskStream),
      builder: (_, data, __)=> Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: true,
            title: Row(children: [
              Container(
                padding: EdgeInsets.all(iconPadding),
                decoration: BoxDecoration(
                  color: data.item1.background.withAlpha(100),
                  borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
                ),
                child: Icon(
                  widget.category.iconData,
                  size: iconSize,
                  color: ColorConstants.whiteFontColor,
                ),
              ),
              SizedBox(width: 8.0,),
              Expanded(child: Text(widget.category.displayName))
            ]),
            backgroundColor: data.item1.widgetBackground,
          ),
          backgroundColor: widget.category.color,
          body: StreamBuilder(
            stream: data.item2.categoryPageStream,
            builder: (_, AsyncSnapshot<List<Task>> snapshot) {
              if (snapshot.connectionState == ConnectionState.active) return ListView(
              children: snapshot.data.map((task) => TaskStrip(task, true)).toList(),);
              else return Container();
            },
          )
          ),
        );
  }
}
