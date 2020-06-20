//Copyright 2020 Pedro Bissonho
//
//Licensed under the Apache License, Version 2.0 (the "License");
//you may not use this file except in compliance with the License.
//You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
//Unless required by applicable law or agreed to in writing, software
//distributed under the License is distributed on an "AS IS" BASIS,
//WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//See the License for the specific language governing permissions and
//limitations under the License.

import 'dart:convert';
import 'dart:io';

import 'core/exceptions.dart';
import 'core/home_path.dart';

class ConfigKeys {
  static const String templatesPath = 'templatesPath';
  static const String scaffoldsPath = 'scaffoldsPath';
  static const String commandsFilePath = 'commandsFilePath';
}

class FastConfig {
  String templatesPath;
  String scaffoldsPath;
  String commandsFilePath;

  FastConfig({this.templatesPath, this.scaffoldsPath, this.commandsFilePath});

  FastConfig._fromJson(Map<String, dynamic> json) {
    templatesPath = json[ConfigKeys.templatesPath];
    commandsFilePath = json[ConfigKeys.commandsFilePath];
    scaffoldsPath = json[ConfigKeys.scaffoldsPath];
  }

  Map<String, dynamic> _toJson() {
    final data = <String, dynamic>{};
    data[ConfigKeys.templatesPath] = templatesPath;
    data[ConfigKeys.commandsFilePath] = commandsFilePath;
    data[ConfigKeys.scaffoldsPath] = scaffoldsPath;
    return data;
  }
}

class ConfigStorage {
  String _filePath = '${homePath}/.fast.json';

  ConfigStorage([String filePath]) {
    if (filePath != null) _filePath = filePath;
  }

  Future setConfig(FastConfig tenazConfig) async {
    await _updateFile(tenazConfig._toJson());
  }

  Future<FastConfig> getConfig() async {
    var data = await _readFile();
    return FastConfig._fromJson(data);
  }

  Future<String> getConfigByKeyOrBlank(String key) async {
    var file = File(_filePath);
    dynamic data;
    if (!await file.exists() || await file.readAsString.toString().isEmpty) {
      return '';
    }
    try {
      var fileContents = await file.readAsString();
      data = await json.decode(fileContents);
      return data[key];
    } catch (error) {
      return '';
    }
  }

  Future _updateFile(Map<String, dynamic> data) async {
    var file = File(_filePath);
    bool exists;

    exists = await file.exists();

    if (!exists) {
      print(file);
      await file.create();
    }

    var writeData = json.encode(data);

    await file.writeAsString(writeData);
  }

  Future<Map<String, dynamic>> _readFile() async {
    var file = File(_filePath);

    if (!await file.exists() || await file.readAsString.toString().isEmpty) {
      throw NotFounfFastConfigException('''
Before using the CLI, you must configure the templates folder path.
Use the command "tena config <folder path> 'to configure the location of the templates.
Example: tena config /home/pedro/Documents/templates/
          ''');
    }
    try {
      var fileContents = await file.readAsString();
      return json.decode(fileContents);
    } catch (error) {
      throw StorageException('''
An error occurred while reading the CLI settings.
Please make sure you have set a valid value for the folder path of the tamplates.

Use the command "tena config <folder path> 'to configure the location of the templates.
Example: tena config /home/pedro/Documents/templates/
          ''');
    }
  }
}
