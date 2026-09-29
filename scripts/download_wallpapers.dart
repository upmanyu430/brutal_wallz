// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

/// Offline asset preparation script for Brutal Wallz.
///
/// Connects to the Wallhaven API, downloads 20 random wallpapers to the local
/// `assets/wallpapers/` directory, and generates `assets/wallpapers.json` metadata
/// for bundling with the mobile application.
///
/// Includes automated retries with exponential backoff and rate-limit handling.
Future<void> main() async {
  print('Starting wallpaper download script...');

  // Ensure target asset directory exists
  final wallpapersDir = Directory('assets/wallpapers');
  if (!wallpapersDir.existsSync()) {
    print('Creating directory: ${wallpapersDir.path}');
    wallpapersDir.createSync(recursive: true);
  } else {
    print('Directory already exists: ${wallpapersDir.path}');
  }

  // Create an HTTP client with custom User-Agent to avoid 403 Forbidden blocks from CDNs
  final client = HttpClient();
  client.userAgent = 'BrutalWallzDownloader/1.0 (Flutter App Asset Builder)';

  try {
    print('Fetching wallpaper list from Wallhaven API...');
    final apiUrl = Uri.parse('https://wallhaven.cc/api/v1/search?sorting=random');
    final apiData = await fetchJsonWithRetry(client, apiUrl);

    // Extract wallpaper array from API response payload
    final rawList = apiData['data'] as List<dynamic>?;
    if (rawList == null || rawList.isEmpty) {
      throw Exception('No wallpapers returned from Wallhaven API');
    }

    // Select the first 20 wallpapers for the offline bundle
    final targetItems = rawList.take(20).toList();
    print('Found ${targetItems.length} wallpapers to download.');

    final metadataList = <Map<String, dynamic>>[];

    // Iterate through items and download assets sequentially
    for (int i = 0; i < targetItems.length; i++) {
      final item = targetItems[i] as Map<String, dynamic>;
      final id = item['id'].toString();
      final remoteUrl = item['path'] as String;
      final category = (item['category'] as String?) ?? 'general';

      // Determine file extension (.jpg or .png) based on URL path or file_type
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

      // Record offline metadata record
      metadataList.add({
        'id': id,
        'title': 'Wallhaven - $id',
        'category': category,
        'imagePath': relativeAssetPath,
        'thumbnailPath': relativeAssetPath,
      });

      // Brief delay between downloads to respect external API rate limits
      await Future.delayed(const Duration(milliseconds: 250));
    }

    // Write metadata records out to indented JSON bundle
    final jsonFile = File('assets/wallpapers.json');
    const encoder = JsonEncoder.withIndent('  ');
    await jsonFile.writeAsString(encoder.convert(metadataList));
    print('Successfully generated ${jsonFile.path} with ${metadataList.length} items.');
    print('Data preparation complete!');
  } finally {
    // Always close HTTP client to release network connections
    client.close();
  }
}

/// Fetches JSON payload from [uri] using [client] with automatic retry on failures or rate limits (429).
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

      // Handle HTTP 429 Too Many Requests with fixed cooldown
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
      // Exponential backoff delay
      await Future.delayed(Duration(seconds: attempt * 2));
    }
  }
  throw Exception('Failed to fetch JSON after $maxRetries attempts');
}

/// Downloads a binary file from [uri] to [destination] with automatic retry and validation.
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

      // Handle HTTP 429 Too Many Requests
      if (response.statusCode == 429) {
        print('Rate limited (429) while downloading $uri. Waiting 3 seconds...');
        await Future.delayed(const Duration(seconds: 3));
        continue;
      }

      if (response.statusCode != 200) {
        throw HttpException('Download failed with status: ${response.statusCode}', uri: uri);
      }

      // Stream response bytes directly into file sink
      final sink = destination.openWrite();
      await response.pipe(sink);

      // Verify downloaded file exists and is non-empty
      if (destination.existsSync() && destination.lengthSync() > 0) {
        return;
      } else {
        throw Exception('Downloaded file is empty');
      }
    } catch (e) {
      // Clean up partially written corrupted file on failure
      if (destination.existsSync()) {
        try {
          destination.deleteSync();
        } catch (_) {}
      }
      if (attempt == maxRetries) rethrow;
      print('Error downloading $uri: $e. Retrying ($attempt/$maxRetries)...');
      // Exponential backoff
      await Future.delayed(Duration(seconds: attempt * 2));
    }
  }
  throw Exception('Failed to download $uri after $maxRetries attempts');
}
