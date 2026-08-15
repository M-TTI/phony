// Measures the internal documentation rate of the Dart sources under `lib/`.
//
// Definition used here — stated explicitly because the number is only worth
// something if everyone computes it the same way:
//
//   rate = comment lines / (comment lines + code lines)
//
//   * blank lines count for nothing, on either side of the ratio;
//   * a line counts as a comment when, once trimmed, it starts with `//` or
//     sits inside a `/* ... */` block. `///` doc comments are counted as
//     comments too, and reported separately as a sub-metric;
//   * a trailing comment on a code line (`foo(); // why`) counts as code. The
//     measure is therefore conservative: it never inflates the rate;
//   * generated files (`*.g.dart`) are excluded — they are not written by hand
//     and drift emits no documentation, so they would only dilute the ratio.
//
// Known limit: the classification is line-based, not a Dart parse. A `//` at
// the start of a line inside a multi-line string would be miscounted as a
// comment. `lib/` currently holds no multi-line string, and the error would be
// a handful of lines out of three thousand.
//
// Usage:
//   dart run tools/doc_coverage.dart [--path=lib] [--min=8] [--max=15]
//                                    [--markdown] [--fail]
//
//   --markdown  emit a GitHub-flavoured Markdown report instead of plain text
//   --fail      exit with code 1 when the rate falls outside [min, max]
//               (without it the script only reports, and always exits 0)

import 'dart:io';

/// Per-file line counts. [code] excludes blank lines.
class FileStats {
  FileStats(this.path, this.comment, this.doc, this.code);

  final String path;
  final int comment;
  final int doc;
  final int code;

  int get total => comment + code;

  double get rate => total == 0 ? 0 : comment * 100 / total;
}

void main(List<String> arguments) {
  final Map<String, String> options = _parseArguments(arguments);

  final String path = options['path'] ?? 'lib';
  final double min = double.parse(options['min'] ?? '8');
  final double max = double.parse(options['max'] ?? '15');
  final bool markdown = options.containsKey('markdown');
  final bool failOnMiss = options.containsKey('fail');

  final Directory root = Directory(path);
  if (!root.existsSync()) {
    stderr.writeln('doc_coverage: directory not found: $path');
    exit(2);
  }

  final List<FileStats> stats = <FileStats>[];
  for (final FileSystemEntity entity in root.listSync(recursive: true)) {
    if (entity is! File) {
      continue;
    }
    if (!entity.path.endsWith('.dart') || entity.path.endsWith('.g.dart')) {
      continue;
    }
    stats.add(_measure(entity));
  }

  if (stats.isEmpty) {
    stderr.writeln('doc_coverage: no hand-written Dart file found under $path');
    exit(2);
  }

  stats.sort((FileStats a, FileStats b) => a.rate.compareTo(b.rate));

  final int comment = stats.fold(0, (int sum, FileStats f) => sum + f.comment);
  final int doc = stats.fold(0, (int sum, FileStats f) => sum + f.doc);
  final int code = stats.fold(0, (int sum, FileStats f) => sum + f.code);
  final double rate = comment * 100 / (comment + code);
  final bool inRange = rate >= min && rate <= max;

  stdout.write(
    markdown
        ? _markdownReport(stats, path, comment, doc, code, rate, min, max)
        : _textReport(stats, path, comment, doc, code, rate, min, max),
  );

  if (failOnMiss && !inRange) {
    exit(1);
  }
}

/// Reads `--flag` and `--key=value` arguments into a map; a bare flag maps to
/// an empty string, which is why callers test with `containsKey`.
Map<String, String> _parseArguments(List<String> arguments) {
  final Map<String, String> options = <String, String>{};
  for (final String argument in arguments) {
    if (!argument.startsWith('--')) {
      stderr.writeln('doc_coverage: unexpected argument: $argument');
      exit(2);
    }
    final String body = argument.substring(2);
    final int separator = body.indexOf('=');
    if (separator == -1) {
      options[body] = '';
    } else {
      options[body.substring(0, separator)] = body.substring(separator + 1);
    }
  }
  return options;
}

FileStats _measure(File file) {
  int comment = 0;
  int doc = 0;
  int code = 0;
  bool inBlock = false;

  for (final String line in file.readAsLinesSync()) {
    final String trimmed = line.trim();

    if (inBlock) {
      comment++;
      if (trimmed.contains('*/')) {
        inBlock = false;
      }
      continue;
    }

    if (trimmed.isEmpty) {
      continue;
    }

    if (trimmed.startsWith('///')) {
      comment++;
      doc++;
      continue;
    }

    if (trimmed.startsWith('//')) {
      comment++;
      continue;
    }

    if (trimmed.startsWith('/*')) {
      comment++;
      if (!trimmed.contains('*/')) {
        inBlock = true;
      }
      continue;
    }

    code++;
  }

  return FileStats(file.path, comment, doc, code);
}

String _verdict(double rate, double min, double max) {
  if (rate < min) {
    return 'below target';
  }
  if (rate > max) {
    return 'above target';
  }
  return 'within target';
}

String _textReport(
  List<FileStats> stats,
  String path,
  int comment,
  int doc,
  int code,
  double rate,
  double min,
  double max,
) {
  final StringBuffer out = StringBuffer()
    ..writeln(
      'Documentation coverage — $path (${stats.length} files, '
      'generated files excluded)',
    )
    ..writeln()
    ..writeln(
      '  comment lines   ${comment.toString().padLeft(6)}'
      '   (of which $doc doc comments)',
    )
    ..writeln('  code lines      ${code.toString().padLeft(6)}')
    ..writeln(
      '  rate            ${rate.toStringAsFixed(2).padLeft(6)} %'
      '   target ${min.toStringAsFixed(0)}–${max.toStringAsFixed(0)} %'
      '   ${_verdict(rate, min, max)}',
    )
    ..writeln()
    ..writeln('Least documented files:');

  for (final FileStats file in stats.take(10)) {
    out.writeln(
      '  ${file.rate.toStringAsFixed(2).padLeft(6)} %  '
      '${file.comment.toString().padLeft(4)} / ${file.total.toString().padLeft(5)}  '
      '${file.path}',
    );
  }

  return out.toString();
}

String _markdownReport(
  List<FileStats> stats,
  String path,
  int comment,
  int doc,
  int code,
  double rate,
  double min,
  double max,
) {
  final bool inRange = rate >= min && rate <= max;
  final StringBuffer out = StringBuffer()
    ..writeln('## Documentation coverage')
    ..writeln()
    ..writeln(
      '${inRange ? '✅' : '⚠️'} **${rate.toStringAsFixed(2)} %** '
      'of `$path` is comment — target '
      '${min.toStringAsFixed(0)}–${max.toStringAsFixed(0)} % '
      '(${_verdict(rate, min, max)}).',
    )
    ..writeln()
    ..writeln('| Metric | Lines |')
    ..writeln('| --- | ---: |')
    ..writeln('| Comment lines | $comment |')
    ..writeln('| … of which `///` doc comments | $doc |')
    ..writeln('| Code lines | $code |')
    ..writeln('| Files measured | ${stats.length} |')
    ..writeln()
    ..writeln(
      '<details><summary>Per-file breakdown '
      '(least documented first)</summary>',
    )
    ..writeln()
    ..writeln('| File | Comment | Code | Rate |')
    ..writeln('| --- | ---: | ---: | ---: |');

  for (final FileStats file in stats) {
    out.writeln(
      '| `${file.path}` | ${file.comment} | ${file.code} | '
      '${file.rate.toStringAsFixed(2)} % |',
    );
  }

  out
    ..writeln()
    ..writeln('</details>');

  return out.toString();
}
