allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    val applyFixes: () -> Unit = {
        val android = extensions.findByName("android")
        if (android != null) {
            try {
                val getNamespace = android.javaClass.getMethod("getNamespace")
                val namespace = getNamespace.invoke(android)
                if (namespace == null) {
                    val setNamespace = android.javaClass.getMethod("setNamespace", String::class.java)
                    val pkgName = "dev.isar." + project.name.replace("-", "_").replace(".", "_")
                    setNamespace.invoke(android, pkgName)
                }
            } catch (_: Exception) {
            }
            try {
                val setCompileSdk = android.javaClass.getMethod("setCompileSdkVersion", Int::class.javaPrimitiveType)
                setCompileSdk.invoke(android, 35)
            } catch (_: Exception) {
                try {
                    val setCompileSdkStr = android.javaClass.getMethod("setCompileSdkVersion", String::class.java)
                    setCompileSdkStr.invoke(android, "android-35")
                } catch (_: Exception) {
                }
            }
        }
    }
    if (state.executed) {
        applyFixes()
    } else {
        afterEvaluate { applyFixes() }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
