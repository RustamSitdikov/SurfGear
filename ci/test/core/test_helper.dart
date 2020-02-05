import 'dart:io';

import 'package:ci/domain/element.dart';
import 'package:ci/services/managers/file_system_manager.dart';
import 'package:ci/services/managers/license_manager.dart';
import 'package:ci/services/managers/shell_manager.dart';
import 'package:ci/services/pubspec_parser.dart';
import 'package:ci/services/runner/shell_runner.dart';
import 'package:ci/tasks/core/task.dart';
import 'package:ci/tasks/factories/license_task_factory.dart';
import 'package:mockito/mockito.dart';
import 'package:shell/shell.dart';
import 'package:test/test.dart';

/// Common

/// Проверяем что выполнение не выбросит исключения.
void expectNoThrow(
  actual, {
  String reason,
  skip,
}) =>
    expect(actual, returnsNormally, reason: reason, skip: skip);

/// Подмена задачи
class TaskMock<T> extends Mock implements Task<T> {}

/// Замена задачи, которая завершается успешно
TaskMock<T> createSuccessTask<T>({T result}) {
  var mock = TaskMock<T>();
  when(mock.run()).thenAnswer((_) => Future.value(result));

  return mock;
}

/// Замена задачи, которая завершается ошибкой
TaskMock<T> createFailTask<T>({Exception exception}) {
  exception ??= Exception('test');
  var mock = TaskMock<T>();
  when(mock.run()).thenAnswer((_) => Future.error(exception));

  return mock;
}

/// Shell part

class ShellMock extends Mock implements Shell {}

/// Подменяет шелл у раннера и возвращает экземпляр замены.
ShellMock substituteShell({
  ShellManager manager,
  Map<String, dynamic> callingMap,
}) {
  var mock = ShellMock();

  callingMap?.forEach((command, result) {
    var parsed = command.split(' ');
    var cmd = parsed[0];
    parsed.remove(cmd);

    ProcessResult answer;
    if (result is ProcessResult) {
      answer = result;
    }

    if (result is bool) {
      answer = result ? createPositiveResult() : createErrorResult();
    }

    when(mock.run(cmd, parsed)).thenAnswer(
      (_) => Future.value(
        answer ?? createPositiveResult(),
      ),
    );
  });

  ShellRunner.init(shell: mock, manager: manager);
  return mock;
}

/// Тестовый ответ на консольную команду, сценарий без ошибки.
ProcessResult createPositiveResult({
  dynamic stdout = 'test out',
  dynamic stderr,
}) =>
    ProcessResult(
      0,
      0,
      stdout,
      stderr,
    );

/// Тестовый ответ на консольную команду, сценарий с ошибкой.
ProcessResult createErrorResult({
  int exitCode = 1,
  dynamic stdout,
  dynamic stderr = 'test error',
}) =>
    ProcessResult(
      0,
      exitCode,
      stdout,
      stderr,
    );

/// File System Manager

class FileSystemManagerMock extends Mock implements FileSystemManager {}

/// Shell Manager

class ShellManagerMock extends Mock implements ShellManager {}

ShellManagerMock createShellManagerMock({Shell copy}) {
  var mock = ShellManagerMock();
  when(mock.copy(any)).thenReturn(copy);
  return mock;
}

/// License manager

class LicenseManagerMock extends Mock implements LicenseManager {}

LicenseManagerMock createLicenseManagerMock({
  String license,
  String copyright,
}) {
  var mock = LicenseManagerMock();

  if (license != null) {
    when(mock.getLicense()).thenAnswer((_) => Future.value(license));
  }

  if (copyright != null) {
    when(mock.getCopyright()).thenAnswer((_) => Future.value(copyright));
  }
}

/// Element

Element createTestElement({
  String name = 'testName',
  String path = 'test/path',
  bool isStable = false,
  bool isChanged = false,
}) {
  return Element(
    name: name,
    uri: Uri.directory(path),
    isStable: isStable,
    changed: isChanged,
  );
}

/// License Task Factory

class LicenseTaskFactoryMock extends Mock implements LicenseTaskFactory {}

/// Pubspec Parser

class PubspecParserMock extends Mock implements PubspecParser {}