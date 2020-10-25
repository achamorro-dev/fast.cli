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
import 'package:plain_optional/plain_optional.dart';
import 'package:pubspec_yaml/pubspec_yaml.dart';
import 'package:fast/core/action.dart';
import 'package:fast/services/packages_service.dart';

class AddDependenciesAction implements Action {
  final String pubspecPath;
  final String setPath;
  var newHostedDependencies = <PackageDependencySpec>[];
  var scaffoldYamlDependencies = <PackageDependencySpec>[];

  AddDependenciesAction(this.pubspecPath, this.setPath);

  String get finishedDescription => 'Add dependencies.';

  @override
  Future<void> execute() async {
    var pubspecFile = File(pubspecPath);

    final setPubsp = await File('$setPath').readAsStringSync().toPubspecYaml();

    for (var depen in setPubsp.dependencies) {
      await depen.iswitch(sdk: (sdk) {
        scaffoldYamlDependencies.add(PackageDependencySpec.sdk(sdk));
      }, git: (git) {
        scaffoldYamlDependencies.add(PackageDependencySpec.git(git));
      }, path: (path) {
        scaffoldYamlDependencies.add(PackageDependencySpec.path(path));
      }, hosted: (hosted) async {
        await process(hosted);
      });
    }

    final pubsYaml = await pubspecFile.readAsStringSync().toPubspecYaml();

    var finalYaml = pubsYaml.copyWith(dependencies: [
      ...newHostedDependencies,
      ...scaffoldYamlDependencies,
      ...pubsYaml.dependencies
    ], devDependencies: [
      ...setPubsp.devDependencies,
      ...pubsYaml.devDependencies
    ]);

    var yamlData = finalYaml.toYamlString();

    await pubspecFile.writeAsString(yamlData);
  }

  void process(HostedPackageDependencySpec hosted) async {
    if (hosted.version.hasValue) {
      newHostedDependencies.add(PackageDependencySpec.hosted(hosted));
    } else {
      var pubService = PackagesService();

      Package package;
      try {
        package = await pubService.fetchPackage(hosted.package);
      } catch (error) {
        rethrow;
      }

      var newHosted =
          hosted.copyWith(version: Optional('^${package.latest.version}'));

      newHostedDependencies.add(PackageDependencySpec.hosted(newHosted));
    }
  }

  @override
  String get succesMessage => 'Dependencies added to the project.';
}
