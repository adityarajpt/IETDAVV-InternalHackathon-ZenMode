import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:police_emerg/providers/domain.dart';
import 'package:provider/provider.dart';

class SosBottomSheet extends StatefulWidget {
  @override
  _SosBottomSheetState createState() => _SosBottomSheetState();
}

class _SosBottomSheetState extends State<SosBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  var _formData = Map<String, String>();

  void _sosRequest(context) async {
    print('test');
    var type = _formData.containsKey('type') ? _formData['type'] : 'Crime Type';
    var description = _formData.containsKey('description')
        ? _formData['description']
        : 'Crime Description';

    var domain = Provider.of<Domain>(context, listen: false).domain;
    await http.get(
        '$domain/report?token=testing&type=$type&description=$description&latitude=23.8941&longitude=74.5772');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      child: Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Type (optional)',
              ),
              textInputAction: TextInputAction.done,
              onSaved: (value) {
                _formData['type'] = value;
              },
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Description (optional)',
              ),
              maxLines: 4,
              textInputAction: TextInputAction.done,
              onSaved: (value) {
                _formData['description'] = value;
              },
            ),
            RaisedButton(
              child: Text("Send"),
              onPressed: () => _sosRequest(context),
            )
          ],
        ),
      ),
      padding: const EdgeInsets.all(20),
    );
  }
}
