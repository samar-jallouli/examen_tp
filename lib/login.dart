import 'dart:convert';
import 'package:auth/user.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dashboard.dart';
import 'register.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  // 10.0.2.2 = PC vu depuis l'émulateur. Téléphone réel : IP du PC (ipconfig)
  String url = "http://10.0.2.2:8081/login";

  Future<User> save(String email, String password) async {
    var res = await http.post(Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}));
    print(res.body);
    if (res.statusCode == 200 && res.body.isNotEmpty) {
      return User.fromMap(
        jsonDecode(res.body),
      );
    } else {
      throw Exception('Failed to login.');
    }
  }

  handleSignIn() async {
    if (_formKey.currentState == null) return;
    if (_formKey.currentState!.validate()) {
      try {
        User u = await save(_emailController.text, _passwordController.text);
        print(u.email);
        if (!mounted) return;
        return Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Dashboard(),
            ));
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Clould not log in with these credentials!',
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
                        Text("Login",
                            style: GoogleFonts.oswald(
                              fontWeight: FontWeight.w700,
                              fontSize: 50,
                              color: Colors.black45,
                            )),
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
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Register()));
                            },
                            child: Text(
                              "Dont have Account ?",
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
                      textStyle: const TextStyle(fontSize: 20),
                      backgroundColor: const Color.fromRGBO(233, 65, 82, 1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                    ),
                    onPressed: () {
                      handleSignIn();
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