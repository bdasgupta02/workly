import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workly/resuable_widgets/clipped_header_bg.dart';
import 'package:workly/screens/forget_password_page.dart';
import 'package:workly/services/auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class EmailLoginPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          ClippedHeader(),
          ListView(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(
                  top: 80,
                  bottom: 60,
                ),
                child: Text(
                  'Sign in with email',
                  style: TextStyle(
                      fontSize: 25,
                      color: Colors.white,
                      fontFamily: 'Khula',
                      fontWeight: FontWeight.w400,
                      height: 1.5),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                //[Note] Now it's at the center of the screen which automatically gets lifted by a keyboard
                alignment: Alignment.center,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Container(
                      child: EmailLoginForm(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: Color(0xFFE9E9E9), //[Action needed] Update colour
    );
  }
}

enum EmailLoginFormType {
  signIn,
  register,
}

class EmailLoginForm extends StatefulWidget with EmailAndPasswordValidators {

  @override
  _EmailLoginFormState createState() => _EmailLoginFormState();
}

class _EmailLoginFormState extends State<EmailLoginForm> {
  final TextEditingController _emailController =
      TextEditingController(); //To store the user input
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _submitted = false;
  bool _isLoading = false;
  bool _incorrectEmailFormat = false;
  bool _incorrectEmailOrPassword = false;
  bool _weakPassword = false;
  
  PickedFile _image;
  ImageProvider<dynamic> image;

  EmailLoginFormType _formType = EmailLoginFormType.signIn;

  void _toggleFormType() {
    //To toggle between different state, either sign in or register
    setState(() {
      _submitted = false;
      _incorrectEmailFormat = false;
      _incorrectEmailOrPassword = false;
      _weakPassword = false;
      _formType = _formType == EmailLoginFormType.signIn
          ? EmailLoginFormType.register
          : EmailLoginFormType.signIn;
    });
    _emailController
        .clear(); //Clear the user input when toggling between different state
    _passwordController.clear();
    _nameController.clear();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFFCFCFC),
          borderRadius: BorderRadius.all(Radius.circular(34)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 15,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.only(
            top: 25,
            left: 25,
            right: 25,
            bottom: 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _buildChildren(),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildChildren() {
    final String flatButtonText = _formType == EmailLoginFormType.signIn
        ? "Sign in"
        : "Create an account";
    final String outlineButtonText = _formType == EmailLoginFormType.signIn
        ? "New? Create a new account now!"
        : "Have an account? Sign in here";
    bool enableSignInButton = _formType == EmailLoginFormType.signIn
        ? widget.emailValidator.isValid(_email.trim()) &&
            widget.passwordValidator.isValid(_password) &&
            !_isLoading
        : widget.emailValidator.isValid(_email.trim()) &&
            widget.passwordValidator.isValid(_password) &&
            widget.nameValidator.isValid(_name) &&
            !_isLoading;

    return [
      Offstage(
        offstage: _formType == EmailLoginFormType.register ? false : true,
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: <Widget>[
            makeAvatar(),
            Positioned(
              bottom: 5,
              right: 50,
              child: _imagePickerButton(),
            ),
          ],
        ),
      ),
      Offstage(
        offstage: _formType == EmailLoginFormType.register ? false : true,
        child: _nameTextField(),
      ),
      _emailTextField(),
      SizedBox(height: 8.0),
      _passwordTextField(),
      SizedBox(height: 12.0),
      Offstage(
        offstage: !_incorrectEmailOrPassword,
        child: Column(
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              child: Text(
                "Email or password is incorrect",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14.0,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            FlatButton(
              child: Text(
                " I forgot my password ",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 18.0,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
              onPressed: () => _forgetMyPassword(context),
            ),
          ],
        ),
      ),
      Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color(0xFF33CFEE).withOpacity(0.25),
              spreadRadius: 2,
              blurRadius: 15,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: FlatButton(
          child: Text(
            flatButtonText,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w600,
            ),
          ),
          color: Color(0xFF04C9F1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(24.0),
            ),
          ),
          onPressed: () => enableSignInButton ? _submit() : null,
        ),
      ),
      SizedBox(height: 4.0),
      OutlineButton(
        borderSide: BorderSide(color: Color(0xFF31BCD8)),
        child: Text(
          outlineButtonText,
          style: TextStyle(
            color: Color(0xFF31BCD8),
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w600,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(24.0),
          ),
        ),
        onPressed: () => !_isLoading ? _toggleFormType() : null,
      ),
      SizedBox(height: 16.0),
      Offstage(
        offstage: !_isLoading,
        child: Center(child: CircularProgressIndicator(),),
      ),
    ];
  }

  Widget makeAvatar() {
    return Container(
      margin: EdgeInsets.only(
        bottom: 12,
        // top: 12,
        // right: 5,
      ),
      width: 126,
      height: 126,
      decoration: BoxDecoration(
        color: Color(0xFFE5E5E5),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black38.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: CircleAvatar(
        backgroundImage: image,
        backgroundColor: Color(0xFFFCFCFC),
        foregroundColor: Colors.black,
        radius: 56,
        child: image == null
            ? Text(
                _name.isNotEmpty ? _name[0].toUpperCase() : "",
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Roboto',
                  fontSize: 48,
                ),
              )
            : SizedBox(),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    PickedFile selectedImage = await ImagePicker().getImage(source: source, preferredCameraDevice: CameraDevice.front);
    // Image.file(File(selectedImage.path));
    if (selectedImage != null) {
      setState(() {
        _image = selectedImage;
        image = FileImage(File(_image.path));
      });
    }
  }

  Widget _imagePickerButton() {
    return MaterialButton(
      color: Colors.grey[200],
      child: Icon(
        Icons.add_a_photo,
        size: 20,
      ),
      padding: EdgeInsets.all(10),
      shape: CircleBorder(),
      onPressed: () => {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return _showImageSource();
          },
          barrierDismissible: true,
        ),
      },
    );
  }

  Widget _showImageSource() {
    return AlertDialog(
      title: Text("Pick image from", style: TextStyle(fontSize: 18,),),
      titlePadding: EdgeInsets.only(left: 20, top: 5),
      backgroundColor: Color(0xFFE9E9E9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      contentPadding: EdgeInsets.only(top: 10, bottom: 15,),
      content: Container(
        height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(
              width: 80,
              child: FlatButton(
                color: Color(0xFF04C9F1),
                padding: EdgeInsets.all(5.0),
                child: Column( 
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Icon(
                      Icons.photo_camera,
                      size: 40,
                      color: Colors.white,
                    ),
                    Text("Camera",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                onPressed: () => {
                  _pickImage(ImageSource.camera),
                  Navigator.of(context).pop(),
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
            Container(
              width: 80,
              child: FlatButton(
                color: Color(0xFF04C9F1),
                padding: EdgeInsets.all(5.0),
                child: Column( 
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Icon(
                      Icons.photo_library,
                      size: 40,
                      color: Colors.white,
                    ),
                    Text("Gallery",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                onPressed: () => {
                  _pickImage(ImageSource.gallery),
                  Navigator.of(context).pop(),
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextField _nameTextField() {
    bool showErrorText =
        _submitted && !widget.nameValidator.isValid(_name.trim());
    return TextField(
      decoration: InputDecoration(
        labelText: "Name",
        hintText: "Your name",
        errorText: showErrorText ? widget.invalidNameErrorText : null,
        enabled: !_isLoading,
      ),
      controller: _nameController,
      textInputAction: TextInputAction.next,
      focusNode: _nameFocusNode,
      onChanged: (name) => _updateState(),
      onEditingComplete: () => _nameEditingComplete(),
    );
  }

  TextField _emailTextField() {
    bool showErrorText = _submitted &&
        (!widget.emailValidator.isValid(_email.trim()) ||
            _incorrectEmailFormat ||
            _incorrectEmailOrPassword);
    return TextField(
      decoration: InputDecoration(
        labelText: "Email",
        hintText: "user@example.com",
        errorText: showErrorText ? widget.invalidEmailErrorText : null,
        enabled: !_isLoading,
      ),
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      focusNode: _emailFocusNode,
      onChanged: (email) => _updateState(),
      onEditingComplete: () => _emailEditingComplete(),
    );
  }

  TextField _passwordTextField() {
    bool showErrorText = _submitted &&
        (!widget.passwordValidator.isValid(_password) ||
            _incorrectEmailOrPassword);
    return TextField(
      decoration: InputDecoration(
        labelText: "Password",
        errorText: _weakPassword ? widget.weakPasswordText : (showErrorText ? widget.invalidPasswordErrorText : null),
        enabled: !_isLoading,
      ),
      controller: _passwordController,
      textInputAction: TextInputAction.done,
      focusNode: _passwordFocusNode,
      onChanged: (password) => _updateState(),
      onEditingComplete: () => _submit(),
      obscureText: true,
    );
  }

  void _nameEditingComplete() {
    final newFocus = widget.nameValidator.isValid(_name.trim())
        ? _emailFocusNode
        : _nameFocusNode;
    FocusScope.of(context).requestFocus(newFocus);
  }

  void _emailEditingComplete() {
    final newFocus = widget.emailValidator.isValid(_email.trim())
        ? _passwordFocusNode
        : _emailFocusNode;
    FocusScope.of(context).requestFocus(newFocus);
  }

  void _updateState() {
    setState(() {});
  }

  String get _email => _emailController.text;

  String get _password => _passwordController.text;

  String get _name => _nameController.text;

  void _submit() async {
    setState(() {
      _submitted = true;
      _isLoading = true;
      _incorrectEmailOrPassword = false;
      _incorrectEmailFormat = false;
      _weakPassword = false;
    });
    try {
      final auth = Provider.of<AuthBase>(context, listen: false);
      if (_formType == EmailLoginFormType.signIn) {
        await auth.signInWithEmailAndPassword(_email.trim(), _password);
      } else {
        await auth
            .createUserWithEmailAndPassword(_email.trim(), _password);
        _createFireBaseUser();
      }
      Navigator.of(context).pop();
    } catch (e) {
      switch (e.code) {
        case "ERROR_INVALID_EMAIL":
          {
            setState(() {
              _incorrectEmailFormat = true;
            });
            widget.invalidEmailFormatText();
          }
          break;
        case "ERROR_WEAK_PASSWORD":
          {
            setState(() {
              _weakPassword = true;
            });
          }
          break;
        default:
          {
            print(e.toString());
            setState(() {
              _incorrectEmailOrPassword = true;
            });
            widget.invalidEmailOrPasswordText();
          }
          break;
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _createFireBaseUser() async {
    final auth = Provider.of<AuthBase>(context, listen: false);
    User user = await auth.currentUser();
    String _url; //If have error, then set this to null
    if (_image != null) {
      _url = await _uploadProfileImage(user.uid);
    }
    Firestore.instance.collection('users').document(user.uid).setData({
      'name': _name.trim(),
      'email': _email.trim(),
      'created': FieldValue.serverTimestamp(),
      'uid': user.uid,
      'imageUrl': _url,
    });
  }

  Future<String> _uploadProfileImage(String uid) async {
    final FirebaseStorage _storage = FirebaseStorage(storageBucket: 'gs://workly-7af57.appspot.com');
    StorageUploadTask _upload = _storage.ref().child('profile/$uid.png').putFile(File(_image.path));
    StorageTaskSnapshot _snapshot = await _upload.onComplete;
    if (_snapshot.error == null) {
      String _url = await _snapshot.ref.getDownloadURL();
      print("URL");
      print(_url);
      return _url;
    } else {
      print(_snapshot.error.toString());
      return null;
    }
  }

  void _forgetMyPassword(BuildContext context) {
    setState(() {
      _submitted = false;
      _isLoading = false;
      _incorrectEmailFormat = false;
      _incorrectEmailOrPassword = false;
      _weakPassword = false;
      _emailController.clear();
      _passwordController.clear();
      _nameController.clear();
    });
    Navigator.of(context).push(MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (context) => ForgetPasswordPage(),
    ));
  }
}

abstract class StringValidator {
  bool isValid(String value);
}

class NonEmptyStringValidator implements StringValidator {
  @override
  bool isValid(String value) {
    return value.isNotEmpty;
  }
}

class EmailAndPasswordValidators {
  final StringValidator emailValidator = NonEmptyStringValidator();
  final StringValidator passwordValidator = NonEmptyStringValidator();
  final StringValidator nameValidator = NonEmptyStringValidator();
  final String invalidNameErrorText = "Name cannot be empty";
  final String weakPasswordText = "Password cannot be less than 6 characters";
  String invalidEmailErrorText;
  String invalidPasswordErrorText;

  void invalidEmailFormatText() {
    invalidEmailErrorText = "Invalid email format";
    invalidPasswordErrorText = "";
  }

  void invalidEmailOrPasswordText() {
    invalidEmailErrorText = "Email may be incorrect";
    invalidPasswordErrorText = "Password may be incorrect";
  }
}
