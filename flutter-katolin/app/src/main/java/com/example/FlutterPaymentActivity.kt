package com.example

import android.content.Intent
import android.database.Cursor
import android.net.Uri
import android.os.Bundle
import android.provider.ContactsContract
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class FlutterPaymentActivity : FlutterActivity() {

    private val CHANNEL = "com.example.shopik/telecom"
    private var pendingContactResult: MethodChannel.Result? = null

    private val contactPickerLauncher = registerForActivityResult(
        ActivityResultContracts.PickContact()
    ) { uri: Uri? ->
        val result = pendingContactResult ?: return@registerForActivityResult
        pendingContactResult = null

        if (uri == null) {
            result.success(null)
            return@registerForActivityResult
        }

        try {
            val projection = arrayOf(ContactsContract.CommonDataKinds.Phone.NUMBER)
            contentResolver.query(uri, projection, null, null, null)?.use { cursor ->
                if (cursor.moveToFirst()) {
                    val numberIndex = cursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER)
                    if (numberIndex != -1) {
                        val rawNumber = cursor.getString(numberIndex)
                        val cleaned = rawNumber.replace(Regex("[^0-9]"), "")
                            .removePrefix("967")
                            .removePrefix("00967")
                        result.success(cleaned)
                        return@registerForActivityResult
                    }
                }
            }
            result.success(null)
        } catch (e: Exception) {
            result.error("CONTACT_ERROR", e.localizedMessage, null)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getInitialSession" -> {
                    val session = SessionStore.loadSession()
                    val route = intent.getStringExtra("initialRoute") ?: "payment"
                    val data = mapOf(
                        "token" to (session.token ?: ""),
                        "baseUrl" to session.baseUrl,
                        "phone" to (session.phone ?: ""),
                        "user_name" to (session.user?.username ?: ""),
                        "wallet_balance" to (session.user?.balance ?: 0.0),
                        "initialRoute" to route
                    )
                    result.success(data)
                }

                "openNativeScreen" -> {
                    val routeName = call.argument<String>("route")
                    // If native navigation needed, finish or return result
                    result.success(true)
                }

                "pickContact" -> {
                    pendingContactResult = result
                    contactPickerLauncher.launch(null)
                }

                "syncWalletBalance" -> {
                    // Triggers host balance sync when payment completes
                    result.success(true)
                }

                "closeScreen" -> {
                    finish()
                    result.success(true)
                }

                else -> result.notImplemented()
            }
        }
    }

    companion object {
        fun launch(activity: android.app.Activity) {
            val intent = Intent(activity, FlutterPaymentActivity::class.java)
            activity.startActivity(intent)
        }
    }
}
