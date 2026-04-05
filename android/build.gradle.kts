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
    
    // Fix for missing namespace and old SDK in older plugins (required by AGP 8.0+)
    afterEvaluate {
        if (project.hasProperty("android")) {
            val extension = project.extensions.findByName("android")
            if (extension is com.android.build.gradle.BaseExtension) {
                if (extension.namespace == null) {
                    extension.namespace = "com.timeleak.${project.name.replace("-", "_")}"
                }
                // Force a compatible compile SDK version
                extension.compileSdkVersion(36)
            }
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
