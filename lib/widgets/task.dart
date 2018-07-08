import 'package:flutter/material.dart';

class TaskCard extends StatelessWidget {
  final String _taskName;
  final String _whenToRepeat;
  final Color _color;
  final Color _accentColor;

  const TaskCard(
      this._taskName, this._whenToRepeat, this._color, this._accentColor);
  @override
  Widget build(BuildContext context) {
    Color _textColor;
    Color _textAccentColor;
    if (this._color == Colors.white) {
      _textColor = Colors.black87;
      _textAccentColor = Colors.black45;
    } else {
      _textColor = Colors.white;
      _textAccentColor = Colors.white70;
    }
    return Material(
      elevation: 10.0,
      borderRadius: BorderRadius.circular(6.0),
      color: _color,
      child: Container(
        constraints: BoxConstraints(
            minWidth: double.infinity), //TODO: FIND A BETTER WAY TO FILL WIDTH
        height: 75.0,
        child: InkWell(
          highlightColor: _accentColor,
          splashColor: _accentColor,
          onTap: () => print('yo wassup'),
          child: Container(
            color: Colors.transparent,
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              //mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    '$_taskName',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: _textColor, fontSize: 28.0),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.0),
                  child: Text(
                    '$_whenToRepeat',
                    style: TextStyle(color: _textAccentColor, fontSize: 12.0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
