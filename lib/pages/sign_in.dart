import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:project_management/pocketbase_options.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}
class _SignInState extends State<SignIn> {

  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  IconData _iconVisibility = Icons.visibility_off_outlined;

  int _page = 0; //0 for sign in, 1 for sign up

  String _email="", _password="",_name="",_username="";
  
  Future<void> signIn() async {
    try {
      final pb = PocketbaseGetter.pb;
      if (_page == 0) {
        await pb.collection('users').authWithPassword(_email, _password);
      }
      else {
        final body = <String, dynamic>{
          "username": _username,
          "email": _email,
          "emailVisibility": false,
          "password": _password,
          "passwordConfirm": _password,
          "name": _name,
        };
        await pb.collection('users').create(body: body);
      }
      await _addToSecureStorage('email', _email);
      await _addToSecureStorage('password', _password);
      if (context.mounted) {
        Navigator.pushNamed(context, '/');
      }
    }
    catch(_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error signing in')),
      );
      }
    }
  }


  AndroidOptions _getAndroidOptions() => const AndroidOptions(
    encryptedSharedPreferences: true,
  );
  final _storage = const FlutterSecureStorage();
  Future<void> _addToSecureStorage(String key,String value) async {
    await _storage.write(
      key: key,
      value: value,
      aOptions: _getAndroidOptions(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in to Project Manager')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Sign in page',style:Theme.of(context).textTheme.displayMedium),
            Form(
              key: _formKey,
              //animated switcher for sign in and sign up
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: _page==0?buildSignIn(context):buildSignUp(context),
              ),
            ),
            SizedBox(
              width: 250,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Processing Data')),
                    );
                    signIn();
                  }
                },
                child: const Text('Submit'),
              ),
            ),
            //page text
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: TextButton(
                onPressed: () {
                  setState(() {
                    if (_page==0) {
                      _page=1;
                    } else {
                      _page=0;
                    }
                  });
                },
                child: Text(_page==0?'Don\'t have an account? Sign up'
                    :'Already a user? Sign in'),
              ),
            ),
          ],
        ),
      )
    );
  }

  Widget buildSignUp(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      width: 450,
      child: Column(
        children: [
          buildEmailCard(),
          buildPasswordCard(),
          //create a name card
          Card(
            //8 margin on bottom
            margin: const EdgeInsets.only(bottom: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                onChanged: (value) {
                  setState(() {
                    _name = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  hintText: 'Enter your name',
                  labelText: 'Name',
                  //add mail icon
                  prefixIcon: Icon(Icons.person_outline_rounded),
                  //remove border
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          //username card
          Card(
            //8 margin on bottom
            margin: const EdgeInsets.only(bottom: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                onChanged: (value) {
                  setState(() {
                    _username = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  hintText: 'Enter your username',
                  labelText: 'Username',
                  //add mail icon
                  prefixIcon: Icon(Icons.person_add),
                  //remove border
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget buildSignIn(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      width: 450,
      child: Column(
        children: [
          buildEmailCard(),
          buildPasswordCard(),
        ],
      ),
    );
  }

  Card buildEmailCard() {
    return Card(
          //8 margin on bottom
          margin: const EdgeInsets.only(bottom: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              onChanged: (value) {
                setState(() {
                  _email = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              decoration: const InputDecoration(
                hintText: 'Enter your email',
                labelText: 'Email',
                //add mail icon
                prefixIcon: Icon(Icons.mail_outline_rounded),
                //remove border
                border: InputBorder.none,
              ),
            ),
          ),
        );
  }

  Card buildPasswordCard() {
    return Card(
          //8 margin on bottom
          margin: const EdgeInsets.only(bottom: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              obscureText: _obscureText,
              onChanged: (value) {
                setState(() {
                  _password = value;
                });
              },
              validator: (value) {
                if (value == null || value.length<8) {
                  return 'Password must be 8 characters or more';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: 'Enter your password',
                labelText: 'Password',
                //remove border
                border: InputBorder.none,
                //add a icon
                suffixIcon: IconButton(onPressed:() {
                  setState(() {
                    _obscureText = !_obscureText;
                    if (_obscureText) {
                      _iconVisibility = Icons.visibility_off_outlined;
                    } else {
                      _iconVisibility = Icons.visibility_outlined;
                    }
                  });
                },
                    icon:Icon(_iconVisibility)),
                // add lock icon
                prefixIcon: const Icon(Icons.lock_outline_rounded),
              ),
            ),
          ),
        );
  }

}