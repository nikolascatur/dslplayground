import com.android.build.gradle.internal.tasks.factory.dependsOn

// Top-level build file where you can add configuration options common to all sub-projects/modules.
plugins {
    alias(libs.plugins.androidApplication) apply false
    alias(libs.plugins.jetbrainsKotlinAndroid) apply false
}

val clean = tasks.register<Delete>("clean")

val copyGitHooks = tasks.register<Copy>("copyGitHooks") {
    println("Copies the git hooks from ${rootDir}/script/hooks to the .git folder.")
    description = "Copies the git hooks from ${rootDir}/script/hooks to the .git folder."
    from("$rootDir/scripts/hooks/") {
        include("**/*.sh")
        rename("(.*).sh", "\$1")
    }
    into("$rootDir/.git/hooks")
}

val installGitHooks = tasks.register<Exec>("installGitHooks") {
    println("Installs the pre-commit git hooks from ${rootDir}/script/hooks.")
    description = "Installs the pre-commit git hooks from ${rootDir}/script/hooks."
    group = "git hooks"
    workingDir = rootDir
    commandLine("chmod")
    args("-R", "+x", ".git/hooks/")
    dependsOn(copyGitHooks)
    doLast{
        println("EXEC intall git hooks success")
    }
}

afterEvaluate{
    clean.dependsOn(installGitHooks)
}


