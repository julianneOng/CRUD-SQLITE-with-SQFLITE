// ignore_for_file: unused_import, unused_field

import 'package:crud_sqflite_app/database/database.dart';
import 'package:crud_sqflite_app/models/note_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import 'add_note_screen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});


  @override
  _HomeScreenState createState() =>  _HomeScreenState();
}
class  _HomeScreenState extends State<HomeScreen>{
  List todos = <dynamic>[];
  late Future<List<Note>> _noteList;
  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  get convert => null;


  @override
  void initState() {
    super.initState();
    getTodo();
    _updateNoteList();
  }

  getTodo() async {
    var url = 'https://jsonplaceholder.typicode.com/todos';
    var response = await http.get(Uri.parse(url));

    setState(() {
      todos = convert.jsonDecode(response.body) as List<dynamic>;
    });
  }
  _updateNoteList(){
    _noteList = DatabaseHelper.instance.getNoteList();
  }
  Widget _buildNote(Note note){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
    child: Column(
     children: [
       ListTile(
        title: Text(note.title!,style:TextStyle(
          fontSize: 18.0,
          color: Colors.white,
          decoration: note.status == 0
            ? TextDecoration.none
              : TextDecoration.lineThrough
        ),
        ),
        subtitle: Text('${_dateFormatter.format(note.date!)} -${note.priority}',style: TextStyle(
        fontSize: 15.0,
        color: Colors.white,
            decoration: note.status == 0
                ? TextDecoration.none
                : TextDecoration.lineThrough
        ),),
        trailing: Checkbox(
          onChanged: (value){
            note.status = value! ? 1 : 0;
            DatabaseHelper.instance.updateNote(note);
            _updateNoteList();
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
       },
       activeColor: Theme.of(context).primaryColor,
       value: note.status == 1 ? true : false,
      ),
      onTap: ()=> Navigator.push(context,CupertinoPageRoute(builder: (_) => AddNoteScreen(
        updateNoteList: _updateNoteList(),
        note: note,
      ),
      ),
      ),
     ),
     const Divider(height: 5.0,color: Colors.deepPurple,thickness: 2.0,),
     ],
    ),
    );
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: (){
          Navigator.push(context,CupertinoPageRoute(builder: (_) => AddNoteScreen(
            updateNoteList: _updateNoteList,
          ),));
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder(
        future: _noteList,
      builder: (context,AsyncSnapshot snapshot) {
          if(!snapshot.hasData){
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final int completedNoteCount = snapshot.data!.where((Note note) => note.status ==1).toList().length;

        return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 80.0),
            itemCount: int.parse(snapshot.data!.length.toString()) + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'My Notes',
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 40.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10.0,),
                      Text(
                        '$completedNoteCount of ${snapshot.data.length}',
                        style: const TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return _buildNote(snapshot.data![index - 1]);
            }
        );
      }
    ),
    );
  }
}