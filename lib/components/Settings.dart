import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotube/components/Shared/PageWindowTitleBar.dart';
import 'package:spotube/main.dart';
import 'package:spotube/models/LocalStorageKeys.dart';
import 'package:spotube/provider/Auth.dart';
import 'package:spotube/provider/UserPreferences.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  TextEditingController? _textEditingController;
  String? _geniusAccessToken;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _textEditingController?.addListener(() {
      setState(() {
        _geniusAccessToken = _textEditingController?.value.text;
      });
    });
  }

  @override
  void dispose() {
    _textEditingController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    UserPreferences preferences = context.watch<UserPreferences>();

    return Scaffold(
      appBar: PageWindowTitleBar(
        leading: const BackButton(),
        center: Text(
          "Settings",
          style: Theme.of(context).textTheme.headline5,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    "Genius Access Token",
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: _textEditingController,
                    decoration: InputDecoration(
                      hintText: preferences.geniusAccessToken,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: _geniusAccessToken != null
                        ? () async {
                            SharedPreferences localStorage =
                                await SharedPreferences.getInstance();
                            preferences
                                .setGeniusAccessToken(_geniusAccessToken);
                            localStorage.setString(
                                LocalStorageKeys.geniusAccessToken,
                                _geniusAccessToken!);
                            setState(() {
                              _geniusAccessToken = null;
                            });
                            _textEditingController?.text = "";
                          }
                        : null,
                    child: const Text("Save"),
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Theme"),
                DropdownButton<ThemeMode>(
                  value: MyApp.of(context)?.getThemeMode(),
                  items: const [
                    DropdownMenuItem(
                      child: Text(
                        "Dark",
                      ),
                      value: ThemeMode.dark,
                    ),
                    DropdownMenuItem(
                      child: Text(
                        "Light",
                      ),
                      value: ThemeMode.light,
                    ),
                    DropdownMenuItem(
                      child: Text("System"),
                      value: ThemeMode.system,
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      MyApp.of(context)?.setThemeMode(value);
                    }
                  },
                )
              ],
            ),
            const SizedBox(height: 10),
            Builder(builder: (context) {
              var auth = context.read<Auth>();
              return ElevatedButton(
                child: const Text("Logout"),
                onPressed: () async {
                  SharedPreferences localStorage =
                      await SharedPreferences.getInstance();
                  await localStorage.clear();
                  auth.logout();
                  Navigator.of(context).pop();
                },
              );
            })
          ],
        ),
      ),
    );
  }
}
