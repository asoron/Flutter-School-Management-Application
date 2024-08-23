import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../Settings/theme_notifier.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeColor = Provider.of<ThemeNotifier>(context).themeColor;

    return Scaffold(
      appBar: AppBar(
        title: Text('Ayarlar', style: TextStyle(color: themeColor)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: themeColor),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Görünüm Ayarları',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: themeColor,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.color_lens, color: themeColor),
              title: const Text('Tema Rengi'),
              trailing: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: themeColor,
                  shape: BoxShape.circle,
                ),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Tema Rengini Seç',
                          style: TextStyle(color: themeColor)),
                      content: SingleChildScrollView(
                        child: BlockPicker(
                          pickerColor: themeColor,
                          onColorChanged: (Color color) {
                            Provider.of<ThemeNotifier>(context, listen: false)
                                .changeThemeColor(color);
                          },
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Kapat',
                              style: TextStyle(color: themeColor)),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            Divider(thickness: 1, color: themeColor.withOpacity(0.5)),
            SwitchListTile(
              title: const Text('Karanlık Mod'),
              value: Provider.of<ThemeNotifier>(context).isDarkMode,
              onChanged: (bool value) {
                Provider.of<ThemeNotifier>(context, listen: false)
                    .toggleDarkMode(value);
              },
              activeColor: themeColor,
              secondary: Icon(Icons.dark_mode, color: themeColor),
            ),
            Divider(thickness: 1, color: themeColor.withOpacity(0.5)),
            ListTile(
              title: const Text('Font Boyutu'),
              subtitle: Slider(
                value: Provider.of<ThemeNotifier>(context).fontSize,
                min: 10.0,
                max: 30.0,
                divisions: 20,
                label: Provider.of<ThemeNotifier>(context).fontSize.toString(),
                onChanged: (double value) {
                  Provider.of<ThemeNotifier>(context, listen: false)
                      .changeFontSize(value);
                },
                activeColor: themeColor,
                inactiveColor: themeColor.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
