import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:workly/resuable_widgets/custom_appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:workly/services/auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:workly/services/database.dart';

/*
Notes:
- Profile pic change: deletes the existing profile pic off storage and
  uploads a new one to replace it with.
 */
class MainSettings extends StatefulWidget {
  @override
  _MainSettingsState createState() => _MainSettingsState();
}

class _MainSettingsState extends State<MainSettings> {
  String _email;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _verifyPwController = TextEditingController();

  PickedFile _image;
  ImageProvider<dynamic> image;
  bool _isEdit;
  bool _isEditPw;
  bool _hasImg;
  bool _incorrectPwMatch;
  bool _pwComplexityMatch;
  bool _nameBlank;

  String cacheName;
  ImageProvider<dynamic> cacheImage;

  @override
  void initState() {
    super.initState();

    _isEdit = false;
    _isEditPw = false;
    _hasImg = false;
    _incorrectPwMatch = false;
    _nameBlank = false;
    _pwComplexityMatch = false;

    _email = "";
    _pwController.text = "";
    _verifyPwController.text = "";
    _nameController.text = "";

    _queryDetails();
  }

  @override
  void setState(fn) {
    // TODO: implement setState
    if (mounted) {
      super.setState(fn);
    }
  }

  void _queryDetails() async {
    final auth = Provider.of<AuthBase>(context, listen: false);
    User user = await auth.currentUser();
    final DocumentSnapshot docSnap = await Firestore.instance
        .collection('users')
        .document('${user.uid}')
        .get();
    Map map = docSnap.data;
    setState(() {
      _email = map['email'];
      _nameController.text = map['name'];
      cacheName = _nameController.text;
      String url = map['imageUrl'].toString();
      if (url == "null") {
        _hasImg = false;
        image = null;
        cacheImage = image;
      } else {
        _hasImg = true;
        image = NetworkImage(map['imageUrl'].toString());
        cacheImage = image;
      }
    });
  }

  void _onEditPw() {
    if (_isEditPw) {
      _submit(true);
    } else {
      setState(() {
        _isEditPw = !_isEditPw;
      });
    }
  }

  void _onDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Are you sure?"),
        content: Text("You will lose this account forever."),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              _onDelete();
              Navigator.of(context).pop();
            },
            child: Text("Yes"),
          ),
          FlatButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("No"),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }

  /*
  Deletes:
  - Profile pic
  - User document
  - User authentication profile
   */
  void _onDelete() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    await delImg(user.uid);
    await delDoc(user.uid);
    await user.delete();
    await _signOut();
  }

  Future<void> delImg(String uid) async {
    final FirebaseStorage _storage =
        FirebaseStorage(storageBucket: 'gs://workly-7af57.appspot.com');
    if (_hasImg) await _storage.ref().child('profile/$uid.png').delete();
  }

  Future<void> delDoc(String id) async {
    await Firestore.instance.document('users/$id').delete();
  }

  void _onEdit() {
    if (_isEdit) {
      _submit(false);
    } else {
      setState(() {
        _isEdit = !_isEdit;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE9E9E9),
      appBar: CustomAppbar.appBar('Settings'),
      body: _constructor(),
    );
  }

  void refresh() => setState(() {});

  Future<String> _uploadProfileImage(String uid) async {
    final FirebaseStorage _storage =
        FirebaseStorage(storageBucket: 'gs://workly-7af57.appspot.com');
    if (_hasImg) await _storage.ref().child('profile/$uid.png').delete();
    StorageUploadTask _upload =
        _storage.ref().child('profile/$uid.png').putFile(File(_image.path));
    StorageTaskSnapshot _snapshot = await _upload.onComplete;
    setState(() {
      _hasImg = true;
    });
    if (_snapshot.error == null) {
      String _url = await _snapshot.ref.getDownloadURL();
      return _url;
    } else {
      return null;
    }
  }

  void _submit(bool pw) async {
    print(_nameController.text);
    if (!pw && (_nameController.text == null || _nameController.text == "")) {
      setState(() {
        _nameBlank = true;
      });
    } else if (pw && !_pwMatch()) {
      setState(() {
        _incorrectPwMatch = true;
        _pwComplexityMatch = false;
      });
    } else if (pw && (_pwController.text.length < 6 ||
        _verifyPwController.text.length < 6)) {
      setState(() {
        _pwComplexityMatch = true;
        _incorrectPwMatch = false;
      });
    } else {
      setState(() {
        _nameBlank = false;
        _incorrectPwMatch = false;
        _pwComplexityMatch = false;
        cacheImage = image;
        cacheName = _nameController.text;
        if (pw) {
          _isEditPw = false;
        } else {
          _isEdit = false;
        }
      });
      _editUser(pw);
    }
  }

  bool _pwMatch() {
    return _pwController.text == _verifyPwController.text;
  }

  bool _blankCheckPw() {
    return (_pwController.text != null || _pwController.text != "") &&
        (_verifyPwController.text != null || _verifyPwController.text != "");
  }

  void _editUser(bool pw) async {
    final auth = Provider.of<AuthBase>(context, listen: false);
    final db = Provider.of<Database>(context, listen: false);
    User user = await auth.currentUser();
    String _url;
    if (_image != null) {
      _url = await _uploadProfileImage(user.uid);
    }
    FirebaseUser userAuth = await FirebaseAuth.instance.currentUser();
    if (pw) {
      //TODO PW SHOULD BE 6 CHARACTERS
      userAuth.updatePassword(_pwController.text);
    } else {
      if (_image != null) {
        Firestore.instance.document('users/${user.uid}').updateData({
          'name': _nameController.text.trim(),
          'email': _email,
          'uid': user.uid,
          'imageUrl': _url,
        });
        await db.updateUserDetails(_nameController.text.trim(), _url);
      } else {
        Firestore.instance.document('users/${user.uid}').updateData({
          'name': _nameController.text.trim(),
          'email': _email,
          'uid': user.uid,
        });
        await db.updateUserDetails(_nameController.text.trim(), null);
      }
    }
    setState(() {
      _pwController.clear();
      _verifyPwController.clear();
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    //TODO: DELETE IMAGE FIRST - DONE
    PickedFile selectedImage = await ImagePicker()
        .getImage(source: source, preferredCameraDevice: CameraDevice.front);
    // Image.file(File(selectedImage.path));
    if (selectedImage != null) {
      setState(() {
        _image = selectedImage;
        image = FileImage(File(_image.path));
      });
    }
  }

  Widget _showImageSource() {
    return AlertDialog(
      title: Text(
        "Pick image from",
        style: TextStyle(
          fontSize: 18,
        ),
      ),
      titlePadding: EdgeInsets.only(left: 20, top: 5),
      backgroundColor: Color(0xFFE9E9E9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      contentPadding: EdgeInsets.only(
        top: 10,
        bottom: 15,
      ),
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
                    Text(
                      "Camera",
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
                    Text(
                      "Gallery",
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

  String get _password => _pwController.text;

  String get _name => _nameController.text;

  Widget _nameEditor() {
    return Container(
      margin: EdgeInsets.only(left: 8, right: 8, bottom: 8),
      padding: EdgeInsets.only(
          left: _isEdit ? 10 : 20, right: _isEdit ? 10 : 20, bottom: 8, top: 8),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Flexible(
                child: Container(
                  margin: EdgeInsets.only(
                      left: _isEdit ? 10 : 0, right: _isEdit ? 10 : 0),
                  child: Text(
                    "Name:",
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: 15,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 5),
          Row(
            children: <Widget>[
              _isEdit
                  ? Flexible(
                      child: TextField(
                        controller: _nameController,
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.start,
                        //maxLines: 4,
                        readOnly: !_isEdit,
                        maxLines: 1,
                        decoration: InputDecoration(
                          hintText: "Your name",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24)),
                        ),
                      ),
                    )
                  : Flexible(
                      child: Text(
                        "$_name",
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
            ],
          ),
        ],
      ),
      decoration: BoxDecoration(
        color: Color(0xFFFCFCFC),
        borderRadius: BorderRadius.all(Radius.circular(35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 15,
            offset: Offset(0, 3),
          ),
        ],
      ),
    );
  }

  void _changeEditPw() {
    setState(() {
      _isEditPw = true;
    });
  }

  void _cancelEditPw() {
    setState(() {
      _isEditPw = false;
      _pwController.text = null;
      _verifyPwController.text = null;
    });
  }

  Widget _passwordEditor() {
    if (_isEditPw) {
      return Container(
        margin: EdgeInsets.only(left: 8, right: 8, bottom: 8),
        padding: EdgeInsets.only(left: 10, right: 10, bottom: 8, top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 5),
            TextField(
              controller: _pwController,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontSize: 15,
              ),
              textAlign: TextAlign.start,
              readOnly: !_isEditPw,
              maxLines: 1,
              decoration: InputDecoration(
                hintText: "Your new password",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: _verifyPwController,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontSize: 15,
              ),
              textAlign: TextAlign.start,
              readOnly: !_isEditPw,
              maxLines: 1,
              decoration: InputDecoration(
                hintText: "Verify password",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
              ),
            ),
            SizedBox(height: 5),
            _incorrectPwMatch
                ? _smallText("Passwords don't match")
                : SizedBox(),
            _pwComplexityMatch
                ? _smallText("Password needs to be at least 6 characters")
                : SizedBox(),
            SizedBox(height: 15),
            Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(right: 8),
                  child: FlatButton(
                    color: Color(0xFF04C9F1),
                    onPressed: () => _onEditPw(),
                    child: Text(
                      "Save",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF04C9F1).withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(right: 8),
                  child: FlatButton(
                    color: Color(0xFFE9E9E9),
                    onPressed: () => _cancelEditPw(),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 15,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                ),
              ],
            ),
          ],
        ),
        decoration: BoxDecoration(
          color: Color(0xFFFCFCFC),
          borderRadius: BorderRadius.all(Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 15,
              offset: Offset(0, 3),
            ),
          ],
        ),
      );
    } else {
      return _normalSize("Change your password", "Change",
          () => _changeEditPw(), Color(0xFF04C9F1));
    }
  }

  Widget _smallText(String txt) {
    return Padding(
      padding: EdgeInsets.only(left: 10, right: 10),
      child: Text(
        txt,
        style: TextStyle(
          color: Colors.redAccent,
          fontSize: 12,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _emailBox() {
    return Container(
      margin: EdgeInsets.only(left: 8, right: 8, bottom: 8),
      padding: EdgeInsets.only(left: 20, right: 20, bottom: 8, top: 8),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Flexible(
                child: Text(
                  _isEdit ? "Email (can't be changed):" : "Email:",
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 15,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 5),
          Row(
            children: <Widget>[
              Text(
                "$_email",
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                ),
              ),
              Spacer(),
            ],
          ),
        ],
      ),
      decoration: BoxDecoration(
        color: Color(0xFFFCFCFC),
        borderRadius: BorderRadius.all(Radius.circular(35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 15,
            offset: Offset(0, 3),
          ),
        ],
      ),
    );
  }

  Widget _normalSize(String hS, String bS, Function f, Color c) {
    return Container(
      margin: EdgeInsets.only(left: 8, right: 8, bottom: 8),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 9,
            child: Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text(
                hS,
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 15,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              margin: EdgeInsets.only(right: 8),
              child: FlatButton(
                color: c,
                onPressed: f,
                child: Text(
                  bS,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: c.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      decoration: BoxDecoration(
        color: Color(0xFFFCFCFC),
        borderRadius: BorderRadius.all(Radius.circular(35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 15,
            offset: Offset(0, 3),
          ),
        ],
      ),
    );
  }

  Widget _imgWidget() {
    return Container(
      margin: EdgeInsets.only(left: 8, right: 8, bottom: 8),
      child: Row(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  "Profile picture",
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 15,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              _isEdit
                  ? Container(
                      margin: EdgeInsets.only(right: 8, left: 20),
                      child: FlatButton(
                        color: Color(0xFFE9E9E9),
                        onPressed: () => {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return _showImageSource();
                            },
                            barrierDismissible: true,
                          ),
                        },
                        child: Text(
                          "Upload new",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 15,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                      ),
                    )
                  : SizedBox(),
            ],
          ),
          Spacer(),
          makeAvatar(),
        ],
      ),
      decoration: BoxDecoration(
        color: Color(0xFFFCFCFC),
        borderRadius: BorderRadius.all(Radius.circular(35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 15,
            offset: Offset(0, 3),
          ),
        ],
      ),
    );
  }

  void _cancelEdit() {
    //TODO: CHANGE TO OTHER METHOD OF BACKUP CACHE
    setState(() {
      _isEdit = false;
      _nameController.text = cacheName;
      image = cacheImage;
    });
  }

  //TODO: CARD SYSTEM TOP ACC DETAILS BOTTOM PW LAST DELETE
  Widget _constructor() {
    //return normalSize("test", "test", () => null, Colors.redAccent);
    return ListView(
      children: <Widget>[
        SizedBox(height: 20),
        Container(
          margin: EdgeInsets.only(left: 10, right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 9,
                    child: _headingText("Account"),
                  ),
                  _isEdit
                      ? Expanded(
                          flex: 4,
                          child: Container(
                            margin: EdgeInsets.only(right: 8),
                            child: FlatButton(
                              color: Color(0xFFFCFCFC),
                              onPressed: () => _cancelEdit(),
                              child: Text(
                                //TODO: CHANGE TO SAVE ONCE _ISEDIT
                                "Cancel",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 15,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SizedBox(),
                  Expanded(
                    flex: 4,
                    child: Container(
                      margin: EdgeInsets.only(right: 8),
                      child: FlatButton(
                        color: _isEdit ? Color(0xFF04C9F1) : Color(0xFFE9E9E9),
                        onPressed: () => _onEdit(),
                        child: Text(
                          !_isEdit ? "Edit" : "Save",
                          style: TextStyle(
                            color: _isEdit ? Colors.white : Colors.black87,
                            fontSize: 15,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        boxShadow: [
                          BoxShadow(
                            color: _isEdit
                                ? Color(0xFF04C9F1).withOpacity(0.2)
                                : Colors.black.withOpacity(0.08),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                  ),
                  //TODO: EDIT BUTTON
                ],
              ),
              _imgWidget(),
              _nameEditor(),
              SizedBox(height: 5),
              _nameBlank && _isEdit ? _smallText("Name can't be blank") : SizedBox(),
              _emailBox(),
              _normalSize("Sign out from your account", "Sign out",
                  () => _signOut(), Colors.black54),
            ],
          ),
          decoration: BoxDecoration(
            color: Color(0xFFE9E9E9),
            borderRadius: BorderRadius.all(Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 15,
                offset: Offset(0, 3),
              ),
            ],
          ),
        ),
        SizedBox(height: 25),
        Container(
          margin: EdgeInsets.only(left: 10, right: 10),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Flexible(
                    child: _headingText("Password"),
                  ),
                ],
              ),
              _passwordEditor(),
            ],
          ),
          decoration: BoxDecoration(
            color: Color(0xFFE9E9E9),
            borderRadius: BorderRadius.all(Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 15,
                offset: Offset(0, 3),
              ),
            ],
          ),
        ),
        SizedBox(height: 25),
        Container(
          margin: EdgeInsets.only(left: 10, right: 10),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Flexible(
                    child: _headingText("Others"),
                  ),
                ],
              ),
              _normalSize("Delete account", "Delete", () => _onDeleteDialog(),
                  Colors.redAccent),
              //TODO: NEEDS DIALOGUE FOR ONDELETE
            ],
          ),
          decoration: BoxDecoration(
            color: Color(0xFFE9E9E9),
            borderRadius: BorderRadius.all(Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 15,
                offset: Offset(0, 3),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _signOut() async {
    try {
      final auth = Provider.of<AuthBase>(context, listen: false);
      await auth.signOut();
    } catch (e) {
      print(e.toString);
    }
  }

  Widget _headingText(String text) {
    return Container(
      margin: EdgeInsets.only(
        left: 22,
        right: 15,
        top: 15,
        bottom: 15,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Color(0xFF141336),
          fontSize: 20,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget makeAvatar() {
    return Container(
      margin: EdgeInsets.only(
        bottom: 12,
        top: 15,
        right: 15,
      ),
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Color(0xFFE5E5E5),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black38.withOpacity(0.12),
            spreadRadius: 2,
            blurRadius: 10,
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
}
