// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  print('Starting wallpaper download script...');

  final wallpapersDir = Directory('assets/wallpapers');
  if (!wallpapersDir.existsSync()) {
    print('Creating directory: ${wallpapersDir.path}');
    wallpapersDir.createSync(recursive: true);
  } else {
    print('Directory already exists: ${wallpapersDir.path}');
  }

  final client = HttpClient();
  // Set User-Agent to prevent 403 Forbidden from some CDNs/APIs
  client.userAgent = 'BrutalWallzDownloader/1.0 (Flutter App Asset Builder)';

  try {
    print('Fetching wallpaper list from Wallhaven API...');
    final apiUrl = Uri.parse('https://wallhaven.cc/api/v1/search?sorting=random');
    final apiData = await fetchJsonWithRetry(client, apiUrl);

    final rawList = apiData['data'] as List<dynamic>?;
    if (rawList == null || rawList.isEmpty) {
      throw Exception('No wallpapers returned from Wallhaven API');
    }

    final targetItems = rawList.take(20).toList();
    print('Found ${targetItems.length} wallpapers to download.');

    final metadataList = <Map<String, dynamic>>[];

    for (int i = 0; i < targetItems.length; i++) {
      final item = targetItems[i] as Map<String, dynamic>;
      final id = item['id'].toString();
      final remoteUrl = item['path'] as String;
      final category = (item['category'] as String?) ?? 'general';

      // Determine file extension
      String ext = 'jpg';
      final pathSegments = Uri.parse(remoteUrl).pathSegments;
      if (pathSegments.isNotEmpty && pathSegments.last.contains('.')) {
        ext = pathSegments.last.split('.').last.toLowerCase();
      } else if (item['file_type'] == 'image/png') {
        ext = 'png';
      }

      final fileName = '$id.$ext';
      final relativeAssetPath = 'assets/wallpapers/$fileName';
      final localFilePath = '${wallpapersDir.path}/$fileName';
      final localFile = File(localFilePath);

      print('[${i + 1}/${targetItems.length}] Downloading $id ($remoteUrl)...');
      await downloadFileWithRetry(client, Uri.parse(remoteUrl), localFile);

      final fileSizeKb = (localFile.lengthSync() / 1024).toStringAsFixed(1);
      print('Saved to $relativeAssetPath ($fileSizeKb KB)');

      metadataList.add({
        'id': id,
        'title': 'Wallhaven - $id',
        'category': category,
        'imagePath': relativeAssetPath,
        'thumbnailPath': relativeAssetPath,
      });

      // Brief delay to respect rate limits
      await Future.delayed(const Duration(milliseconds: 250));
    }

    final jsonFile = File('assets/wallpapers.json');
    const encoder = JsonEncoder.withIndent('  ');
    await jsonFile.writeAsString(encoder.convert(metadataList));
    print('Successfully generated ${jsonFile.path} with ${metadataList.length} items.');
    print('Data preparation complete!');
  } finally {
    client.close();
  }
}

Future<Map<String, dynamic>> fetchJsonWithRetry(
  HttpClient client,
  Uri uri, {
  int maxRetries = 3,
}) async {
  for (int attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      final request = await client.getUrl(uri);
      request.followRedirects = true;
      final response = await request.close();

      if (response.statusCode == 429) {
        print('Rate limited (429). Waiting 3 seconds before retry (attempt $attempt/$maxRetries)...');
        await Future.delayed(const Duration(seconds: 3));
        continue;
      }

      if (response.statusCode != 200) {
        throw HttpException('Request failed with status: ${response.statusCode}', uri: uri);
      }

      final responseBody = await response.transform(utf8.decoder).join();
      return jsonDecode(responseBody) as Map<String, dynamic>;
    } catch (e) {
      if (attempt == maxRetries) rethrow;
      print('Network error fetching $uri: $e. Retrying ($attempt/$maxRetries)...');
      await Future.delayed(Duration(seconds: attempt * 2));
    }
  }
  throw Exception('Failed to fetch JSON after $maxRetries attempts');
}

Future<void> downloadFileWithRetry(
  HttpClient client,
  Uri uri,
  File destination, {
  int maxRetries = 3,
}) async {
  for (int attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      final request = await client.getUrl(uri);
      request.followRedirects = true;
      final response = await request.close();

      if (response.statusCode == 429) {
        print('Rate limited (429) while downloading $uri. Waiting 3 seconds...');
        await Future.delayed(const Duration(seconds: 3));
        continue;
      }

      if (response.statusCode != 200) {
        throw HttpException('Download failed with status: ${response.statusCode}', uri: uri);
      }

      final sink = destination.openWrite();
      await response.pipe(sink);

      // Verify file is not empty
      if (destination.existsSync() && destination.lengthSync() > 0) {
        return;
      } else {
        throw Exception('Downloaded file is empty');
      }
    } catch (e) {
      if (destination.existsSync()) {
        try {
          destination.deleteSync();
        } catch (_) {}
      }
      if (attempt == maxRetries) rethrow;
      print('Error downloading $uri: $e. Retrying ($attempt/$maxRetries)...');
      await Future.delayed(Duration(seconds: attempt * 2));
    }
  }
  throw Exception('Failed to download $uri after $maxRetries attempts');
}
