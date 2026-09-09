pluginManagement {
  repositories {
    google {
      content {
        includeGroupByRegex("com\\.android.*")
        includeGroupByRegex("com\\.google.*")
        includeGroupByRegex("androidx.*")
      }
    }
    mavenCentral()
    gradlePluginPortal()
  }
}

plugins { id("org.gradle.toolchains.foojay-resolver-convention") version "1.0.0" }

dependencyResolutionManagement {
  repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
  repositories {
    google()
    mavenCentral()
  }
}

rootProject.name = "شبيك"

include(":app")

// Integration with Flutter Payment Network Module
val flutterProject = file("flutter_payment_network")
val includeFlutterScript = file("${flutterProject.path}/.android/include_flutter.groovy")
if (includeFlutterScript.exists()) {
    apply(from = includeFlutterScript)
}
