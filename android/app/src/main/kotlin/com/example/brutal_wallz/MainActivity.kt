package com.example.brutal_wallz

import android.app.WallpaperManager
import android.graphics.BitmapFactory
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.net.URL
import kotlin.concurrent.thread

class MainActivity : FlutterActivity() {
    private val CHANNEL = "async_wallpaper"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "set_home_wallpaper_file" -> applyFromFile(call.argument<String>("url"), WallpaperManager.FLAG_SYSTEM, result)
                "set_lock_wallpaper_file" -> applyFromFile(call.argument<String>("url"), WallpaperManager.FLAG_LOCK, result)
                "set_both_wallpaper_file", "set_wallpaper_file" -> applyFromFile(
                    call.argument<String>("url"),
                    WallpaperManager.FLAG_SYSTEM or WallpaperManager.FLAG_LOCK,
                    result
                )
                "set_home_wallpaper" -> applyFromUrl(call.argument<String>("url"), WallpaperManager.FLAG_SYSTEM, result)
                "set_lock_wallpaper" -> applyFromUrl(call.argument<String>("url"), WallpaperManager.FLAG_LOCK, result)
                "set_both_wallpaper", "set_wallpaper" -> applyFromUrl(
                    call.argument<String>("url"),
                    WallpaperManager.FLAG_SYSTEM or WallpaperManager.FLAG_LOCK,
                    result
                )
                else -> result.notImplemented()
            }
        }
    }

    private fun applyFromFile(filePath: String?, flag: Int, result: MethodChannel.Result) {
        if (filePath.isNullOrEmpty()) {
            result.success(false)
            return
        }
        thread {
            try {
                val cleanPath = if (filePath.startsWith("file://")) filePath.substring(7) else filePath
                val file = File(cleanPath)
                if (!file.exists()) {
                    runOnUiThread { result.success(false) }
                    return@thread
                }
                val bitmap = BitmapFactory.decodeFile(file.absolutePath)
                if (bitmap == null) {
                    runOnUiThread { result.success(false) }
                    return@thread
                }
                val wm = WallpaperManager.getInstance(applicationContext)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    wm.setBitmap(bitmap, null, true, flag)
                } else {
                    wm.setBitmap(bitmap)
                }
                runOnUiThread { result.success(true) }
            } catch (e: Exception) {
                runOnUiThread { result.success(false) }
            }
        }
    }

    private fun applyFromUrl(url: String?, flag: Int, result: MethodChannel.Result) {
        if (url.isNullOrEmpty()) {
            result.success(false)
            return
        }
        thread {
            try {
                val connection = URL(url).openConnection()
                connection.connectTimeout = 10000
                connection.readTimeout = 10000
                val inputStream = connection.getInputStream()
                val bitmap = BitmapFactory.decodeStream(inputStream)
                inputStream.close()
                if (bitmap == null) {
                    runOnUiThread { result.success(false) }
                    return@thread
                }
                val wm = WallpaperManager.getInstance(applicationContext)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    wm.setBitmap(bitmap, null, true, flag)
                } else {
                    wm.setBitmap(bitmap)
                }
                runOnUiThread { result.success(true) }
            } catch (e: Exception) {
                runOnUiThread { result.success(false) }
            }
        }
    }
}
