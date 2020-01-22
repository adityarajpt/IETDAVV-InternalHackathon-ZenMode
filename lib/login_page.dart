import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import './providers/domain.dart';
import './providers/token.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  var _formData = Map<String, String>();
  var _passwordFocusNode = FocusNode();
  var _disableButton = false;

  @override
  void dispose() {
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _login(BuildContext context) async {
    if (!_formKey.currentState.validate()) {
      print("Invalid form");
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _disableButton = true;
    });
    var domain = Provider.of<Domain>(context, listen: false).domain;
    var phoneNumber = _formData['phone_no'].trim();
    var password = _formData['password'];
    print(phoneNumber);
    print(password);
    var url = '$domain/login?phone_no=$phoneNumber&password=$password';
    print(url);
    try {
      var response = await http.get(url);
      if (response.statusCode != 200) {
        throw ArgumentError(
            "Request returned with status code ${response.statusCode}");
      }

      var data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data.containsKey('error')) {
        var errMsg =
            data.containsKey('message') ? data['message'] : "An error occured";
        throw ArgumentError(errMsg);
      }
      if (!data.containsKey('id')) {
        throw ArgumentError("Missing id from response body");
      }
      var userid = data['id'];
      Provider.of<Token>(context, listen: false).setToken(userid);
      Navigator.of(context).pushReplacementNamed('/map');
    } catch (e) {
      print(e);
      _showAlert(e, context);
    } finally {
      setState(() {
        _disableButton = false;
      });
    }
  }

  void _showAlert(e, BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Error'),
        content: Text(e.toString()),
        actions: [
          FlatButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("InstaCop"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Phone No.',
                ),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_passwordFocusNode),
                onSaved: (value) {
                  _formData['phone_no'] = value;
                },
                validator: (value) {
                  value = value.trim();
                  var matchGroup = RegExp(r'\d{10}').allMatches(value).toList();
                  if (matchGroup.length > 0) {
                    print(matchGroup[0].group(0));
                    if (matchGroup[0].group(0) != value)
                      return "Invalid phone number";
                    return null;
                  }
                  return "Invalid phone number";
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'password',
                ),
                focusNode: _passwordFocusNode,
                obscureText: true,
                onFieldSubmitted: (_) => _login(context),
                validator: (value) {
                  if (value.length < 6) return "Password too short";
                  return null;
                },
                onSaved: (value) {
                  _formData['password'] = value;
                },
              ),
              RaisedButton(
                child: Text('Login'),
                onPressed: _disableButton ? null : () => _login(context),
                color: Theme.of(context).primaryColor,
                textColor: Theme.of(context).textTheme.button.color,
              ),
              FlatButton(
                child: Text('Signup Instead'),
                onPressed: () =>
                    Navigator.of(context).pushReplacementNamed('/signup'),
                textColor: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
