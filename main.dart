import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _secureStorage = FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final email = _emailController.text.trim();
                  final password = _passwordController.text.trim();
                  if (email == 'test@gmail.com' && password == 'test') {
                    await _secureStorage.write(key: 'isLoggedIn', value: 'true');
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen()));
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Login Failed'),
                        content: Text('Invalid email or password.'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                child: Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ImagePicker _imagePicker;
  List<File> _imageFiles = [];

  @override
  void initState() {
    super.initState();
    _imagePicker = ImagePicker();
    _loadSavedImages();
  }

  Future<void> _loadSavedImages() async {
    final prefs = await SharedPreferences.getInstance();
    final savedImagePaths = prefs.getStringList('image_paths') ?? [];

    for (final path in savedImagePaths) {
      _imageFiles.add(File(path));
    }

    setState(() {});
  }

  Future<void> _saveImageLocally(File imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    await imageFile.copy(imagePath);

    final prefs = await SharedPreferences.getInstance();
    final savedImagePaths = prefs.getStringList('image_paths') ?? [];
    savedImagePaths.add(imagePath);
    await prefs.setStringList('image_paths', savedImagePaths);
  }

  Future<void> _pickImageFromCamera() async {
    final pickedFile = await _imagePicker.getImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      _saveImageLocally(imageFile);
      setState(() {
        _imageFiles.add(imageFile);
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _imagePicker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      _saveImageLocally(imageFile);
      setState(() {
        _imageFiles.add(imageFile);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text('Image Upload App'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _imageFiles.length,
              itemBuilder: (context, index) {
                return Image.file(
                  _imageFiles[index],
                  width: 200,
                  height: 200,
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _pickImageFromCamera,
            style: ElevatedButton.styleFrom(
              primary: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0.0),
              ),
            ),
            child: Text('Take a Photo'),
          ),
          ElevatedButton(
            onPressed: _pickImageFromGallery,
            style: ElevatedButton.styleFrom(
              primary: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0.0),
              ),
            ),
            child: Text('Pick an Image from Gallery'),
          ),
        ],
      ),
    );
  }
}
