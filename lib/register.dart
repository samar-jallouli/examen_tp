import 'dart:convert';
import 'package:auth/user.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String url = "http://10.0.2.2:8081/register";

  Future<User> register(String email, String password) async {
    final res = await http.post(Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}));
    print(res.body);
    if (res.statusCode == 200) {
      return User.fromMap(
        jsonDecode(res.body),
      );
    } else {
      throw Exception('Failed to register');
    }
  }

  handleRegister() async {
    if (_formKey.currentState == null) return;
    if (_formKey.currentState!.validate()) {
      try {
        User u =
        await register(_emailController.text, _passwordController.text);
        print(u);
        if (!mounted) return;
        return Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not register with these credentials!',
              style: TextStyle(fontSize: 16.0),
            ),
            duration: Duration(seconds: 5),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _label(String text) => Align(
    alignment: Alignment.topLeft,
    child: Text(text,
        style: GoogleFonts.roboto(fontSize: 30, color: Colors.purple)),
  );

  Widget _field(TextEditingController c, String emptyMsg,
      {bool obscure = false}) =>
      TextFormField(
        controller: c,
        obscureText: obscure,
        validator: (String? value) {
          if (value == null || value.isEmpty) return emptyMsg;
          return null;
        },
        style: TextStyle(fontSize: 30, color: Colors.blueGrey.shade700),
        decoration: const InputDecoration(
            errorStyle: TextStyle(fontSize: 20, color: Colors.black),
            border: OutlineInputBorder()),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Container(
                  height: 520.0,
                  width: 340.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFBEE6C6),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black54,
                          blurRadius: 6,
                          offset: Offset(0, 4))
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        Text("Register",
                            style: GoogleFonts.pacifico(
                                fontSize: 40, color: Colors.white)),
                        _label("Email"),
                        _field(_emailController, "Email is Empty"),
                        Container(
                          height: 4,
                          color: const Color.fromRGBO(255, 255, 255, 0.4),
                        ),
                        const SizedBox(height: 30),
                        _label("Password"),
                        _field(_passwordController, "Password is Empty",
                            obscure: true),
                        Container(
                          height: 4,
                          color: const Color.fromRGBO(255, 255, 255, 0.4),
                        ),
                        const SizedBox(height: 30),
                        Center(
                          child: InkWell(
                            onTap: () => Navigator.pop(context),
                            child: Text(
                              "Already have Account ?",
                              style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  height: 90,
                  width: 90,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                    ),
                    onPressed: () {
                      handleRegister();
                    },
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 30,
                    ),
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