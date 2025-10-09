allprojects {
    repositories {
        google()
        mavenCentral()
    }

    subprojects {
        afterEvaluate {
            if (this@subprojects.extensions.findByName("android") != null) {
                // 使用 BaseExtension，它是 ApplicationExtension 和 LibraryExtension 的父类
                (this@subprojects as org.gradle.api.plugins.ExtensionAware).extensions.configure<com.android.build.gradle.BaseExtension> {
                    if (namespace == null) {
                        namespace = project.group.toString()
                    }
                }
            }
        }
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
