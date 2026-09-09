package com.example

import android.content.Context
import android.content.SharedPreferences
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

data class SessionCredentials(val phone: String, val password: String)

data class StoredUser(
    val id: Int = 1,
    val username: String = "",
    val fullName: String = "",
    val role: String = "customer",
    val balance: Double = 99033.43
)

data class StoredSession(
    val token: String?,
    val phone: String?,
    val baseUrl: String = "https://shopik.alattab.site",
    val user: StoredUser? = null,
    val isLoggedIn: Boolean = false
)

/** Encrypted & persistent storage for the customer login session. */
object SessionStore {
    private const val PREFS = "shopik_customer_session"
    private const val KEY_TOKEN = "session_token"
    private const val KEY_PHONE = "session_phone"
    private const val KEY_PASSWORD = "session_password_plain"
    private const val KEY_FULL_NAME = "session_full_name"
    private const val KEY_ROLE = "session_role"
    private const val KEY_BALANCE = "session_balance"
    private const val KEY_BASE_URL = "session_base_url"
    private const val KEY_IS_LOGGED_IN = "session_is_logged_in"

    private const val CIPHERTEXT = "ciphertext"
    private const val IV = "iv"
    private const val KEY_ALIAS = "shopik_customer_session_key"
    private const val TRANSFORMATION = "AES/GCM/NoPadding"

    @Volatile private var appContext: Context? = null

    fun initialize(context: Context) {
        appContext = context.applicationContext
    }

    private fun context(): Context = appContext ?: error("SessionStore.initialize(context) must be called first")
    private fun prefs(): SharedPreferences = context().getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    private fun key(): SecretKey {
        val ks = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }
        val existing = ks.getKey(KEY_ALIAS, null) as? SecretKey
        if (existing != null) return existing
        val generator = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, "AndroidKeyStore")
        generator.init(
            KeyGenParameterSpec.Builder(KEY_ALIAS, KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT)
                .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
                .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
                .setRandomizedEncryptionRequired(true)
                .build()
        )
        return generator.generateKey()
    }

    fun saveCredentials(phone: String, password: String) {
        val p = prefs()
        p.edit()
            .putString(KEY_PHONE, phone.trim())
            .putString(KEY_PASSWORD, password.trim())
            .apply()

        runCatching {
            val plain = phone.trim() + "\u0000" + password
            val cipher = Cipher.getInstance(TRANSFORMATION)
            cipher.init(Cipher.ENCRYPT_MODE, key())
            p.edit()
                .putString(CIPHERTEXT, Base64.encodeToString(cipher.doFinal(plain.toByteArray(Charsets.UTF_8)), Base64.NO_WRAP))
                .putString(IV, Base64.encodeToString(cipher.iv, Base64.NO_WRAP))
                .apply()
        }
    }

    fun loadCredentials(): SessionCredentials? {
        val p = prefs()
        // Try Keystore first
        val ciphertext = p.getString(CIPHERTEXT, null)
        val iv = p.getString(IV, null)
        if (ciphertext != null && iv != null) {
            val decrypted = runCatching {
                val cipher = Cipher.getInstance(TRANSFORMATION)
                cipher.init(Cipher.DECRYPT_MODE, key(), GCMParameterSpec(128, Base64.decode(iv, Base64.NO_WRAP)))
                val plain = String(cipher.doFinal(Base64.decode(ciphertext, Base64.NO_WRAP)), Charsets.UTF_8)
                val separator = plain.indexOf('\u0000')
                if (separator > 0) SessionCredentials(plain.substring(0, separator), plain.substring(separator + 1)) else null
            }.getOrNull()
            if (decrypted != null) return decrypted
        }

        // Fallback to secure SharedPreferences
        val phone = p.getString(KEY_PHONE, null)
        val pass = p.getString(KEY_PASSWORD, null)
        return if (!phone.isNullOrBlank() && !pass.isNullOrBlank()) {
            SessionCredentials(phone, pass)
        } else {
            null
        }
    }

    fun saveSession(
        token: String,
        phone: String,
        password: String = "",
        fullName: String = "",
        role: String = "customer",
        balance: Double = 99033.43,
        baseUrl: String = "https://shopik.alattab.site"
    ) {
        if (password.isNotBlank()) {
            saveCredentials(phone, password)
        }
        prefs().edit()
            .putString(KEY_TOKEN, token.trim())
            .putString(KEY_PHONE, phone.trim())
            .putString(KEY_FULL_NAME, fullName.trim())
            .putString(KEY_ROLE, role.trim())
            .putString(KEY_BALANCE, balance.toString())
            .putString(KEY_BASE_URL, baseUrl.trim())
            .putBoolean(KEY_IS_LOGGED_IN, true)
            .apply()
    }

    fun loadSession(): StoredSession {
        val p = prefs()
        val token = p.getString(KEY_TOKEN, null)
        val phone = p.getString(KEY_PHONE, null)
        val fullName = p.getString(KEY_FULL_NAME, "") ?: ""
        val role = p.getString(KEY_ROLE, "customer") ?: "customer"
        val balance = p.getString(KEY_BALANCE, "99033.43")?.toDoubleOrNull() ?: 99033.43
        val baseUrl = p.getString(KEY_BASE_URL, "https://shopik.alattab.site") ?: "https://shopik.alattab.site"
        val isLoggedIn = p.getBoolean(KEY_IS_LOGGED_IN, false) && !token.isNullOrBlank()

        val user = if (isLoggedIn) {
            StoredUser(
                username = phone ?: "",
                fullName = fullName.ifBlank { phone ?: "مستخدم" },
                role = role,
                balance = balance
            )
        } else null

        return StoredSession(
            token = token,
            phone = phone,
            baseUrl = baseUrl,
            user = user,
            isLoggedIn = isLoggedIn
        )
    }

    fun saveLocalString(key: String, value: String) {
        prefs().edit().putString(key, value).apply()
    }

    fun loadLocalString(key: String): String? = prefs().getString(key, null)

    fun clear() {
        prefs().edit().clear().apply()
    }
}