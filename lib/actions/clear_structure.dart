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
import 'dart:io';

import 'package:fast/core/action.dart';
import 'package:fast/core/directory/directory.dart';

class ClearScaffoldStructure implements Action {
  final String path;
  final List<String> excludedFiles;

  ClearScaffoldStructure(this.path, {this.excludedFiles = const []});

  @override
  Future<void> execute() async {
    await Directory(path).clear(excludedFiles: excludedFiles);
  }

  @override
  String get succesMessage => 'Cleaned ${path} folder.';
}
