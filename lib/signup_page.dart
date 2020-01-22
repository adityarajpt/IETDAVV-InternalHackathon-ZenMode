import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import './providers/domain.dart';

class SignupPage extends StatefulWidget {
  SignupPage();

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  var _formData = Map<String, String>();
  var _passwordFocusNode = FocusNode();
  var _phoneNumberFocusNode = FocusNode();
  var _ageFocusNode = FocusNode();
  var _sexFocusNode = FocusNode();
  var _addressFocusNode = FocusNode();
  var _havingDisabilityFocusNode = FocusNode();
  var _disableButton = false;

  @override
  void dispose() {
    _passwordFocusNode.dispose();
    _phoneNumberFocusNode.dispose();
    _ageFocusNode.dispose();
    _sexFocusNode.dispose();
    _addressFocusNode.dispose();
    _havingDisabilityFocusNode.dispose();
    super.dispose();
  }

  void _signup(BuildContext context) async {
    if (!_formKey.currentState.validate()) {
      print("Invalid form");
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _disableButton = true;
    });

    var domain = Provider.of<Domain>(context, listen: false).domain;
    var name = _formData['name'].trim();
    var password = _formData['password'];
    var phoneNumber = _formData['phone_no'].trim();
    var age = _formData['age'].trim();
    var sex = _formData['sex'];
    var address = _formData['address'].trim();
    var havingDisability = _formData['having_disability'];

    try {
      var response =
          await http.get('$domain/signup?name=$name&password=$password');
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
      if (!data.containsKey('success')) {
        throw ArgumentError("Missing success from response body");
      }
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Success'),
          content: Text("Your Account has been successfully created."),
          actions: [
            FlatButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
      Navigator.of(context).pushReplacementNamed('/login');
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
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Name',
                  ),
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_passwordFocusNode),
                  onSaved: (value) {
                    _formData['name'] = value;
                  },
                  validator: (value) {
                    if (value.trim().length == 0)
                      return "Field must not be empty";
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                  ),
                  focusNode: _passwordFocusNode,
                  obscureText: true,
                  onFieldSubmitted: (_) => FocusScope.of(context)
                      .requestFocus(_phoneNumberFocusNode),
                  validator: (value) {
                    if (value.length < 8) return "Password too short";
                    return null;
                  },
                  onSaved: (value) {
                    _formData['password'] = value;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                  ),
                  focusNode: _phoneNumberFocusNode,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_ageFocusNode),
                  onSaved: (value) {
                    _formData['phone_no'] = value;
                  },
                  validator: (value) {
                    value = value.trim();
                    var matchGroup =
                        RegExp(r'\d{10}').allMatches(value).toList();
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
                    labelText: 'Age',
                  ),
                  focusNode: _ageFocusNode,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_sexFocusNode),
                  onSaved: (value) {
                    _formData['age'] = value;
                  },
                  validator: (value) {
                    value = value.trim();
                    var age = int.tryParse(value);
                    if (age != null) {
                      if (age > 0 && age < 100) return null;
                    }
                    return "Invalid age";
                  },
                ),
                DropdownButtonFormField(
                  hint: Text(_formData.containsKey('sex')
                      ? _formData['sex'] == 'M' ? 'Male' : 'Female'
                      : 'Sex:'),
                  items: [
                    DropdownMenuItem(
                      child: Text('Male'),
                      value: 'M',
                    ),
                    DropdownMenuItem(
                      child: Text('Female'),
                      value: 'F',
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _formData['sex'] = value;
                    });
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Address',
                  ),
                  focusNode: _addressFocusNode,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => FocusScope.of(context)
                      .requestFocus(_havingDisabilityFocusNode),
                  onSaved: (value) {
                    _formData['address'] = value;
                  },
                  validator: (value) {
                    value = value.trim();
                    if (value.length == 0) return "Address must not be empty";
                    return null;
                  },
                ),
                DropdownButtonFormField(
                  hint: Text(
                    _formData.containsKey('having_disability')
                        ? _formData['having_disability'] == 'true'
                            ? 'Yes'
                            : 'No'
                        : 'Having Disability:',
                  ),
                  items: [
                    DropdownMenuItem(
                      child: Text('Yes'),
                      value: 'true',
                    ),
                    DropdownMenuItem(
                      child: Text('No'),
                      value: 'false',
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _formData['having_disability'] = value;
                    });
                  },
                ),
                RaisedButton(
                  child: Text('Create Account'),
                  onPressed: _disableButton ? null : () => _signup(context),
                  color: Theme.of(context).primaryColor,
                  textColor: Theme.of(context).textTheme.button.color,
                ),
                FlatButton(
                  child: Text('Login Instead'),
                  onPressed: () =>
                      Navigator.of(context).pushReplacementNamed('/login'),
                  textColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
