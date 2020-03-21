import 'package:flutter/material.dart';
import 'package:smarthome/Models/objectsModel.dart';
import 'package:smarthome/Services/httpService.dart';
import 'package:smarthome/Services/saveService.dart';

HttpService httpService = new HttpService();

class SingleAdapterPage extends StatefulWidget {
  final String name;
  final String title;
  final String adapterId;
  SingleAdapterPage({this.name, this.title, this.adapterId});

  @override
  _SingleAdapterPageState createState() => _SingleAdapterPageState();
}

class _SingleAdapterPageState extends State<SingleAdapterPage> {
  TextEditingController _searchQueryController = TextEditingController();
  bool _isSearching = false;
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching ? _buildSearchField() : Text(widget.title),
      ),
      body: Center(
        child: FutureBuilder(
          future: httpService.getAdapterObjects(widget.name),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return new CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return new CircularProgressIndicator();
            } else {
              List<ObjectsModel> objects = snapshot.data ?? [];

              if (_isSearching && this.searchQuery.length > 1) {
                objects = queryObjects(objects);
              }
              return ListView.builder(
                itemCount: objects.length,
                itemBuilder: (context, index) {
                  return ObjectListTile(object: objects[index]);
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _startSearch();
        },
        child: Icon(Icons.search),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchQueryController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: widget.title + ' durchsuchen',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white30),
      ),
      onChanged: (query) {
        setState(() {
          this.searchQuery = query;
        });
      },
    );
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  List<ObjectsModel> queryObjects(List<ObjectsModel> queryObjects) {
    List<ObjectsModel> returnList = new List();
    for (var object in queryObjects) {
      if (object.desc.contains(this.searchQuery) ||
          object.id.contains(this.searchQuery) ||
          object.name.contains(this.searchQuery)) {
        returnList.add(object);
      }
    }
    return returnList;
  }
}

class ObjectListTile extends StatefulWidget {
  final ObjectsModel object;

  ObjectListTile({this.object});

  @override
  _ObjectListTileState createState() => _ObjectListTileState();
}

class _ObjectListTileState extends State<ObjectListTile> {
  bool _isFavorite = false;
  SaveService saveService = new SaveService();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.object.name),
      subtitle: Text(widget.object.id),
      onTap: () {
        return showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(widget.object.name),
              actions: <Widget>[
                FlatButton(
                  child: Text('Ok'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
      trailing: IconButton(
        color: _isFavorite ? Theme.of(context).accentColor : null,
        icon: Icon(
          _isFavorite ? Icons.star : Icons.star_border,
        ),
        onPressed: () {
          setState(() {
            saveService.addObjectToFavorite(widget.object);
            _isFavorite = !_isFavorite;
          });
        },
      ),
    );
  }
}
